---
name: rag-implementation
displayName: "RAG Implementation"
category: llm-application-dev
tier: 2
model: inherit
triggers:
  - "RAG"
  - "retrieval augmented"
  - "vector search"
  - "document retrieval"
  - "knowledge base"
---

# RAG Implementation

> Build Retrieval-Augmented Generation systems for knowledge-grounded LLM applications.

## RAG Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      RAG PIPELINE                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INDEXING                                                        │
│  Documents → Chunking → Embedding → Vector Store                 │
│                                                                  │
│  RETRIEVAL                                                       │
│  Query → Embed Query → Similarity Search → Top-K Documents       │
│                                                                  │
│  GENERATION                                                      │
│  Query + Retrieved Docs → LLM → Grounded Response                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Document Processing

### Chunking Strategies

```python
from langchain_text_splitters import (
    RecursiveCharacterTextSplitter,
    MarkdownHeaderTextSplitter,
    TokenTextSplitter
)

# 1. Recursive Character Splitter (default choice)
splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    separators=["\n\n", "\n", " ", ""]
)

# 2. Markdown-aware splitting
md_splitter = MarkdownHeaderTextSplitter(
    headers_to_split_on=[
        ("#", "Header 1"),
        ("##", "Header 2"),
        ("###", "Header 3"),
    ]
)

# 3. Token-based splitting (for token limits)
token_splitter = TokenTextSplitter(
    chunk_size=500,
    chunk_overlap=50,
    encoding_name="cl100k_base"  # For OpenAI models
)

# Combine: first by headers, then by size
docs = md_splitter.split_text(document)
final_chunks = []
for doc in docs:
    if len(doc.page_content) > 1000:
        final_chunks.extend(splitter.split_documents([doc]))
    else:
        final_chunks.append(doc)
```

### Metadata Enrichment

```python
from datetime import datetime

def enrich_chunks(chunks, source_doc):
    """Add metadata to chunks for better retrieval."""
    enriched = []
    for i, chunk in enumerate(chunks):
        chunk.metadata.update({
            "source": source_doc.name,
            "chunk_index": i,
            "total_chunks": len(chunks),
            "created_at": datetime.now().isoformat(),
            "doc_type": source_doc.type,
            # Semantic metadata
            "section": extract_section(chunk),
            "entities": extract_entities(chunk),
        })
        enriched.append(chunk)
    return enriched
```

## Vector Store Setup

```python
from langchain_community.vectorstores import Chroma, Pinecone, Weaviate
from langchain_openai import OpenAIEmbeddings

# Initialize embeddings
embeddings = OpenAIEmbeddings(model="text-embedding-3-small")

# Option 1: Chroma (local, simple)
vectorstore = Chroma.from_documents(
    documents=chunks,
    embedding=embeddings,
    persist_directory="./chroma_db"
)

# Option 2: Pinecone (cloud, scalable)
import pinecone
pinecone.init(api_key="...", environment="...")

vectorstore = Pinecone.from_documents(
    documents=chunks,
    embedding=embeddings,
    index_name="my-index"
)

# Option 3: pgvector (PostgreSQL)
from langchain_community.vectorstores import PGVector

vectorstore = PGVector.from_documents(
    documents=chunks,
    embedding=embeddings,
    connection_string="postgresql://...",
    collection_name="documents"
)
```

## Retrieval Strategies

### Basic Retrieval
```python
# Simple similarity search
retriever = vectorstore.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 4}
)

# MMR (Maximum Marginal Relevance) - diverse results
retriever = vectorstore.as_retriever(
    search_type="mmr",
    search_kwargs={
        "k": 4,
        "fetch_k": 20,  # Fetch more, then diversify
        "lambda_mult": 0.5  # Balance relevance vs diversity
    }
)

# Similarity with score threshold
retriever = vectorstore.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={
        "score_threshold": 0.7,
        "k": 10
    }
)
```

### Multi-Query Retrieval
```python
from langchain.retrievers import MultiQueryRetriever

# Generate multiple query variations
multi_retriever = MultiQueryRetriever.from_llm(
    retriever=base_retriever,
    llm=llm
)

# Query: "What are the benefits of exercise?"
# Generated queries:
# 1. "How does physical activity improve health?"
# 2. "What are the advantages of working out?"
# 3. "Why is exercise good for you?"
```

### Contextual Compression
```python
from langchain.retrievers import ContextualCompressionRetriever
from langchain.retrievers.document_compressors import LLMChainExtractor

# Extract only relevant parts of documents
compressor = LLMChainExtractor.from_llm(llm)

compression_retriever = ContextualCompressionRetriever(
    base_compressor=compressor,
    base_retriever=base_retriever
)
```

### Ensemble Retrieval
```python
from langchain.retrievers import EnsembleRetriever
from langchain_community.retrievers import BM25Retriever

# Combine vector search with keyword search
bm25_retriever = BM25Retriever.from_documents(documents)
bm25_retriever.k = 4

vector_retriever = vectorstore.as_retriever(search_kwargs={"k": 4})

# Ensemble with weights
ensemble = EnsembleRetriever(
    retrievers=[bm25_retriever, vector_retriever],
    weights=[0.3, 0.7]  # Favor semantic search
)
```

## RAG Chain

```python
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_core.output_parsers import StrOutputParser

# RAG prompt with source citation
rag_prompt = ChatPromptTemplate.from_template("""
You are an assistant that answers questions based on the provided context.

Context:
{context}

Question: {question}

Instructions:
- Answer based ONLY on the provided context
- If the context doesn't contain the answer, say "I don't have enough information"
- Cite sources using [Source: filename] format

Answer:
""")

def format_docs_with_sources(docs):
    formatted = []
    for doc in docs:
        source = doc.metadata.get("source", "Unknown")
        formatted.append(f"[Source: {source}]\n{doc.page_content}")
    return "\n\n---\n\n".join(formatted)

# Build chain
rag_chain = (
    {
        "context": retriever | format_docs_with_sources,
        "question": RunnablePassthrough()
    }
    | rag_prompt
    | llm
    | StrOutputParser()
)

# Query
answer = rag_chain.invoke("What is the refund policy?")
```

## Evaluation

```python
from ragas import evaluate
from ragas.metrics import (
    faithfulness,
    answer_relevancy,
    context_precision,
    context_recall
)

# Prepare evaluation dataset
eval_dataset = {
    "question": ["What is...?", "How to...?"],
    "answer": ["The answer is...", "You can..."],
    "contexts": [["Context 1", "Context 2"], ["Context 3"]],
    "ground_truth": ["Expected answer 1", "Expected answer 2"]
}

# Run evaluation
result = evaluate(
    eval_dataset,
    metrics=[
        faithfulness,      # Is answer grounded in context?
        answer_relevancy,  # Is answer relevant to question?
        context_precision, # Are retrieved docs relevant?
        context_recall     # Did we retrieve all needed info?
    ]
)

print(result)
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Chunk wisely** | 500-1000 tokens, overlap 10-20% |
| **Enrich metadata** | Source, date, section, entities |
| **Hybrid search** | Combine vector + keyword |
| **Rerank results** | Use cross-encoder for precision |
| **Handle no results** | Graceful fallback messages |
| **Cite sources** | Traceability and trust |
| **Evaluate regularly** | Track retrieval quality |
| **Update index** | Keep knowledge current |
