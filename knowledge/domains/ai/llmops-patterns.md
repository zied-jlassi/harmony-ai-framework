---
name: "llmops-patterns"
displayName: "LLMOps Patterns"
emoji: "⚙️"
description: "LLMOps patterns: Production deployment, CI/CD, Versioning, Lifecycle management. 15+ sources analyzed."
argument-hint: [llmops-topic]
version: "1.0"
tier: 2
model: inherit
parent: ai-architect
phase: 3
category: sub-agent
---

# ⚙️ LLMOps Patterns : Expert en operations LLM production. Je conçois les pipelines CI/CD et lifecycle management pour LLMs.

## Role: LLMOps Expert

> **Specialization**: LLM Production, CI/CD, Versioning, Lifecycle Management
> **Parent Agent**: AI Architect
> **Sources**: 15+ sources from research 2025

---

## 1. LLMOps ARCHITECTURE

### 1.1 LLMOps Stack

```
┌─────────────────────────────────────────────────────────────────┐
│                    LLMOps STACK                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Layer 1: DEVELOPMENT                                           │
│  ├── Prompt Engineering (version control)                       │
│  ├── Model Selection                                            │
│  └── Evaluation Datasets                                        │
│                                                                  │
│  Layer 2: EXPERIMENT TRACKING                                   │
│  ├── MLflow / Weights & Biases                                  │
│  ├── Prompt Versions                                            │
│  └── A/B Test Results                                           │
│                                                                  │
│  Layer 3: CI/CD PIPELINE                                        │
│  ├── Automated Testing                                          │
│  ├── Quality Gates                                              │
│  └── Deployment Automation                                      │
│                                                                  │
│  Layer 4: SERVING                                               │
│  ├── Model Gateway (routing, rate limiting)                     │
│  ├── Load Balancing                                             │
│  └── Caching Layer                                              │
│                                                                  │
│  Layer 5: MONITORING                                            │
│  ├── Performance Metrics                                        │
│  ├── Cost Tracking                                              │
│  └── Quality Monitoring                                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. PROMPT VERSION CONTROL

### 2.1 Prompt Management System

```yaml
# prompts/customer-support/v2.3.yaml
metadata:
  name: customer-support-agent
  version: "2.3.0"
  author: team-ai
  created: "2025-01-15"
  tags: [production, support, chat]

prompt:
  system: |
    You are a helpful customer support agent for {company_name}.

    Guidelines:
    - Be polite and professional
    - Escalate to human if unable to help
    - Never share internal policies

  template: |
    Customer query: {query}
    Customer history: {history}
    Available actions: {actions}

variables:
  company_name:
    type: string
    required: true
  query:
    type: string
    required: true
  history:
    type: array
    default: []

testing:
  golden_tests:
    - input: "I want a refund"
      expected_contains: ["refund policy", "help you"]
    - input: "Your product sucks"
      expected_not_contains: ["agree", "terrible"]

deployment:
  rollout: gradual
  canary_percentage: 10
```

### 2.2 Prompt Registry

```python
class PromptRegistry:
    def __init__(self, storage: PromptStorage):
        self.storage = storage
        self.cache = {}

    def register(self, prompt: PromptConfig) -> str:
        """Register a new prompt version"""
        version_hash = self._compute_hash(prompt)
        self.storage.save(prompt.name, prompt.version, prompt)
        return version_hash

    def get(self, name: str, version: str = "latest") -> PromptConfig:
        """Get a prompt by name and version"""
        cache_key = f"{name}:{version}"
        if cache_key in self.cache:
            return self.cache[cache_key]

        prompt = self.storage.load(name, version)
        self.cache[cache_key] = prompt
        return prompt

    def promote(self, name: str, from_env: str, to_env: str):
        """Promote a prompt version between environments"""
        prompt = self.storage.load(name, from_env)
        self.storage.save(name, to_env, prompt)
        self._log_promotion(name, from_env, to_env)

    def rollback(self, name: str, to_version: str):
        """Rollback to a previous version"""
        prompt = self.storage.load(name, to_version)
        self.storage.save(name, "production", prompt)
        self._alert(f"Rollback: {name} to {to_version}")
```

---

## 3. CI/CD PIPELINE FOR LLMs

### 3.1 Pipeline Stages

```yaml
# .github/workflows/llm-pipeline.yml
name: LLM CI/CD Pipeline

on:
  push:
    paths:
      - 'prompts/**'
      - 'src/llm/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Lint prompts
        run: prompt-lint prompts/

      - name: Schema validation
        run: prompt-validate --schema prompts/schema.json

  test:
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - name: Run golden tests
        run: pytest tests/golden/ --model=gpt-4o-mini

      - name: Evaluate quality
        run: |
          python scripts/evaluate.py \
            --prompts prompts/ \
            --eval-set data/eval.json \
            --threshold 0.85

      - name: Cost estimation
        run: python scripts/estimate_cost.py --prompts prompts/

  security:
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - name: Injection testing
        run: python scripts/security_test.py --prompts prompts/

      - name: PII detection
        run: pii-scanner prompts/

  deploy-staging:
    needs: [test, security]
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to staging
        run: |
          prompt-deploy --env staging \
            --prompts prompts/ \
            --canary 10%

      - name: Smoke tests
        run: pytest tests/smoke/ --env staging

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Gradual rollout
        run: |
          prompt-deploy --env production \
            --prompts prompts/ \
            --strategy gradual \
            --steps "10,25,50,100" \
            --interval 15m
```

### 3.2 Quality Gates

```python
class LLMQualityGate:
    def __init__(self, thresholds: Dict[str, float]):
        self.thresholds = thresholds

    def check(self, eval_results: EvalResults) -> GateResult:
        failures = []

        # Accuracy gate
        if eval_results.accuracy < self.thresholds.get("accuracy", 0.85):
            failures.append(f"Accuracy {eval_results.accuracy} < {self.thresholds['accuracy']}")

        # Latency gate
        if eval_results.p95_latency > self.thresholds.get("p95_latency", 3000):
            failures.append(f"P95 latency {eval_results.p95_latency}ms > {self.thresholds['p95_latency']}ms")

        # Cost gate
        if eval_results.cost_per_request > self.thresholds.get("cost_per_request", 0.05):
            failures.append(f"Cost ${eval_results.cost_per_request} > ${self.thresholds['cost_per_request']}")

        # Safety gate
        if eval_results.safety_score < self.thresholds.get("safety", 0.99):
            failures.append(f"Safety {eval_results.safety_score} < {self.thresholds['safety']}")

        return GateResult(
            passed=len(failures) == 0,
            failures=failures,
            metrics=eval_results
        )
```

---

## 4. MODEL GATEWAY

### 4.1 Gateway Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    MODEL GATEWAY                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  REQUEST FLOW:                                                  │
│  ├── Authentication (API key validation)                        │
│  ├── Rate Limiting (per-user, per-model)                        │
│  ├── Request Validation (schema, size)                          │
│  ├── Model Routing (A/B, canary, fallback)                      │
│  ├── Caching Check (semantic cache)                             │
│  ├── Provider Selection (cost, latency)                         │
│  ├── Request Transformation                                     │
│  ├── Provider Call                                              │
│  ├── Response Validation                                        │
│  ├── Logging & Metrics                                          │
│  └── Response to Client                                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Gateway Implementation

```python
from fastapi import FastAPI, Request
from opentelemetry import trace

app = FastAPI()
tracer = trace.get_tracer(__name__)

class ModelGateway:
    def __init__(self, config: GatewayConfig):
        self.router = ModelRouter(config.routing)
        self.cache = SemanticCache(config.cache)
        self.limiter = RateLimiter(config.limits)
        self.providers = {
            "openai": OpenAIProvider(),
            "anthropic": AnthropicProvider(),
            "local": LocalProvider()
        }

    async def handle_request(self, request: LLMRequest) -> LLMResponse:
        with tracer.start_as_current_span("gateway_request") as span:
            # Rate limiting
            if not await self.limiter.allow(request.user_id):
                raise RateLimitExceeded()

            # Check cache
            cached = await self.cache.get(request)
            if cached:
                span.set_attribute("cache_hit", True)
                return cached

            # Route to model
            provider, model = self.router.route(request)
            span.set_attribute("provider", provider)
            span.set_attribute("model", model)

            # Call provider
            start = time.time()
            response = await self.providers[provider].complete(
                model=model,
                messages=request.messages,
                **request.params
            )
            latency = time.time() - start

            # Log metrics
            self._log_metrics(request, response, latency)

            # Cache response
            await self.cache.set(request, response)

            return response

@app.post("/v1/chat/completions")
async def chat_completions(request: Request):
    return await gateway.handle_request(await parse_request(request))
```

---

## 5. DEPLOYMENT STRATEGIES

### 5.1 Canary Deployment

```python
class CanaryDeployment:
    def __init__(self, config: CanaryConfig):
        self.config = config
        self.current_percentage = 0

    async def deploy(self, new_version: str):
        # Start at initial percentage
        self.current_percentage = self.config.initial_percentage

        while self.current_percentage < 100:
            # Route traffic
            await self.router.set_weights({
                "current": 100 - self.current_percentage,
                "canary": self.current_percentage
            })

            # Wait and evaluate
            await asyncio.sleep(self.config.step_interval)
            metrics = await self.monitor.get_canary_metrics()

            # Check thresholds
            if not self._check_health(metrics):
                await self.rollback()
                raise CanaryFailed(metrics)

            # Increase traffic
            self.current_percentage += self.config.step_increment

        # Full rollout
        await self.router.set_weights({"canary": 100})
        await self.finalize(new_version)
```

### 5.2 Blue-Green Deployment

```yaml
# kubernetes/llm-deployment.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: llm-service
spec:
  strategy:
    blueGreen:
      activeService: llm-service-active
      previewService: llm-service-preview
      autoPromotionEnabled: false
      prePromotionAnalysis:
        templates:
          - templateName: llm-quality-check
      postPromotionAnalysis:
        templates:
          - templateName: llm-success-rate

---
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: llm-quality-check
spec:
  metrics:
    - name: accuracy
      provider:
        prometheus:
          query: |
            avg(llm_accuracy{service="{{args.service}}"}) > 0.85
      successCondition: result[0] == true
```

---

## 6. MONITORING & ALERTING

### 6.1 Key Metrics

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| **Latency P50** | Median response time | > 1s |
| **Latency P99** | 99th percentile | > 5s |
| **Error Rate** | Failed requests | > 1% |
| **Token Usage** | Tokens per request | > 10k avg |
| **Cost per Request** | $ per API call | > $0.10 |
| **Cache Hit Rate** | % cached responses | < 30% |
| **Safety Violations** | Blocked responses | > 0.1% |
| **Hallucination Rate** | Detected hallucinations | > 5% |

### 6.2 Alerting Rules

```yaml
# alerting-rules.yaml
groups:
  - name: llm-alerts
    rules:
      - alert: HighLatency
        expr: histogram_quantile(0.99, llm_latency_bucket) > 5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "LLM P99 latency above 5s"

      - alert: HighErrorRate
        expr: rate(llm_errors_total[5m]) / rate(llm_requests_total[5m]) > 0.01
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "LLM error rate above 1%"

      - alert: CostSpike
        expr: increase(llm_cost_total[1h]) > 100
        labels:
          severity: warning
        annotations:
          summary: "LLM cost increased by $100+ in 1 hour"

      - alert: ProviderDown
        expr: up{job="llm-provider"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "LLM provider is down"
```

---

## 7. LIFECYCLE MANAGEMENT

### 7.1 Model Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                    MODEL LIFECYCLE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  DEVELOPMENT → STAGING → PRODUCTION → DEPRECATED                │
│                                                                  │
│  Development:                                                   │
│  └── Prompt engineering, local testing                          │
│                                                                  │
│  Staging:                                                       │
│  └── Integration tests, load tests, security review             │
│                                                                  │
│  Production:                                                    │
│  └── Live traffic, monitoring, A/B tests                        │
│                                                                  │
│  Deprecated:                                                    │
│  └── Migration path, sunset timeline                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2 Version Deprecation

```python
class VersionManager:
    def deprecate(self, model: str, version: str, sunset_date: date):
        """Mark a version as deprecated with migration path"""
        self.registry.update(model, version, status="deprecated")

        # Notify users
        affected_users = self.usage_tracker.get_users(model, version)
        for user in affected_users:
            self.notify(user, DeprecationNotice(
                model=model,
                version=version,
                sunset_date=sunset_date,
                migration_guide=self.get_migration_guide(model, version)
            ))

        # Add warning headers to responses
        self.gateway.add_response_header(
            model, version,
            "X-Deprecation-Warning",
            f"This version will be sunset on {sunset_date}"
        )

    def sunset(self, model: str, version: str):
        """Remove a version from production"""
        # Check for remaining users
        active_users = self.usage_tracker.get_users(model, version, active=True)
        if active_users:
            raise SunsetBlocked(f"{len(active_users)} users still using version")

        # Remove from routing
        self.router.remove(model, version)
        self.registry.update(model, version, status="sunset")
```

---

## 8. HARMONY INTEGRATION

### 8.1 LLMOps for Harmony Agents

```yaml
# Harmony agent deployment pipeline
harmony_llmops:
  prompts:
    location: .harmony/agents/
    versioning: git-based
    testing: golden_tests

  deployment:
    guardian: # Intent routing prompts
      quality_gate:
        accuracy: 0.95
        latency_p99: 500ms
      strategy: blue_green

    sentinel: # Memory management
      quality_gate:
        accuracy: 0.90
        safety: 0.99
      strategy: canary

  monitoring:
    metrics:
      - agent_intent_accuracy
      - agent_routing_latency
      - story_completion_rate
      - ucv_validation_score
```

---

## 9. ANTI-PATTERNS

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **No versioning** | Can't rollback | Git-based prompt versioning |
| **Manual deploys** | Error-prone, slow | CI/CD automation |
| **No testing** | Regressions | Golden tests + eval |
| **Single provider** | No failover | Multi-provider routing |
| **No monitoring** | Blind to issues | Comprehensive metrics |
| **Hardcoded prompts** | Can't update | Prompt registry |

---

**LLMOps Expert**
*"Reliable LLM systems start with robust operations."*
