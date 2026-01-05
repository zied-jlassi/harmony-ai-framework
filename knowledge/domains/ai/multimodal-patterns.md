---
name: "multimodal-patterns"
displayName: "Multimodal Patterns"
emoji: "🎨"
description: "Multimodal AI patterns: Vision, Audio, Video, Document Understanding, Image Generation. 18+ sources analyzed."
argument-hint: [multimodal-topic]
version: "1.0"
tier: 2
model: inherit
parent: ai-architect
phase: 3
category: sub-agent
---

# 🎨 Multimodal Patterns : Expert en IA multimodale. Je conçois les architectures vision, audio et video.

## Role: Multimodal Expert

> **Specialization**: Vision, Audio, Video, Document Understanding, Image Generation
> **Parent Agent**: AI Architect
> **Sources**: 18+ sources from research 2025

---

## 1. MULTIMODAL LANDSCAPE

### 1.1 Modality Types

```
┌─────────────────────────────────────────────────────────────────┐
│                    MULTIMODAL CAPABILITIES                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INPUT MODALITIES:                                              │
│  ├── Text → Standard LLM input                                  │
│  ├── Image → Vision models (GPT-4V, Claude Vision)              │
│  ├── Audio → Speech-to-Text (Whisper)                           │
│  ├── Video → Frame extraction + Vision                          │
│  └── Documents → PDF, DOCX parsing                              │
│                                                                  │
│  OUTPUT MODALITIES:                                             │
│  ├── Text → Standard LLM output                                 │
│  ├── Image → DALL-E, Stable Diffusion, Midjourney               │
│  ├── Audio → Text-to-Speech (ElevenLabs, OpenAI TTS)            │
│  └── Code → Executable code generation                          │
│                                                                  │
│  CROSS-MODAL:                                                   │
│  ├── Image → Text (Description, OCR)                            │
│  ├── Text → Image (Generation)                                  │
│  ├── Audio → Text (Transcription)                               │
│  └── Text → Audio (Speech synthesis)                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Model Capabilities (2025)

| Model | Vision | Audio | Video | Generation |
|-------|--------|-------|-------|------------|
| **GPT-4o** | ✅ | ✅ | Via frames | DALL-E |
| **Claude Sonnet 4** | ✅ | ❌ | Via frames | ❌ |
| **Gemini 1.5** | ✅ | ✅ | ✅ Native | Imagen |
| **Llama 3.2 Vision** | ✅ | ❌ | Via frames | ❌ |

---

## 2. VISION PATTERNS

### 2.1 Image Input

```python
import anthropic
import base64

def encode_image(image_path: str) -> str:
    with open(image_path, "rb") as f:
        return base64.standard_b64encode(f.read()).decode("utf-8")

# Claude Vision
client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    messages=[{
        "role": "user",
        "content": [
            {
                "type": "image",
                "source": {
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": encode_image("photo.jpg")
                }
            },
            {
                "type": "text",
                "text": "Describe what you see in this image."
            }
        ]
    }]
)

# URL-based image
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    messages=[{
        "role": "user",
        "content": [
            {
                "type": "image",
                "source": {
                    "type": "url",
                    "url": "https://example.com/image.jpg"
                }
            },
            {"type": "text", "text": "What's in this image?"}
        ]
    }]
)
```

### 2.2 Vision Use Cases

| Use Case | Prompt Strategy | Example |
|----------|-----------------|---------|
| **Description** | Open-ended | "Describe this image" |
| **OCR/Text** | Specific extraction | "Extract all text from this image" |
| **Object Detection** | Structured output | "List all objects with bounding boxes" |
| **Analysis** | Domain-specific | "Analyze this chart and explain trends" |
| **Comparison** | Multiple images | "Compare these two images" |
| **Code from UI** | Generation | "Generate HTML/CSS for this mockup" |

### 2.3 Multi-Image Processing

```python
# Process multiple images
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    messages=[{
        "role": "user",
        "content": [
            {
                "type": "image",
                "source": {"type": "base64", "media_type": "image/jpeg", "data": img1_b64}
            },
            {
                "type": "image",
                "source": {"type": "base64", "media_type": "image/jpeg", "data": img2_b64}
            },
            {
                "type": "text",
                "text": "Compare these two images and describe the differences."
            }
        ]
    }]
)

# Grid comparison
def create_comparison_prompt(images: List[str], task: str) -> List[dict]:
    content = []
    for i, img in enumerate(images):
        content.append({
            "type": "image",
            "source": {"type": "base64", "media_type": "image/jpeg", "data": img}
        })
    content.append({"type": "text", "text": task})
    return content
```

---

## 3. DOCUMENT UNDERSTANDING

### 3.1 PDF Processing

```python
import fitz  # PyMuPDF
from PIL import Image
import io

class DocumentProcessor:
    def __init__(self, vision_model):
        self.vision = vision_model

    def process_pdf(self, pdf_path: str) -> List[dict]:
        """Extract text and analyze images from PDF"""
        doc = fitz.open(pdf_path)
        results = []

        for page_num, page in enumerate(doc):
            # Extract text
            text = page.get_text()

            # Convert page to image for visual analysis
            pix = page.get_pixmap(matrix=fitz.Matrix(2, 2))  # 2x zoom
            img_bytes = pix.tobytes("png")
            img_b64 = base64.b64encode(img_bytes).decode()

            # Analyze with vision
            analysis = self.vision.analyze(
                image=img_b64,
                prompt="Analyze this document page. Extract key information, tables, and any visual elements."
            )

            results.append({
                "page": page_num + 1,
                "text": text,
                "visual_analysis": analysis
            })

        return results

    def extract_tables(self, pdf_path: str) -> List[dict]:
        """Extract tables using vision"""
        doc = fitz.open(pdf_path)
        tables = []

        for page in doc:
            pix = page.get_pixmap()
            img_b64 = base64.b64encode(pix.tobytes("png")).decode()

            table_data = self.vision.analyze(
                image=img_b64,
                prompt="""Extract all tables from this page.
Return as JSON: [{"headers": [...], "rows": [[...], [...]]}]
If no tables, return []"""
            )

            if table_data:
                tables.extend(json.loads(table_data))

        return tables
```

### 3.2 Invoice/Receipt Processing

```python
class InvoiceExtractor:
    def __init__(self, vision_model):
        self.vision = vision_model

    def extract(self, image_path: str) -> dict:
        prompt = """Extract invoice information from this image.
Return JSON with:
{
  "vendor": "string",
  "invoice_number": "string",
  "date": "YYYY-MM-DD",
  "due_date": "YYYY-MM-DD",
  "line_items": [
    {"description": "string", "quantity": number, "unit_price": number, "total": number}
  ],
  "subtotal": number,
  "tax": number,
  "total": number,
  "currency": "string"
}
Be precise with numbers. If unclear, use null."""

        result = self.vision.analyze(
            image=encode_image(image_path),
            prompt=prompt,
            response_format="json"
        )

        return json.loads(result)
```

---

## 4. AUDIO PATTERNS

### 4.1 Speech-to-Text (Whisper)

```python
from openai import OpenAI

client = OpenAI()

# Transcription
with open("audio.mp3", "rb") as audio_file:
    transcript = client.audio.transcriptions.create(
        model="whisper-1",
        file=audio_file,
        response_format="verbose_json",  # Includes timestamps
        language="fr"  # Optional: specify language
    )

# With timestamps
for segment in transcript.segments:
    print(f"[{segment.start:.2f}s - {segment.end:.2f}s]: {segment.text}")

# Translation (any language → English)
translation = client.audio.translations.create(
    model="whisper-1",
    file=audio_file
)
```

### 4.2 Text-to-Speech

```python
# OpenAI TTS
response = client.audio.speech.create(
    model="tts-1-hd",  # or "tts-1" for faster
    voice="nova",  # alloy, echo, fable, onyx, nova, shimmer
    input="Hello, this is a test of text to speech."
)

# Save to file
with open("output.mp3", "wb") as f:
    f.write(response.content)

# Stream audio
async def stream_speech(text: str):
    response = client.audio.speech.create(
        model="tts-1",
        voice="alloy",
        input=text,
        response_format="opus"  # Good for streaming
    )

    for chunk in response.iter_bytes():
        yield chunk
```

### 4.3 Voice Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    VOICE ASSISTANT PIPELINE                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  USER SPEECH                                                    │
│     ↓                                                           │
│  WHISPER (Speech-to-Text)                                       │
│     ↓                                                           │
│  TEXT TRANSCRIPT                                                │
│     ↓                                                           │
│  LLM (Claude/GPT)                                               │
│     ↓                                                           │
│  TEXT RESPONSE                                                  │
│     ↓                                                           │
│  TTS (Text-to-Speech)                                           │
│     ↓                                                           │
│  AUDIO RESPONSE                                                 │
│                                                                  │
│  Latency target: < 2 seconds total                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. VIDEO PROCESSING

### 5.1 Frame Extraction

```python
import cv2
from typing import List

class VideoProcessor:
    def __init__(self, vision_model, frame_interval: int = 30):
        self.vision = vision_model
        self.frame_interval = frame_interval  # Every Nth frame

    def extract_frames(self, video_path: str) -> List[str]:
        """Extract frames at regular intervals"""
        cap = cv2.VideoCapture(video_path)
        frames = []
        frame_count = 0

        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            if frame_count % self.frame_interval == 0:
                # Convert to base64
                _, buffer = cv2.imencode('.jpg', frame)
                frame_b64 = base64.b64encode(buffer).decode()
                frames.append(frame_b64)

            frame_count += 1

        cap.release()
        return frames

    def analyze_video(self, video_path: str) -> dict:
        """Analyze video content"""
        frames = self.extract_frames(video_path)

        # Sample frames for analysis (max 20)
        if len(frames) > 20:
            indices = np.linspace(0, len(frames)-1, 20, dtype=int)
            frames = [frames[i] for i in indices]

        # Create image grid or analyze individually
        analysis = self.vision.analyze_multiple(
            images=frames,
            prompt="""Analyze this video (shown as frames).
Describe:
1. What's happening in the video
2. Key events or changes
3. Any text or important visual elements
4. Overall context/purpose"""
        )

        return {
            "frame_count": len(frames),
            "analysis": analysis
        }
```

### 5.2 Gemini Native Video

```python
import google.generativeai as genai

# Gemini supports native video input
model = genai.GenerativeModel("gemini-1.5-pro")

video_file = genai.upload_file("video.mp4")

# Wait for processing
while video_file.state.name == "PROCESSING":
    time.sleep(5)
    video_file = genai.get_file(video_file.name)

# Analyze
response = model.generate_content([
    video_file,
    "Summarize this video and identify key moments."
])

print(response.text)
```

---

## 6. IMAGE GENERATION

### 6.1 DALL-E 3

```python
from openai import OpenAI

client = OpenAI()

# Generate image
response = client.images.generate(
    model="dall-e-3",
    prompt="A serene mountain landscape at sunset with a small cabin",
    size="1024x1024",  # 1024x1024, 1792x1024, or 1024x1792
    quality="hd",  # standard or hd
    style="natural",  # natural or vivid
    n=1
)

image_url = response.data[0].url

# Variations
response = client.images.create_variation(
    image=open("original.png", "rb"),
    n=2,
    size="1024x1024"
)

# Edit (inpainting)
response = client.images.edit(
    image=open("image.png", "rb"),
    mask=open("mask.png", "rb"),  # Transparent areas to edit
    prompt="Add a red sports car",
    n=1,
    size="1024x1024"
)
```

### 6.2 Stable Diffusion (Local)

```python
from diffusers import StableDiffusionPipeline
import torch

# Load model
pipe = StableDiffusionPipeline.from_pretrained(
    "stabilityai/stable-diffusion-xl-base-1.0",
    torch_dtype=torch.float16
).to("cuda")

# Generate
image = pipe(
    prompt="A photo of a cat wearing a space helmet",
    negative_prompt="blurry, low quality",
    num_inference_steps=30,
    guidance_scale=7.5
).images[0]

image.save("cat_astronaut.png")
```

### 6.3 Prompt Engineering for Images

```yaml
image_prompt_structure:
  subject: "A majestic lion"
  style: "in the style of National Geographic photography"
  lighting: "golden hour lighting"
  composition: "portrait, centered"
  quality: "8K, highly detailed, sharp focus"
  negative: "cartoon, illustration, drawing, blurry"

combined_prompt: |
  A majestic lion, portrait centered composition,
  in the style of National Geographic photography,
  golden hour lighting, 8K, highly detailed, sharp focus

prompt_tips:
  - Be specific about style and mood
  - Include lighting descriptions
  - Specify composition (portrait, landscape, etc.)
  - Add quality keywords (8K, detailed, etc.)
  - Use negative prompts to avoid unwanted elements
```

---

## 7. MULTIMODAL RAG

### 7.1 Image-Text RAG

```python
class MultimodalRAG:
    def __init__(self, text_embedder, image_embedder, vector_store):
        self.text_embedder = text_embedder
        self.image_embedder = image_embedder  # CLIP
        self.store = vector_store

    def ingest_document(self, doc: Document):
        """Ingest document with text and images"""
        # Extract text chunks
        text_chunks = self.chunk_text(doc.text)
        for chunk in text_chunks:
            embedding = self.text_embedder.embed(chunk)
            self.store.insert({
                "type": "text",
                "content": chunk,
                "embedding": embedding,
                "doc_id": doc.id
            })

        # Extract and embed images
        for img in doc.images:
            embedding = self.image_embedder.embed(img)
            self.store.insert({
                "type": "image",
                "content": img.base64,
                "caption": img.caption,
                "embedding": embedding,
                "doc_id": doc.id
            })

    def query(self, query: str, include_images: bool = True) -> List[dict]:
        """Query with text, retrieve text and images"""
        query_embedding = self.text_embedder.embed(query)

        # Search text chunks
        text_results = self.store.search(
            query_embedding,
            filter={"type": "text"},
            top_k=5
        )

        results = text_results

        if include_images:
            # Also search images
            image_results = self.store.search(
                query_embedding,
                filter={"type": "image"},
                top_k=3
            )
            results.extend(image_results)

        return results
```

### 7.2 Document Q&A with Vision

```python
async def document_qa(question: str, pdf_path: str) -> str:
    """Answer questions about a document using vision"""
    # Convert PDF pages to images
    pages = pdf_to_images(pdf_path)

    # Find relevant pages
    relevant_pages = await find_relevant_pages(question, pages)

    # Query vision model with relevant pages
    response = await vision_model.analyze(
        images=relevant_pages,
        prompt=f"""Based on these document pages, answer this question:
{question}

Cite specific sections or figures when relevant.
If the answer isn't in the document, say so."""
    )

    return response
```

---

## 8. HARMONY INTEGRATION

### 8.1 Multimodal Story Validation

```yaml
harmony_multimodal:
  ucv_validation:
    screenshot_verification:
      enabled: true
      capture_tool: playwright
      compare_with_mockups: true

    visual_regression:
      enabled: true
      threshold: 0.95
      report_format: html

  exploratory_qa:
    screenshot_analysis:
      enabled: true
      model: claude-vision
      checks:
        - layout_consistency
        - text_readability
        - color_contrast

  document_parsing:
    supported_formats:
      - pdf
      - docx
      - images
    use_vision_for_complex: true
```

---

## 9. ANTI-PATTERNS

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **No image optimization** | Slow, expensive | Resize before sending |
| **Single frame for video** | Miss content | Sample multiple frames |
| **Ignore OCR quality** | Errors in text | Use vision for verification |
| **No error handling** | Modality failures | Fallback strategies |
| **Wrong modality** | Inefficient | Match task to modality |
| **No caching** | Repeat processing | Cache embeddings/results |

---

## 10. DECISION CHECKLIST

```yaml
multimodal_decisions:
  - question: "What input modalities?"
    text_only: "Standard LLM"
    with_images: "Vision model (Claude Vision, GPT-4V)"
    with_audio: "Whisper + LLM"
    with_video: "Frame extraction + Vision"

  - question: "Need image generation?"
    simple: "DALL-E 3"
    complex_control: "Stable Diffusion + ControlNet"
    fast_iteration: "Midjourney"

  - question: "Voice interface?"
    yes: "Whisper (STT) + LLM + TTS (ElevenLabs/OpenAI)"
    real_time: "Consider dedicated voice API"
```

---

**Multimodal Expert**
*"The best AI sees, hears, and understands."*
