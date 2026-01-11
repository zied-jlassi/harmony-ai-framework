"""
Document Parsing Services - RGPD Compliant
100% local processing - NO data sent externally

Supported formats:
- PDF: PyMuPDF with semantic chunking
- DOCX: python-docx with structure preservation
- XLSX/XLS: pandas + openpyxl with statistics
- PPTX: python-pptx with notes extraction
- Universal: TXT, MD, XML, HTML, JSON, YAML, CSV, Code files, Jupyter, Config files
"""

from .pdf_parser import PDFParser
from .docx_parser import DOCXParser
from .excel_parser import ExcelParser
from .pptx_parser import PPTXParser
from .universal_parser import UniversalParser

__all__ = [
    'PDFParser',
    'DOCXParser',
    'ExcelParser',
    'PPTXParser',
    'UniversalParser'
]


def parse_file(file_path: str, **kwargs) -> dict:
    """
    Auto-detect file type and parse accordingly.

    Args:
        file_path: Path to file
        **kwargs: Additional arguments passed to parser

    Returns:
        Parsed content as dict
    """
    from pathlib import Path
    suffix = Path(file_path).suffix.lower()

    # Route to specialized parsers first
    specialized = {
        '.pdf': PDFParser,
        '.docx': DOCXParser,
        '.xlsx': ExcelParser,
        '.xls': ExcelParser,
        '.pptx': PPTXParser,
    }

    parser_class = specialized.get(suffix, UniversalParser)
    parser = parser_class(**kwargs) if kwargs else parser_class()
    return parser.parse(file_path)
