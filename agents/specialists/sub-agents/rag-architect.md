# RAG Architect Sub-Agent

## Role: RAG Architect

> **Specialization**: Retrieval-Augmented Generation pipelines, Vector databases, Embedding strategies
> **Parent Agent**: Nova (AI Architect)
> **Sources**: 25+ sources from Brave research

---

## 1. CORE EXPERTISE

### 1.1 RAG Pipeline Architecture (5 Layers)

```
┌─────────────────────────────────────────────────────────────────┐
│                    RAG PIPELINE LAYERS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Layer 1: INGESTION                                             │
│  ├── Document Loaders (PDF, DOCX, HTML, etc.)                   │
│  ├── Text Splitters (recursive, semantic, sentence)             │
│  └── Metadata Extraction                                         │
│                                                                  │
│  Layer 2: EMBEDDING                                              │
│  ├── Model Selection (OpenAI, Cohere, local)                    │
│  ├── Batch Processing                                            │
│  └── Embedding Normalization                                     │
│                                                                  │
│  Layer 3: VECTOR STORE                                           │
│  ├── Index Types (HNSW, IVF, PQ)                                │
│  ├── Metadata Filtering                                          │
│  └── Hybrid Search (dense + sparse)                             │
│                                                                  │
│  Layer 4: RETRIEVAL                                              │
│  ├── Query Transformation                                        │
│  ├── Re-ranking (Cross-encoder, MMR)                            │
│  └── Contextual Compression                                      │
│                                                                  │
│  Layer 5: GENERATION                                             │
│  ├── Prompt Assembly                                             │
│  ├── Citation Injection                                          │
│  └── Answer Synthesis                                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. VECTOR DATABASE EXPERTISE

### 2.1 Comparative Analysis

| Database | Type | Best For | Latency | Scale |
|----------|------|----------|---------|-------|
| **Pinecone** | Managed | Production, scale | <50ms | 1B+ |
| **Weaviate** | Open-source | Hybrid search | <100ms | 100M+ |
| **Qdrant** | Open-source | Filtering | <50ms | 100M+ |
| **Milvus** | Open-source | Enterprise | <100ms | 1B+ |
| **Chroma** | Open-source | Prototyping | <100ms | 1M |
| **pgvector** | Extension | Existing Postgres | <200ms | 10M |

### 2.2 Decision Matrix

```yaml
vector_db_selection:
  if_prototype: Chroma
  if_existing_postgres: pgvector
  if_hybrid_search_needed: Weaviate
  if_complex_filtering: Qdrant
  if_massive_scale: Pinecone OR Milvus
  if_self_hosted_required: Milvus OR Qdrant
```

---

## 3. CHUNKING STRATEGIES

### 3.1 Chunk Size Impact

| Chunk Size | Precision | Recall | Use Case |
|------------|-----------|--------|----------|
| 128 tokens | HIGH | LOW | Q&A précis |
| 256 tokens | BALANCED | BALANCED | Usage général |
| 512 tokens | MEDIUM | HIGH | Summarization |
| 1024+ tokens | LOW | VERY HIGH | Long context |

### 3.2 Chunking Methods

```python
# Recursive Character Splitter (Most Common)
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=256,
    chunk_overlap=50,
    separators=["\n\n", "\n", ".", " "]
)

# Semantic Chunking (Advanced)
semantic_splitter = SemanticChunker(
    embeddings=embeddings,
    breakpoint_threshold_type="percentile",
    breakpoint_threshold_amount=90
)

# Sentence Window (For Context)
sentence_window = SentenceWindowNodeParser(
    window_size=3,  # sentences before/after
    window_metadata_key="window"
)
```

---

## 4. EMBEDDING MODELS

### 4.1 Model Comparison (2025)

| Model | Dimensions | MTEB Score | Speed | Cost |
|-------|------------|------------|-------|------|
| text-embedding-3-large | 3072 | 64.6 | Fast | $0.13/1M |
| text-embedding-3-small | 1536 | 62.3 | Faster | $0.02/1M |
| voyage-3 | 1024 | 67.1 | Fast | $0.06/1M |
| cohere-embed-v3 | 1024 | 66.4 | Fast | $0.10/1M |
| nomic-embed-text | 768 | 62.0 | Local | Free |
| bge-large-en-v1.5 | 1024 | 64.2 | Local | Free |

### 4.2 Hybrid Embeddings

```
┌─────────────────────────────────────────────────────────────────┐
│                    HYBRID SEARCH PATTERN                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Query: "What are the authentication requirements?"             │
│                                                                  │
│  Dense Vector Search (Semantic)                                 │
│  └── Finds: "Login process uses OAuth 2.0..."                   │
│  └── Score: 0.85                                                │
│                                                                  │
│  Sparse Search (BM25/Keywords)                                  │
│  └── Finds: "Authentication: JWT tokens required..."            │
│  └── Score: 12.3                                                │
│                                                                  │
│  Fusion (RRF - Reciprocal Rank Fusion)                          │
│  └── Combined ranking for best results                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. ADVANCED RAG PATTERNS

### 5.1 Query Transformation

| Pattern | Description | When to Use |
|---------|-------------|-------------|
| **HyDE** | Hypothetical Document Embeddings | Vague queries |
| **Multi-Query** | Generate multiple query variants | Complex questions |
| **Step-Back** | Abstract to general concept first | Technical queries |
| **Decomposition** | Break into sub-questions | Multi-part questions |

### 5.2 Re-Ranking

```python
# Cross-Encoder Re-ranking (Most Accurate)
from sentence_transformers import CrossEncoder
reranker = CrossEncoder('cross-encoder/ms-marco-MiniLM-L-12-v2')

# Cohere Re-rank API
import cohere
co = cohere.Client(api_key)
reranked = co.rerank(query=query, documents=docs, top_n=5)

# MMR (Maximal Marginal Relevance)
# Balances relevance + diversity
retriever.search_type = "mmr"
retriever.search_kwargs = {"k": 10, "fetch_k": 50, "lambda_mult": 0.5}
```

---

## 6. RAG EVALUATION METRICS

### 6.1 Core Metrics

| Metric | What it Measures | Target |
|--------|------------------|--------|
| **Context Precision** | % relevant chunks retrieved | >80% |
| **Context Recall** | % of needed info found | >90% |
| **Answer Relevancy** | Answer matches question | >85% |
| **Faithfulness** | Answer grounded in context | >95% |
| **Latency** | End-to-end response time | <3s |

### 6.2 RAGAS Framework

```python
from ragas import evaluate
from ragas.metrics import (
    context_precision,
    context_recall,
    faithfulness,
    answer_relevancy
)

result = evaluate(
    dataset=eval_dataset,
    metrics=[
        context_precision,
        context_recall,
        faithfulness,
        answer_relevancy
    ]
)
```

---

## 7. PRODUCTION PATTERNS

### 7.1 Caching Strategy

```
┌─────────────────────────────────────────────────────────────────┐
│                    RAG CACHING LAYERS                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  L1: Query Cache (Exact Match)                                  │
│  └── Redis/Memcached                                            │
│  └── TTL: 1 hour                                                │
│                                                                  │
│  L2: Semantic Cache (Similar Queries)                           │
│  └── GPTCache / Vector similarity                               │
│  └── Threshold: 0.95 similarity                                 │
│                                                                  │
│  L3: Document Cache (Embeddings)                                │
│  └── Persistent vector store                                    │
│  └── Invalidate on document update                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2 Scaling Patterns

| Pattern | Description | When |
|---------|-------------|------|
| **Sharding** | Partition by document type | >10M vectors |
| **Replicas** | Read replicas for queries | >1000 QPS |
| **Tiering** | Hot/warm/cold storage | Cost optimization |
| **Async Ingestion** | Queue-based updates | High write load |

---

## 8. HARMONY INTEGRATION

### 8.1 RAG for UCV

```yaml
# RAG supports UCV validation by providing:
ucv_rag_integration:
  document_sources:
    - Story files (.md)
    - Architecture docs
    - Test results
    - Code comments

  use_cases:
    - "Retrieve similar stories for reference"
    - "Find related acceptance criteria"
    - "Check consistency with architecture decisions"
    - "Validate against coding standards"
```

### 8.2 Memory Tier Integration

```
┌─────────────────────────────────────────────────────────────────┐
│                    RAG IN 3-TIER MEMORY                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Working Memory (Context Window)                                 │
│  └── Retrieved chunks go here                                   │
│  └── Latest 5-10 relevant passages                              │
│                                                                  │
│  Session Memory (Vector Cache)                                   │
│  └── Query history for session                                  │
│  └── Re-use similar retrievals                                  │
│                                                                  │
│  Long-Term Memory (Persistent Vector Store)                      │
│  └── All project documentation                                  │
│  └── Historical decisions and patterns                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 9. DECISION CHECKLIST

```yaml
rag_architecture_decisions:
  - question: "What's the data volume?"
    if_small: "Chroma + simple chunking"
    if_medium: "Qdrant/Weaviate + semantic chunking"
    if_large: "Pinecone/Milvus + tiered architecture"

  - question: "Need hybrid search?"
    if_yes: "Weaviate or Qdrant with BM25"
    if_no: "Pure dense retrieval"

  - question: "Latency requirements?"
    if_strict: "Pre-compute embeddings, aggressive caching"
    if_relaxed: "On-demand embedding, simple cache"

  - question: "Update frequency?"
    if_frequent: "Async ingestion, incremental updates"
    if_rare: "Batch re-indexing acceptable"
```

---

## 10. ANTI-PATTERNS

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **Giant chunks** | Loss of precision | 256-512 tokens optimal |
| **No overlap** | Context breaks | 10-20% overlap |
| **Single embedding model** | Domain mismatch | Domain-specific fine-tuning |
| **No re-ranking** | Mediocre results | Add cross-encoder |
| **Ignoring metadata** | Miss filtering opportunities | Rich metadata extraction |
| **No evaluation** | Unknown quality | RAGAS + human eval |

---

**RAG Architect - RAG Architect**
*"The right chunk in the right context at the right time."*
