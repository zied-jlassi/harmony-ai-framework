# Document Parser Service - RGPD Compliant

> Universal RGPD-compliant document parser - 100% Local Processing

## Security

```
┌─────────────────────────────────────────────────────────────────┐
│              SECURITY VALIDATION - RGPD COMPLIANT               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ✅ PyMuPDF (fitz) - 100% LOCAL                                 │
│  ✅ python-docx - 100% LOCAL                                    │
│  ✅ pandas + openpyxl - 100% LOCAL                              │
│  ✅ python-pptx - 100% LOCAL                                    │
│                                                                  │
│  ❌ NO cloud APIs                                                │
│  ❌ NO external data transfer                                    │
│  ❌ NO third-party processors                                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Usage

### Build and Start

```bash
# Build the image
docker compose build

# Start the service
docker compose up -d
```

### Parse Documents

```bash
# Parse PDF
docker exec harmony-doc-parser python -m services.pdf_parser /documents/file.pdf

# Parse DOCX
docker exec harmony-doc-parser python -m services.docx_parser /documents/file.docx

# Parse Excel
docker exec harmony-doc-parser python -m services.excel_parser /documents/file.xlsx

# Save output to JSON
docker exec harmony-doc-parser python -m services.pdf_parser /documents/file.pdf /parsed/output.json
```

### Python API

```python
from services import PDFParser, DOCXParser, ExcelParser

# PDF with semantic chunking
pdf = PDFParser(chunk_size=400, overlap=0.15)
result = pdf.parse('/documents/contract.pdf')

# DOCX with structure preservation
docx = DOCXParser()
result = docx.parse('/documents/report.docx')

# Excel with statistics
excel = ExcelParser()
result = excel.parse('/documents/data.xlsx')
```

## Chunking Strategy

Based on 2025 benchmarks:

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Chunk size | 256-512 tokens | Optimal for LLM context |
| Overlap | 10-20% | Preserve context continuity |
| Strategy | Semantic | +70% accuracy vs fixed-size |

## Output Format

All parsers return a consistent JSON structure:

```json
{
  "source": "filename.ext",
  "parser": "parser-name",
  "rgpd_compliant": true,
  "metadata": { ... },
  "content": { ... }
}
```

## Forbidden Tools

These tools are **FORBIDDEN** for RGPD compliance:

| Tool | Reason |
|------|--------|
| unstructured.io API | Sends data to cloud |
| Google Document AI | Cloud processing |
| Azure Form Recognizer | Cloud processing |
| AWS Textract | Cloud processing |

## Integration

To use in a project, add to your docker-compose.yml:

```yaml
services:
  doc-parser:
    build:
      context: ./path/to/document-parser
      dockerfile: Dockerfile
    container_name: myapp-doc-parser
    volumes:
      - ./documents/source:/documents:ro
      - ./documents/parsed:/parsed
    restart: unless-stopped
```
