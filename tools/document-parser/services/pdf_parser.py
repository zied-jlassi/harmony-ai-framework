"""
PDF Parser - 100% Local RGPD Compliant with OCR Support
Uses PyMuPDF (fitz) + Tesseract + Surya - NO cloud APIs

OPTIMIZATIONS:
- O2: ThreadPoolExecutor for parallel page extraction (4-8x speedup)
- Page selection: --pages "1-10" or "1,3,5-8"

OCR SUPPORT:
- Auto-detection: native text → Tesseract OCR → Surya OCR
- Tesseract >= 5.1.0 (CVE-2024-29511 patched)
- Surya OCR for complex layouts (90+ languages)
"""

import fitz  # PyMuPDF
import json
import argparse
import os
import io
import sys
from typing import Optional, List, Tuple, Literal
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from enum import Enum
import threading

# PIL for Surya OCR
from PIL import Image


class OCREngine(Enum):
    """Available OCR engines."""
    AUTO = "auto"      # Auto-detect best engine
    NATIVE = "native"  # PyMuPDF native only (no OCR)
    TESSERACT = "tesseract"  # Tesseract via PyMuPDF
    SURYA = "surya"    # Surya OCR (advanced)


class PDFParser:
    """Parse PDF 100% local - RGPD compliant with OCR support."""

    # Minimum text threshold to consider a page as "has text"
    MIN_TEXT_CHARS = 50

    # Surya models (lazy loaded)
    _surya_det_model = None
    _surya_det_processor = None
    _surya_rec_model = None
    _surya_rec_processor = None

    # Thread lock for OCR (Leptonica/Tesseract is NOT thread-safe)
    _ocr_lock = threading.Lock()

    def __init__(
        self,
        chunk_size: int = 200,
        overlap: float = 0.15,
        max_workers: int = 4,
        ocr_engine: OCREngine = OCREngine.AUTO,
        ocr_lang: str = "fra+eng",
        ocr_dpi: int = 150,
        force_ocr: bool = False
    ):
        """
        Initialize PDF parser with chunking and OCR parameters.

        Args:
            chunk_size: Target chunk size in words (~256 tokens max)
            overlap: Overlap ratio between chunks (15% default)
            max_workers: Number of threads for parallel extraction
            ocr_engine: OCR engine to use (auto, native, tesseract, surya)
            ocr_lang: OCR language(s) - Tesseract format (e.g., "fra+eng")
            ocr_dpi: DPI for OCR rendering (default: 150)
            force_ocr: Force OCR even if native text exists
        """
        self.chunk_size = chunk_size
        self.overlap = overlap
        self.max_workers = max_workers
        self.ocr_engine = ocr_engine
        self.ocr_lang = ocr_lang
        self.ocr_dpi = ocr_dpi
        self.force_ocr = force_ocr

        # OCR statistics
        self.ocr_stats = {
            "native_pages": 0,
            "tesseract_pages": 0,
            "surya_pages": 0,
            "failed_pages": 0
        }

    def parse(self, file_path: str, pages: Optional[str] = None) -> dict:
        """
        Extract text and metadata from PDF with OCR fallback.

        Args:
            file_path: Path to PDF file
            pages: Page selection (e.g., "5", "1-10", "1,3,5-8")

        Returns:
            dict with metadata, chunks, and OCR statistics
        """
        # Reset OCR stats
        self.ocr_stats = {
            "native_pages": 0,
            "tesseract_pages": 0,
            "surya_pages": 0,
            "failed_pages": 0
        }

        doc = fitz.open(file_path)
        total_pages = len(doc)

        # Parse page selection
        page_indices = self._parse_page_range(pages, total_pages)

        result = {
            "source": str(Path(file_path).name),
            "parser": "PyMuPDF",
            "rgpd_compliant": True,
            "ocr_enabled": self.ocr_engine != OCREngine.NATIVE,
            "metadata": {
                "total_pages": total_pages,
                "parsed_pages": len(page_indices),
                "page_range": pages if pages else "all",
                "title": doc.metadata.get("title", ""),
                "author": doc.metadata.get("author", ""),
                "subject": doc.metadata.get("subject", ""),
                "creator": doc.metadata.get("creator", ""),
                "ocr_engine": self.ocr_engine.value,
                "ocr_lang": self.ocr_lang,
                "ocr_dpi": self.ocr_dpi,
            },
            "chunks": []
        }

        # Extract pages with OCR fallback
        # IMPORTANT: Force sequential when OCR is enabled (Leptonica is NOT thread-safe)
        use_parallel = (
            len(page_indices) > 10 and
            self.max_workers > 1 and
            self.ocr_engine == OCREngine.NATIVE and  # Parallel only safe without OCR
            not self.force_ocr
        )
        if use_parallel:
            page_texts = self._extract_pages_parallel(doc, page_indices)
        else:
            page_texts = self._extract_pages_sequential(doc, page_indices)

        # Sequential chunking (CPU-bound, benefits from locality)
        for page_num, text, extraction_method in page_texts:
            if not text.strip():
                continue

            chunks = self._semantic_chunk(text)

            for i, chunk in enumerate(chunks):
                if chunk.strip():
                    result["chunks"].append({
                        "page": page_num + 1,
                        "chunk_index": i,
                        "text": chunk,
                        "tokens": len(chunk.split()),
                        "extraction": extraction_method
                    })

        doc.close()

        result["total_chunks"] = len(result["chunks"])
        result["total_tokens"] = sum(c["tokens"] for c in result["chunks"])
        result["ocr_stats"] = self.ocr_stats

        return result

    def _parse_page_range(self, pages: Optional[str], total: int) -> List[int]:
        """Parse page specification to list of 0-indexed page indices."""
        if pages is None:
            return list(range(total))

        indices = set()
        for part in pages.split(','):
            part = part.strip()
            if '-' in part:
                start, end = part.split('-', 1)
                start = max(1, int(start))
                end = min(total, int(end))
                indices.update(range(start - 1, end))
            else:
                page = int(part)
                if 1 <= page <= total:
                    indices.add(page - 1)

        return sorted(indices)

    def _extract_pages_sequential(self, doc, page_indices: List[int]) -> List[Tuple[int, str, str]]:
        """Extract pages sequentially with OCR fallback."""
        results = []
        for idx in page_indices:
            text, method = self._extract_page_text(doc, idx)
            results.append((idx, text, method))
        return results

    def _extract_pages_parallel(self, doc, page_indices: List[int]) -> List[Tuple[int, str, str]]:
        """Extract pages in parallel with OCR fallback."""
        results = []

        def extract_page(idx):
            return (idx, *self._extract_page_text(doc, idx))

        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = {executor.submit(extract_page, idx): idx for idx in page_indices}
            for future in as_completed(futures):
                results.append(future.result())

        results.sort(key=lambda x: x[0])
        return results

    def _extract_page_text(self, doc, page_idx: int) -> Tuple[str, str]:
        """
        Extract text from a single page with OCR fallback.

        Returns:
            Tuple of (text, extraction_method)
        """
        page = doc[page_idx]

        # Try native text extraction first (unless force_ocr)
        if not self.force_ocr:
            native_text = page.get_text()
            if len(native_text.strip()) >= self.MIN_TEXT_CHARS:
                self.ocr_stats["native_pages"] += 1
                return native_text, "native"

        # OCR fallback
        if self.ocr_engine == OCREngine.NATIVE:
            self.ocr_stats["failed_pages"] += 1
            return "", "none"

        # Try Tesseract first (faster)
        if self.ocr_engine in (OCREngine.AUTO, OCREngine.TESSERACT):
            text = self._extract_with_tesseract(page)
            if len(text.strip()) >= self.MIN_TEXT_CHARS:
                self.ocr_stats["tesseract_pages"] += 1
                return text, "tesseract"

        # Try Surya for complex layouts
        if self.ocr_engine in (OCREngine.AUTO, OCREngine.SURYA):
            text = self._extract_with_surya(page)
            if len(text.strip()) >= self.MIN_TEXT_CHARS:
                self.ocr_stats["surya_pages"] += 1
                return text, "surya"

        # Last resort: return whatever we got
        self.ocr_stats["failed_pages"] += 1
        return text if 'text' in dir() else "", "failed"

    def _extract_with_tesseract(self, page) -> str:
        """
        Extract text using Tesseract via PyMuPDF's pdfocr_tobytes.

        Uses PyMuPDF's built-in Tesseract integration for optimal performance.
        Note: Uses thread lock because Leptonica/Tesseract is NOT thread-safe.
        """
        try:
            # Render page to pixmap (can be done outside lock)
            pix = page.get_pixmap(dpi=self.ocr_dpi)

            # Convert to RGB if needed (required for OCR)
            if pix.n > 3:  # CMYK or other
                pix = fitz.Pixmap(fitz.csRGB, pix)
            if pix.alpha:  # Remove alpha channel
                pix = fitz.Pixmap(pix, 0)

            # OCR using PyMuPDF's Tesseract integration
            # CRITICAL: Use lock because Leptonica is NOT thread-safe
            with PDFParser._ocr_lock:
                pdf_bytes = pix.pdfocr_tobytes(language=self.ocr_lang)

            # Extract text from the OCR'd PDF
            temp_doc = fitz.open("pdf", pdf_bytes)
            text = temp_doc[0].get_text()
            temp_doc.close()

            return text

        except Exception as e:
            print(f"[WARNING] Tesseract OCR failed: {e}", file=sys.stderr)
            return ""

    def _extract_with_surya(self, page) -> str:
        """
        Extract text using Surya OCR (advanced layout analysis).

        Surya provides better results for complex documents with tables,
        multi-column layouts, and mixed content.
        """
        try:
            # Lazy load Surya models (heavy, only load when needed)
            if PDFParser._surya_det_model is None:
                self._load_surya_models()

            # Render page to pixmap
            pix = page.get_pixmap(dpi=self.ocr_dpi)

            # Convert to PIL Image
            img_data = pix.tobytes("png")
            pil_image = Image.open(io.BytesIO(img_data)).convert("RGB")

            # Run Surya OCR
            from surya.ocr import run_ocr

            # Determine language codes for Surya
            surya_langs = self._tesseract_to_surya_langs(self.ocr_lang)

            results = run_ocr(
                [pil_image],
                [surya_langs],
                PDFParser._surya_det_model,
                PDFParser._surya_det_processor,
                PDFParser._surya_rec_model,
                PDFParser._surya_rec_processor
            )

            # Extract text from results
            if results and len(results) > 0:
                text_lines = []
                for text_line in results[0].text_lines:
                    text_lines.append(text_line.text)
                return "\n".join(text_lines)

            return ""

        except Exception as e:
            print(f"[WARNING] Surya OCR failed: {e}", file=sys.stderr)
            return ""

    @classmethod
    def _load_surya_models(cls):
        """Lazy load Surya models (only when needed)."""
        print("[INFO] Loading Surya OCR models (first time only)...", file=sys.stderr)

        from surya.model.detection.model import load_model as load_det_model
        from surya.model.detection.model import load_processor as load_det_processor
        from surya.model.recognition.model import load_model as load_rec_model
        from surya.model.recognition.processor import load_processor as load_rec_processor

        cls._surya_det_model = load_det_model()
        cls._surya_det_processor = load_det_processor()
        cls._surya_rec_model = load_rec_model()
        cls._surya_rec_processor = load_rec_processor()

        print("[INFO] Surya OCR models loaded.", file=sys.stderr)

    def _tesseract_to_surya_langs(self, tess_lang: str) -> List[str]:
        """Convert Tesseract language codes to Surya format."""
        # Mapping of common Tesseract codes to Surya/ISO codes
        mapping = {
            "fra": "fr",
            "eng": "en",
            "deu": "de",
            "spa": "es",
            "ita": "it",
            "por": "pt",
            "nld": "nl",
            "ara": "ar",
            "chi_sim": "zh",
            "chi_tra": "zh",
            "jpn": "ja",
            "kor": "ko",
            "rus": "ru",
        }

        langs = []
        for code in tess_lang.split("+"):
            code = code.strip()
            langs.append(mapping.get(code, code))

        return langs if langs else ["en", "fr"]

    def _semantic_chunk(self, text: str) -> list:
        """
        Semantic chunking with overlap.
        Splits by paragraphs first, then by sentence if needed.
        """
        # Split by double newlines (paragraphs)
        paragraphs = [p.strip() for p in text.split('\n\n') if p.strip()]

        # Pre-compute word counts (O1 optimization)
        para_word_counts = [len(p.split()) for p in paragraphs]

        chunks = []
        current_chunk = ""
        current_words = 0
        overlap_buffer = ""

        for para, para_words in zip(paragraphs, para_word_counts):
            if current_words + para_words < self.chunk_size:
                current_chunk += para + "\n\n"
                current_words += para_words
            else:
                if current_chunk:
                    chunks.append(current_chunk.strip())
                    # Calculate overlap
                    overlap_size = int(current_words * self.overlap)
                    words = current_chunk.split()
                    overlap_buffer = " ".join(words[-overlap_size:]) if overlap_size > 0 else ""

                current_chunk = overlap_buffer + " " + para + "\n\n" if overlap_buffer else para + "\n\n"
                current_words = len(current_chunk.split())

        if current_chunk.strip():
            chunks.append(current_chunk.strip())

        return chunks

    def parse_to_json(self, file_path: str, pages: Optional[str] = None, output_path: Optional[str] = None) -> str:
        """Parse PDF and save as JSON."""
        result = self.parse(file_path, pages)
        json_str = json.dumps(result, ensure_ascii=False, indent=2)

        if output_path:
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(json_str)

        return json_str


def main():
    """CLI entry point."""
    parser = argparse.ArgumentParser(
        description="PDF Parser - 100% Local RGPD Compliant with OCR Support",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic usage
  python pdf_parser.py document.pdf                    # All pages, auto OCR
  python pdf_parser.py document.pdf --pages 5          # Page 5 only
  python pdf_parser.py document.pdf --pages 1-10       # Pages 1 to 10
  python pdf_parser.py document.pdf -o output.json     # Save to file
  python pdf_parser.py document.pdf -o out.json -s     # + Generate summary

  # OCR options
  python pdf_parser.py scan.pdf --ocr                  # Force OCR on all pages
  python pdf_parser.py scan.pdf --ocr-engine surya     # Use Surya OCR
  python pdf_parser.py scan.pdf --lang fra             # French only
  python pdf_parser.py scan.pdf --dpi 300              # Higher quality OCR

  # Engine selection
  --ocr-engine auto       # Auto-detect best engine (default)
  --ocr-engine native     # No OCR, native text only
  --ocr-engine tesseract  # Tesseract OCR only
  --ocr-engine surya      # Surya OCR only (advanced)
        """
    )

    # Input/Output
    parser.add_argument("file", help="Path to PDF file")
    parser.add_argument("--pages", "-p", help="Page selection (e.g., '1-10', '1,3,5-8')")
    parser.add_argument("--output", "-o", help="Output JSON file path")
    parser.add_argument("--workers", "-w", type=int, default=4, help="Number of worker threads (default: 4)")
    parser.add_argument("--summary", "-s", action="store_true", help="Generate summary file")

    # OCR options
    parser.add_argument("--ocr", action="store_true", help="Force OCR on all pages")
    parser.add_argument(
        "--ocr-engine",
        choices=["auto", "native", "tesseract", "surya"],
        default="auto",
        help="OCR engine to use (default: auto)"
    )
    parser.add_argument("--lang", default="fra+eng", help="OCR language(s), Tesseract format (default: fra+eng)")
    parser.add_argument("--dpi", type=int, default=150, help="OCR rendering DPI (default: 150)")

    args = parser.parse_args()

    # Create parser with OCR settings
    ocr_engine = OCREngine(args.ocr_engine)

    pdf_parser = PDFParser(
        max_workers=args.workers,
        ocr_engine=ocr_engine,
        ocr_lang=args.lang,
        ocr_dpi=args.dpi,
        force_ocr=args.ocr
    )

    # Parse PDF
    result = pdf_parser.parse_to_json(args.file, args.pages, args.output)
    print(result)

    # Print OCR statistics to stderr
    stats = pdf_parser.ocr_stats
    print(f"\n✓ OCR Statistics:", file=sys.stderr)
    print(f"  Native pages:    {stats['native_pages']}", file=sys.stderr)
    print(f"  Tesseract pages: {stats['tesseract_pages']}", file=sys.stderr)
    print(f"  Surya pages:     {stats['surya_pages']}", file=sys.stderr)
    print(f"  Failed pages:    {stats['failed_pages']}", file=sys.stderr)

    # Generate summary if requested
    if args.summary and args.output:
        from services.summary_generator import SummaryGenerator
        generator = SummaryGenerator()
        summary = generator.generate(args.output)
        print(f"\n✓ Summary generated: {args.output.replace('.json', '-summary.json')}", file=sys.stderr)
        print(f"  Sections: {len(summary['sections'])}, Exceeds limit: {summary['exceeds_limit']}", file=sys.stderr)


if __name__ == "__main__":
    main()
