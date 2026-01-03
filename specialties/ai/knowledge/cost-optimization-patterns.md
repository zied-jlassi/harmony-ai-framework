---
name: "cost-optimization-patterns"
displayName: "Cost Optimization Patterns"
emoji: "💰"
description: "LLM Cost Optimization patterns: LLM Routing, Semantic Caching, Token Reduction, Model Selection. 15+ sources analyzed."
argument-hint: [cost-topic]
version: "1.0"
tier: 2
model: inherit
parent: ai-architect
phase: 3
category: sub-agent
---

# 💰 Cost Optimization Patterns : Expert en optimisation des couts LLM. Je conçois les strategies de routing et caching.

## Role: Cost Optimization Expert

> **Specialization**: LLM Cost Optimization, Routing, Caching, Token Reduction
> **Parent Agent**: AI Architect
> **Sources**: 15+ sources from research 2025

---

## 1. COST OPTIMIZATION LANDSCAPE

### 1.1 Cost Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    LLM COST BREAKDOWN                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  TOKEN COSTS (Primary):                                         │
│  ├── Input tokens (context, prompts)                            │
│  ├── Output tokens (completions)                                │
│  └── Cached tokens (if applicable)                              │
│                                                                  │
│  INFRASTRUCTURE COSTS:                                          │
│  ├── API gateway                                                │
│  ├── Caching layer                                              │
│  ├── Vector database                                            │
│  └── Compute for pre/post-processing                            │
│                                                                  │
│  HIDDEN COSTS:                                                  │
│  ├── Retries on failures                                        │
│  ├── Streaming overhead                                         │
│  ├── Logging and monitoring                                     │
│  └── Development and testing                                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Model Pricing (2025)

| Model | Input $/1M | Output $/1M | Speed | Quality |
|-------|------------|-------------|-------|---------|
| **GPT-4o** | $2.50 | $10.00 | Fast | High |
| **GPT-4o-mini** | $0.15 | $0.60 | Faster | Good |
| **Claude Opus 4** | $15.00 | $75.00 | Fast | Highest |
| **Claude Sonnet 4** | $3.00 | $15.00 | Fast | High |
| **Claude Haiku** | $0.25 | $1.25 | Fastest | Good |
| **Gemini 1.5 Pro** | $1.25 | $5.00 | Fast | High |
| **Gemini 1.5 Flash** | $0.075 | $0.30 | Fastest | Good |
| **Llama 3.1 70B** | ~$0.30 | ~$0.30 | Medium | Good |

---

## 2. LLM ROUTING

### 2.1 Router Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    LLM ROUTER                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  REQUEST                                                        │
│     ↓                                                           │
│  CLASSIFIER                                                     │
│  ├── Complexity analysis                                        │
│  ├── Task type detection                                        │
│  └── Quality requirements                                       │
│     ↓                                                           │
│  ROUTING DECISION                                               │
│  ├── Simple → Small model (Haiku, GPT-4o-mini)                  │
│  ├── Complex → Large model (Opus, GPT-4o)                       │
│  └── Specialized → Domain model                                 │
│     ↓                                                           │
│  RESPONSE                                                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Classifier-Based Routing

```python
class LLMRouter:
    def __init__(self, models: Dict[str, LLMClient]):
        self.models = models
        self.classifier = ComplexityClassifier()

    async def route(self, prompt: str, context: dict = None) -> str:
        # Classify complexity
        complexity = self.classifier.classify(prompt)

        # Select model based on complexity
        if complexity == "simple":
            model = self.models["haiku"]  # $0.25/1M
            quality_threshold = 0.8
        elif complexity == "medium":
            model = self.models["sonnet"]  # $3/1M
            quality_threshold = 0.9
        else:  # complex
            model = self.models["opus"]  # $15/1M
            quality_threshold = 0.95

        # Generate response
        response = await model.generate(prompt)

        # Optional: Verify quality, upgrade if needed
        if await self._check_quality(response) < quality_threshold:
            return await self._upgrade_model(prompt, model)

        return response

    def _classify_complexity(self, prompt: str) -> str:
        """Fast classification with small model or heuristics"""
        # Heuristics
        if len(prompt) < 100 and "simple" in prompt.lower():
            return "simple"

        # Or use a small classifier model
        return self.classifier.predict(prompt)
```

### 2.3 Semantic Router

```python
from semantic_router import Route, SemanticRouter
from semantic_router.encoders import OpenAIEncoder

# Define routes
routes = [
    Route(
        name="simple_qa",
        utterances=[
            "What is the capital of France?",
            "How many days in a week?",
            "Define photosynthesis"
        ],
        model="gpt-4o-mini"
    ),
    Route(
        name="code_generation",
        utterances=[
            "Write a function to sort a list",
            "Create a REST API endpoint",
            "Implement binary search"
        ],
        model="claude-sonnet"
    ),
    Route(
        name="complex_reasoning",
        utterances=[
            "Analyze the pros and cons of...",
            "Design a system architecture for...",
            "Explain the implications of..."
        ],
        model="claude-opus"
    )
]

router = SemanticRouter(
    encoder=OpenAIEncoder(),
    routes=routes
)

# Route request
result = router(prompt)
selected_model = result.name  # or result.model
```

---

## 3. SEMANTIC CACHING

### 3.1 Cache Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SEMANTIC CACHE                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  QUERY: "What's the weather in Paris?"                          │
│     ↓                                                           │
│  EMBED QUERY                                                    │
│     ↓                                                           │
│  SIMILARITY SEARCH (Vector DB)                                  │
│  ├── "What is Paris weather?" → 0.98 similarity                │
│  └── Threshold: 0.95                                            │
│     ↓                                                           │
│  CACHE HIT → Return cached response                             │
│     OR                                                          │
│  CACHE MISS → Query LLM → Store in cache                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 GPTCache Implementation

```python
from gptcache import cache
from gptcache.adapter import openai as gptcache_openai
from gptcache.embedding import Onnx
from gptcache.manager import CacheBase, VectorBase
from gptcache.similarity_evaluation import OnnxModelEvaluation

# Initialize cache
cache.init(
    embedding_func=Onnx(),
    data_manager=CacheBase("sqlite"),
    vector_data=VectorBase("faiss", dimension=768),
    similarity_evaluation=OnnxModelEvaluation(),
    similarity_threshold=0.95
)

# Use cached OpenAI
response = gptcache_openai.ChatCompletion.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "What is the capital of France?"}]
)

# Cache stats
print(f"Cache hit rate: {cache.report['hit_rate']:.2%}")
print(f"Tokens saved: {cache.report['tokens_saved']}")
```

### 3.3 Custom Semantic Cache

```python
import hashlib
import numpy as np
from typing import Optional

class SemanticCache:
    def __init__(
        self,
        embedding_model,
        vector_store,
        similarity_threshold: float = 0.95,
        ttl_seconds: int = 3600
    ):
        self.embedder = embedding_model
        self.store = vector_store
        self.threshold = similarity_threshold
        self.ttl = ttl_seconds

    async def get(self, query: str) -> Optional[str]:
        # Embed query
        query_embedding = await self.embedder.embed(query)

        # Search for similar cached queries
        results = await self.store.search(
            query_embedding,
            top_k=1,
            threshold=self.threshold
        )

        if results and not self._is_expired(results[0]):
            return results[0].response

        return None

    async def set(self, query: str, response: str):
        query_embedding = await self.embedder.embed(query)

        await self.store.insert({
            "id": self._hash(query),
            "embedding": query_embedding,
            "query": query,
            "response": response,
            "timestamp": time.time()
        })

    def _is_expired(self, entry) -> bool:
        return time.time() - entry.timestamp > self.ttl

    def _hash(self, query: str) -> str:
        return hashlib.sha256(query.encode()).hexdigest()
```

---

## 4. TOKEN OPTIMIZATION

### 4.1 Prompt Compression

```python
class PromptCompressor:
    """Reduce prompt size while preserving meaning"""

    def __init__(self, compressor_model="gpt-4o-mini"):
        self.compressor = LLM(model=compressor_model)

    async def compress(self, long_context: str, target_tokens: int) -> str:
        prompt = f"""Compress this text to approximately {target_tokens} tokens.
Preserve all key information, facts, and meaning.
Remove redundancy and verbose language.

Text to compress:
{long_context}

Compressed version:"""

        return await self.compressor.generate(prompt)

    def extractive_compress(self, text: str, ratio: float = 0.5) -> str:
        """Extract most important sentences"""
        sentences = self._split_sentences(text)
        scores = self._score_sentences(sentences)

        # Keep top sentences by score
        n_keep = int(len(sentences) * ratio)
        top_indices = np.argsort(scores)[-n_keep:]
        top_indices = sorted(top_indices)  # Preserve order

        return " ".join([sentences[i] for i in top_indices])
```

### 4.2 Context Window Management

```python
class ContextManager:
    """Manage context window efficiently"""

    def __init__(self, max_tokens: int = 128000):
        self.max_tokens = max_tokens
        self.reserved_output = 4096

    def prepare_context(
        self,
        system_prompt: str,
        conversation: List[Message],
        documents: List[str]
    ) -> List[Message]:
        available = self.max_tokens - self.reserved_output

        # Priority 1: System prompt (required)
        system_tokens = self._count_tokens(system_prompt)
        available -= system_tokens

        # Priority 2: Recent conversation (most important)
        conversation_tokens = sum(
            self._count_tokens(m.content) for m in conversation[-10:]
        )
        available -= conversation_tokens

        # Priority 3: Documents (compress if needed)
        doc_tokens = sum(self._count_tokens(d) for d in documents)

        if doc_tokens > available:
            # Compress or truncate documents
            documents = self._fit_documents(documents, available)

        return self._build_messages(system_prompt, conversation, documents)

    def _fit_documents(self, docs: List[str], max_tokens: int) -> List[str]:
        fitted = []
        remaining = max_tokens

        for doc in docs:
            doc_tokens = self._count_tokens(doc)
            if doc_tokens <= remaining:
                fitted.append(doc)
                remaining -= doc_tokens
            elif remaining > 500:  # Min useful size
                # Truncate to fit
                truncated = self._truncate_to_tokens(doc, remaining)
                fitted.append(truncated)
                break

        return fitted
```

### 4.3 Output Token Control

```python
# Control output length
response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages,
    max_tokens=500,  # Limit output
    temperature=0.7,
    stop=["\n\n", "END"]  # Stop sequences
)

# Structured output (more predictable token count)
response = client.chat.completions.create(
    model="gpt-4o",
    messages=messages,
    response_format={"type": "json_object"}
)
```

---

## 5. BATCH PROCESSING

### 5.1 Batch API Usage

```python
# OpenAI Batch API (50% cheaper)
import openai

# Create batch file
batch_requests = [
    {
        "custom_id": f"request-{i}",
        "method": "POST",
        "url": "/v1/chat/completions",
        "body": {
            "model": "gpt-4o-mini",
            "messages": [{"role": "user", "content": prompt}]
        }
    }
    for i, prompt in enumerate(prompts)
]

# Upload batch file
with open("batch_requests.jsonl", "w") as f:
    for req in batch_requests:
        f.write(json.dumps(req) + "\n")

batch_file = client.files.create(
    file=open("batch_requests.jsonl", "rb"),
    purpose="batch"
)

# Create batch job
batch_job = client.batches.create(
    input_file_id=batch_file.id,
    endpoint="/v1/chat/completions",
    completion_window="24h"  # Allows up to 24h processing
)

# Check status
status = client.batches.retrieve(batch_job.id)
```

### 5.2 Request Batching

```python
class RequestBatcher:
    """Batch similar requests to reduce overhead"""

    def __init__(self, batch_size: int = 10, max_wait_ms: int = 100):
        self.batch_size = batch_size
        self.max_wait = max_wait_ms / 1000
        self.pending = []
        self.lock = asyncio.Lock()

    async def add_request(self, request: LLMRequest) -> LLMResponse:
        future = asyncio.Future()

        async with self.lock:
            self.pending.append((request, future))

            if len(self.pending) >= self.batch_size:
                await self._process_batch()

        # Wait for result or timeout trigger
        return await asyncio.wait_for(future, timeout=30)

    async def _process_batch(self):
        if not self.pending:
            return

        batch = self.pending[:self.batch_size]
        self.pending = self.pending[self.batch_size:]

        # Process batch
        requests = [r for r, _ in batch]
        responses = await self._batch_call(requests)

        # Resolve futures
        for (_, future), response in zip(batch, responses):
            future.set_result(response)
```

---

## 6. MODEL CASCADING

### 6.1 Cascade Strategy

```
┌─────────────────────────────────────────────────────────────────┐
│                    MODEL CASCADE                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  TIER 1: Smallest Model (Haiku, GPT-4o-mini)                    │
│  ├── Try first for all requests                                 │
│  ├── Cost: $0.15-0.25/1M tokens                                 │
│  └── If confidence < threshold → Tier 2                         │
│                                                                  │
│  TIER 2: Medium Model (Sonnet, GPT-4o)                          │
│  ├── Handle medium complexity                                   │
│  ├── Cost: $2.50-3.00/1M tokens                                 │
│  └── If still failing → Tier 3                                  │
│                                                                  │
│  TIER 3: Largest Model (Opus)                                   │
│  ├── Last resort for complex tasks                              │
│  └── Cost: $15/1M tokens                                        │
│                                                                  │
│  RESULT: 70-80% handled by Tier 1                               │
│          Massive cost savings                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 6.2 Cascade Implementation

```python
class ModelCascade:
    def __init__(self):
        self.tiers = [
            {"model": "claude-3-haiku", "threshold": 0.85, "cost": 0.25},
            {"model": "claude-sonnet-4", "threshold": 0.95, "cost": 3.00},
            {"model": "claude-opus-4", "threshold": 1.0, "cost": 15.00},
        ]

    async def generate(self, prompt: str) -> CascadeResult:
        for i, tier in enumerate(self.tiers):
            response = await self._call_model(tier["model"], prompt)
            confidence = await self._evaluate_confidence(response)

            if confidence >= tier["threshold"]:
                return CascadeResult(
                    response=response,
                    tier_used=i + 1,
                    model=tier["model"],
                    confidence=confidence
                )

        # Fallback to last tier result
        return CascadeResult(
            response=response,
            tier_used=len(self.tiers),
            model=self.tiers[-1]["model"],
            confidence=confidence
        )

    async def _evaluate_confidence(self, response: str) -> float:
        """Evaluate response quality/confidence"""
        # Use a small model to judge
        judge_prompt = f"""Rate the quality of this response from 0-1:
Response: {response}
Score:"""
        score = await self._call_model("gpt-4o-mini", judge_prompt)
        return float(score.strip())
```

---

## 7. COST MONITORING

### 7.1 Cost Tracking

```python
class CostTracker:
    def __init__(self):
        self.costs = defaultdict(float)
        self.tokens = defaultdict(int)

    def record(
        self,
        model: str,
        input_tokens: int,
        output_tokens: int,
        user_id: str = None
    ):
        pricing = MODEL_PRICING[model]
        cost = (
            input_tokens * pricing["input"] / 1_000_000 +
            output_tokens * pricing["output"] / 1_000_000
        )

        self.costs[model] += cost
        self.tokens[model] += input_tokens + output_tokens

        if user_id:
            self.costs[f"user:{user_id}"] += cost

        # Alert on high costs
        self._check_alerts(cost, user_id)

    def get_daily_report(self) -> dict:
        return {
            "total_cost": sum(self.costs.values()),
            "by_model": dict(self.costs),
            "total_tokens": sum(self.tokens.values()),
            "avg_cost_per_request": self._calc_avg(),
            "top_users": self._get_top_users()
        }

    def _check_alerts(self, cost: float, user_id: str):
        if self.costs[f"user:{user_id}"] > 10:  # $10 limit
            send_alert(f"User {user_id} exceeded cost limit")
```

### 7.2 Cost Dashboard Metrics

```yaml
cost_metrics:
  real_time:
    - cost_per_minute
    - tokens_per_minute
    - cache_hit_rate
    - cascade_tier_distribution

  daily:
    - total_cost
    - cost_by_model
    - cost_by_user
    - cost_by_feature
    - savings_from_caching
    - savings_from_routing

  alerts:
    - cost_spike (>2x normal)
    - user_limit_exceeded
    - cache_miss_spike
    - model_error_rate
```

---

## 8. HARMONY INTEGRATION

### 8.1 Cost-Aware Agent Routing

```yaml
harmony_cost_optimization:
  guardian:
    routing_strategy: cascade
    tiers:
      - intent_detection: haiku  # Fast, cheap
      - complex_routing: sonnet  # When needed

  agents:
    developer:
      default: sonnet
      code_review: opus  # Worth the cost

    analyst:
      default: haiku
      complex_analysis: sonnet

  caching:
    enabled: true
    ttl: 3600
    similarity_threshold: 0.95
```

---

## 9. ANTI-PATTERNS

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **Always use biggest model** | 10-50x higher cost | Model routing |
| **No caching** | Repeated work | Semantic cache |
| **Unbounded output** | Token waste | max_tokens limit |
| **No monitoring** | Cost surprises | Real-time tracking |
| **Retry without backoff** | Multiplied costs | Exponential backoff |
| **Large system prompts** | Input token waste | Prompt compression |

---

**Cost Optimization Expert**
*"Every token saved is money earned."*
