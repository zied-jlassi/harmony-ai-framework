"""
Summary Generator - Generate navigation index for large parsed files
Enables quick navigation without reading full 25K+ token files

Usage:
    python -m services.summary_generator /parsed/file.json
    python -m services.summary_generator /parsed/*.json  # Batch mode
"""

import json
import argparse
import glob
from pathlib import Path
from typing import List, Optional


class SummaryGenerator:
    """Generate index summary for navigation in large parsed files"""

    # Token limit for Read tool
    TOKEN_LIMIT = 25000

    def generate(self, parsed_file: str) -> dict:
        """
        Create *-summary.json from parsed file.

        Args:
            parsed_file: Path to parsed JSON file

        Returns:
            Summary dict with sections and chunk ranges
        """
        with open(parsed_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        total_tokens = data.get("total_tokens", 0)

        summary = {
            "source": str(Path(parsed_file).name),
            "source_path": parsed_file,
            "total_chunks": len(data.get("chunks", [])),
            "total_tokens": total_tokens,
            "exceeds_limit": total_tokens > self.TOKEN_LIMIT,
            "recommended_strategy": self._get_strategy(total_tokens),
            "metadata": data.get("metadata", {}),
            "sections": []
        }

        # Extract sections by analyzing titles
        current_section = None
        section_start = 0
        chunks = data.get("chunks", [])

        for i, chunk in enumerate(chunks):
            text = chunk.get("text", "")

            # Check first 3 lines for titles
            lines = text.split('\n')
            for line in lines[:3]:
                if self._is_title(line):
                    # Save previous section
                    if current_section:
                        summary["sections"].append(
                            self._create_section(
                                current_section, section_start, i - 1, chunks
                            )
                        )
                    current_section = line.strip()
                    section_start = i
                    break

        # Add last section
        if current_section:
            summary["sections"].append(
                self._create_section(
                    current_section, section_start, len(chunks) - 1, chunks
                )
            )

        # If no sections found, create one default section
        if not summary["sections"] and chunks:
            summary["sections"].append({
                "title": "Document Content",
                "chunk_range": [0, len(chunks) - 1],
                "tokens_estimate": total_tokens,
                "pages": self._get_pages_range(chunks, 0, len(chunks) - 1)
            })

        # Save summary
        summary_path = parsed_file.replace('.json', '-summary.json')
        with open(summary_path, 'w', encoding='utf-8') as f:
            json.dump(summary, f, indent=2, ensure_ascii=False)

        return summary

    def _create_section(self, title: str, start: int, end: int, chunks: List[dict]) -> dict:
        """Create a section entry with metadata."""
        tokens = sum(
            c.get("tokens", 0) for c in chunks[start:end + 1]
        )
        return {
            "title": title[:100],  # Truncate long titles
            "chunk_range": [start, end],
            "tokens_estimate": tokens,
            "pages": self._get_pages_range(chunks, start, end)
        }

    def _get_pages_range(self, chunks: List[dict], start: int, end: int) -> str:
        """Get page range string for a section."""
        pages = set()
        for c in chunks[start:end + 1]:
            if "page" in c:
                pages.add(c["page"])
        if pages:
            page_list = sorted(pages)
            if len(page_list) == 1:
                return str(page_list[0])
            return f"{page_list[0]}-{page_list[-1]}"
        return "N/A"

    def _get_strategy(self, total_tokens: int) -> str:
        """Recommend reading strategy based on token count."""
        if total_tokens <= self.TOKEN_LIMIT:
            return "direct_read"
        elif total_tokens <= self.TOKEN_LIMIT * 2:
            return "read_with_offset"
        else:
            return "section_navigation"

    def _is_title(self, line: str) -> bool:
        """
        Detect if a line is likely a title.

        Criteria:
        - Markdown heading (#, ##, etc.)
        - ALL CAPS or mostly caps (>50%)
        - Numbered (1., 1.1, I., II., etc.)
        - Short lines with specific patterns
        """
        line = line.strip()

        # Skip empty or very long lines
        if not line or len(line) > 100:
            return False

        # Skip lines that are just dashes or equals
        if set(line) <= {'-', '=', '_', ' '}:
            return False

        # Markdown headings
        if line.startswith('#'):
            return True

        # Mostly uppercase (>50% uppercase letters)
        letters = [c for c in line if c.isalpha()]
        if len(letters) > 5:
            upper_ratio = sum(1 for c in letters if c.isupper()) / len(letters)
            if upper_ratio > 0.5:
                return True

        # Numbered titles (1., 1.1, I., II., etc.)
        if len(line) > 2:
            # Arabic numerals: 1., 1.1, 1.1.1, etc.
            if line[0].isdigit() and ('.' in line[:5] or ':' in line[:5]):
                return True
            # Roman numerals
            if line[:3] in ['I. ', 'II.', 'III', 'IV.', 'V. ', 'VI.', 'VII', 'VII', 'IX.', 'X. ']:
                return True

        # Chapter/Section keywords (French and English)
        lower = line.lower()
        title_keywords = [
            'chapitre', 'chapter', 'section', 'partie', 'part',
            'introduction', 'conclusion', 'annexe', 'annex', 'appendix',
            'sommaire', 'table des', 'index', 'glossaire', 'glossary',
            'resume', 'abstract', 'preface', 'avant-propos'
        ]
        for keyword in title_keywords:
            if lower.startswith(keyword):
                return True

        return False

    def generate_batch(self, pattern: str) -> List[dict]:
        """
        Generate summaries for multiple files.

        Args:
            pattern: Glob pattern (e.g., "/parsed/*.json")

        Returns:
            List of generated summaries
        """
        files = glob.glob(pattern)
        # Exclude existing summary files
        files = [f for f in files if not f.endswith('-summary.json')]

        results = []
        for file_path in files:
            try:
                summary = self.generate(file_path)
                results.append({
                    "file": file_path,
                    "status": "success",
                    "sections": len(summary["sections"]),
                    "exceeds_limit": summary["exceeds_limit"]
                })
                print(f"✓ {Path(file_path).name}: {len(summary['sections'])} sections")
            except Exception as e:
                results.append({
                    "file": file_path,
                    "status": "error",
                    "error": str(e)
                })
                print(f"✗ {Path(file_path).name}: {e}")

        return results


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate navigation summaries for large parsed files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python -m services.summary_generator /parsed/document.json
  python -m services.summary_generator "/parsed/*.json"  # Batch mode
  python -m services.summary_generator /parsed/ --all    # All JSON files
        """
    )
    parser.add_argument("path", help="Path to JSON file or glob pattern")
    parser.add_argument("--all", "-a", action="store_true",
                        help="Process all JSON files in directory")

    args = parser.parse_args()

    generator = SummaryGenerator()

    if args.all or '*' in args.path:
        pattern = args.path
        if args.all and not pattern.endswith('*'):
            pattern = str(Path(args.path) / "*.json")
        results = generator.generate_batch(pattern)
        print(f"\nProcessed {len(results)} files")
        success = sum(1 for r in results if r["status"] == "success")
        print(f"Success: {success}, Errors: {len(results) - success}")
    else:
        summary = generator.generate(args.path)
        print(json.dumps(summary, indent=2, ensure_ascii=False))
