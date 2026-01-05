---
name: "evaluation-patterns"
displayName: "Evaluation Patterns"
emoji: "📊"
description: "LLM Evaluation patterns: LLM-as-Judge, RAGAS, BLEU/ROUGE, Human Eval, Benchmarks. 18+ sources analyzed."
argument-hint: [evaluation-topic]
version: "1.0"
tier: 2
model: inherit
parent: ai-architect
phase: 3
category: sub-agent
---

# 📊 Evaluation Patterns : Expert en evaluation LLM. Je conçois les frameworks d'evaluation avec metriques et benchmarks.

## Role: LLM Evaluation Expert

> **Specialization**: LLM Evaluation, Benchmarks, Quality Metrics, Human Evaluation
> **Parent Agent**: AI Architect
> **Sources**: 18+ sources from research 2025

---

## 1. EVALUATION FRAMEWORK

### 1.1 Evaluation Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                    EVALUATION LAYERS                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Layer 1: AUTOMATED METRICS                                     │
│  ├── Reference-based (BLEU, ROUGE, METEOR)                      │
│  ├── Reference-free (Perplexity, Coherence)                     │
│  └── Task-specific (Accuracy, F1, EM)                           │
│                                                                  │
│  Layer 2: LLM-AS-JUDGE                                          │
│  ├── Pointwise (Rate single output)                             │
│  ├── Pairwise (Compare two outputs)                             │
│  └── Reference-guided (Compare to gold)                         │
│                                                                  │
│  Layer 3: HUMAN EVALUATION                                      │
│  ├── Expert review                                              │
│  ├── Crowdsourced ratings                                       │
│  └── User feedback                                              │
│                                                                  │
│  Layer 4: PRODUCTION METRICS                                    │
│  ├── User satisfaction                                          │
│  ├── Task completion rate                                       │
│  └── Business KPIs                                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. AUTOMATED METRICS

### 2.1 Reference-Based Metrics

| Metric | Formula | Best For | Range |
|--------|---------|----------|-------|
| **BLEU** | n-gram precision | Translation | 0-100 |
| **ROUGE-L** | LCS-based recall | Summarization | 0-1 |
| **ROUGE-1/2** | Unigram/bigram overlap | Summarization | 0-1 |
| **METEOR** | Alignment + synonyms | Translation | 0-1 |
| **BERTScore** | Semantic similarity | Any text | -1 to 1 |
| **Exact Match** | String equality | QA | 0-1 |

### 2.2 Implementation

```python
from evaluate import load
import numpy as np

class MetricsEvaluator:
    def __init__(self):
        self.bleu = load("bleu")
        self.rouge = load("rouge")
        self.bertscore = load("bertscore")

    def evaluate(self, predictions: List[str], references: List[str]) -> Dict:
        results = {}

        # BLEU Score
        results["bleu"] = self.bleu.compute(
            predictions=predictions,
            references=[[r] for r in references]
        )["bleu"]

        # ROUGE Scores
        rouge_results = self.rouge.compute(
            predictions=predictions,
            references=references
        )
        results["rouge1"] = rouge_results["rouge1"]
        results["rougeL"] = rouge_results["rougeL"]

        # BERTScore
        bert_results = self.bertscore.compute(
            predictions=predictions,
            references=references,
            lang="en"
        )
        results["bertscore_f1"] = np.mean(bert_results["f1"])

        return results
```

### 2.3 When to Use Which Metric

```yaml
metric_selection:
  translation:
    primary: BLEU
    secondary: [METEOR, chrF]
    semantic: BERTScore

  summarization:
    primary: ROUGE-L
    secondary: [ROUGE-1, ROUGE-2]
    semantic: BERTScore

  question_answering:
    primary: Exact Match
    secondary: F1 Score
    semantic: BERTScore

  code_generation:
    primary: pass@k
    secondary: [CodeBLEU, execution_accuracy]

  open_generation:
    avoid: [BLEU, ROUGE]  # Too restrictive
    use: [BERTScore, LLM-as-Judge]
```

---

## 3. LLM-AS-JUDGE

### 3.1 Judge Patterns

```
┌─────────────────────────────────────────────────────────────────┐
│                    LLM-AS-JUDGE PATTERNS                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  POINTWISE EVALUATION:                                          │
│  "Rate this response on a scale of 1-5"                         │
│  ├── Single output scoring                                      │
│  └── Best for: Quality assessment                               │
│                                                                  │
│  PAIRWISE COMPARISON:                                           │
│  "Which response is better: A or B?"                            │
│  ├── Relative ranking                                           │
│  └── Best for: Model comparison                                 │
│                                                                  │
│  REFERENCE-GUIDED:                                              │
│  "How well does this match the reference?"                      │
│  ├── Similarity to gold standard                                │
│  └── Best for: Factual tasks                                    │
│                                                                  │
│  MULTI-ASPECT:                                                  │
│  "Rate helpfulness, accuracy, safety separately"                │
│  ├── Granular assessment                                        │
│  └── Best for: Detailed analysis                                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 LLM Judge Implementation

```python
class LLMJudge:
    def __init__(self, model: str = "claude-3-opus"):
        self.model = model
        self.client = get_llm_client(model)

    def pointwise_evaluate(
        self,
        question: str,
        response: str,
        criteria: List[str]
    ) -> Dict[str, int]:
        prompt = f"""Evaluate this response on the following criteria.
Rate each criterion from 1-5.

Question: {question}
Response: {response}

Criteria to evaluate:
{chr(10).join(f'- {c}' for c in criteria)}

Provide your evaluation in JSON format:
{{"criterion_name": score, ...}}

Be strict and objective in your scoring.
"""
        result = self.client.invoke(prompt)
        return json.loads(result)

    def pairwise_compare(
        self,
        question: str,
        response_a: str,
        response_b: str
    ) -> str:
        prompt = f"""Compare these two responses and determine which is better.

Question: {question}

Response A:
{response_a}

Response B:
{response_b}

Which response is better? Answer with:
- "A" if Response A is better
- "B" if Response B is better
- "TIE" if they are equally good

Explain your reasoning briefly, then give your verdict.
"""
        result = self.client.invoke(prompt)
        return self._extract_verdict(result)

    def multi_aspect_evaluate(
        self,
        question: str,
        response: str
    ) -> Dict:
        aspects = {
            "helpfulness": "Does the response address the user's needs?",
            "accuracy": "Is the information factually correct?",
            "clarity": "Is the response clear and well-organized?",
            "safety": "Is the response free from harmful content?",
            "relevance": "Does the response stay on topic?"
        }

        results = {}
        for aspect, description in aspects.items():
            score = self._evaluate_aspect(question, response, aspect, description)
            results[aspect] = score

        results["overall"] = np.mean(list(results.values()))
        return results
```

### 3.3 Judge Calibration

```python
class CalibratedJudge:
    """Judge with bias mitigation"""

    def __init__(self, base_judge: LLMJudge):
        self.judge = base_judge

    def evaluate_with_calibration(
        self,
        question: str,
        response_a: str,
        response_b: str
    ) -> Dict:
        # Position bias mitigation: evaluate both orders
        result_ab = self.judge.pairwise_compare(question, response_a, response_b)
        result_ba = self.judge.pairwise_compare(question, response_b, response_a)

        # Check consistency
        if result_ab == "A" and result_ba == "B":
            final = "A"
        elif result_ab == "B" and result_ba == "A":
            final = "B"
        elif result_ab == result_ba:
            final = result_ab
        else:
            # Inconsistent - needs human review
            final = "UNCERTAIN"

        return {
            "verdict": final,
            "ab_result": result_ab,
            "ba_result": result_ba,
            "consistent": result_ab != result_ba or result_ab == "TIE"
        }
```

---

## 4. RAGAS FRAMEWORK (RAG Evaluation)

### 4.1 RAGAS Metrics

| Metric | Measures | Range | Good Score |
|--------|----------|-------|------------|
| **Faithfulness** | Answer grounded in context | 0-1 | > 0.9 |
| **Answer Relevancy** | Answer addresses question | 0-1 | > 0.85 |
| **Context Precision** | Retrieved chunks are relevant | 0-1 | > 0.8 |
| **Context Recall** | All needed info was retrieved | 0-1 | > 0.9 |
| **Context Relevancy** | Context is focused | 0-1 | > 0.7 |

### 4.2 RAGAS Implementation

```python
from ragas import evaluate
from ragas.metrics import (
    faithfulness,
    answer_relevancy,
    context_precision,
    context_recall,
    answer_correctness
)
from datasets import Dataset

def evaluate_rag_pipeline(
    questions: List[str],
    answers: List[str],
    contexts: List[List[str]],
    ground_truths: List[str]
) -> Dict:
    # Create evaluation dataset
    dataset = Dataset.from_dict({
        "question": questions,
        "answer": answers,
        "contexts": contexts,
        "ground_truth": ground_truths
    })

    # Run evaluation
    results = evaluate(
        dataset,
        metrics=[
            faithfulness,
            answer_relevancy,
            context_precision,
            context_recall,
            answer_correctness
        ]
    )

    return {
        "faithfulness": results["faithfulness"],
        "answer_relevancy": results["answer_relevancy"],
        "context_precision": results["context_precision"],
        "context_recall": results["context_recall"],
        "answer_correctness": results["answer_correctness"],
        "overall_score": np.mean([
            results["faithfulness"],
            results["answer_relevancy"]
        ])
    }
```

### 4.3 Custom RAG Metrics

```python
class CustomRAGEvaluator:
    def __init__(self, judge: LLMJudge):
        self.judge = judge

    def evaluate_hallucination(
        self,
        answer: str,
        context: str
    ) -> float:
        """Detect statements not grounded in context"""
        prompt = f"""Analyze if the answer contains any hallucinations
(statements not supported by the context).

Context:
{context}

Answer:
{answer}

List any hallucinated statements. If none, say "NONE".
Then rate hallucination severity from 0-1 (0 = no hallucination).
"""
        result = self.judge.invoke(prompt)
        return self._parse_hallucination_score(result)

    def evaluate_completeness(
        self,
        question: str,
        answer: str,
        context: str
    ) -> float:
        """Check if answer addresses all parts of the question"""
        prompt = f"""Does this answer completely address the question
using the available context?

Question: {question}
Context: {context}
Answer: {answer}

Rate completeness from 0-1 (1 = fully complete).
Explain what is missing, if anything.
"""
        result = self.judge.invoke(prompt)
        return self._parse_completeness_score(result)
```

---

## 5. HUMAN EVALUATION

### 5.1 Evaluation Interface Design

```yaml
human_evaluation_config:
  task_design:
    type: pairwise_comparison
    randomize_order: true
    blind_evaluation: true  # Hide which model produced output

  quality_control:
    minimum_time_per_task: 30s  # Prevent rushing
    attention_checks: true      # Include known answers
    agreement_threshold: 0.7    # Inter-annotator agreement

  rating_scales:
    likert_5:
      1: "Very Poor"
      2: "Poor"
      3: "Acceptable"
      4: "Good"
      5: "Excellent"

    binary:
      0: "Unacceptable"
      1: "Acceptable"

  annotator_requirements:
    training_required: true
    qualification_test: true
    minimum_accuracy: 0.85
```

### 5.2 Crowdsourced Evaluation

```python
class CrowdsourcedEvaluator:
    def __init__(self, platform: str = "mturk"):
        self.platform = self._init_platform(platform)

    def create_task(
        self,
        samples: List[EvalSample],
        task_type: str = "pairwise"
    ) -> str:
        task = HumanTask(
            title="AI Response Quality Evaluation",
            description="Compare AI responses and select the better one",
            reward_per_task=0.15,
            time_limit_minutes=5,
            required_annotators=3  # For majority voting
        )

        for sample in samples:
            task.add_question(
                question=sample.question,
                options={
                    "A": sample.response_a,
                    "B": sample.response_b
                },
                gold_answer=sample.gold if hasattr(sample, 'gold') else None
            )

        task_id = self.platform.submit(task)
        return task_id

    def aggregate_results(self, task_id: str) -> Dict:
        results = self.platform.get_results(task_id)

        aggregated = {}
        for question_id, annotations in results.items():
            # Majority voting
            votes = [a.answer for a in annotations]
            winner = max(set(votes), key=votes.count)
            agreement = votes.count(winner) / len(votes)

            aggregated[question_id] = {
                "winner": winner,
                "agreement": agreement,
                "annotations": annotations
            }

        return aggregated
```

---

## 6. BENCHMARK SUITES

### 6.1 Standard Benchmarks

| Benchmark | Domain | Metrics | Models Tested |
|-----------|--------|---------|---------------|
| **MMLU** | Knowledge | Accuracy | All |
| **HumanEval** | Coding | pass@k | Code models |
| **GSM8K** | Math reasoning | Accuracy | All |
| **TruthfulQA** | Truthfulness | % correct | All |
| **HellaSwag** | Commonsense | Accuracy | All |
| **MT-Bench** | Multi-turn chat | LLM score | Chat models |
| **AlpacaEval** | Instruction | Win rate | Instruction |

### 6.2 Custom Benchmark Creation

```python
class CustomBenchmark:
    def __init__(self, name: str, description: str):
        self.name = name
        self.description = description
        self.test_cases = []
        self.metrics = []

    def add_test_case(
        self,
        input: str,
        expected: Optional[str] = None,
        category: str = "general",
        difficulty: str = "medium"
    ):
        self.test_cases.append({
            "id": len(self.test_cases),
            "input": input,
            "expected": expected,
            "category": category,
            "difficulty": difficulty
        })

    def add_metric(self, metric: Callable):
        self.metrics.append(metric)

    def run(self, model: LLM) -> BenchmarkResults:
        results = []

        for case in self.test_cases:
            output = model.generate(case["input"])

            case_results = {
                "id": case["id"],
                "category": case["category"],
                "output": output
            }

            for metric in self.metrics:
                case_results[metric.__name__] = metric(
                    output,
                    case.get("expected")
                )

            results.append(case_results)

        return BenchmarkResults(
            benchmark_name=self.name,
            results=results,
            summary=self._compute_summary(results)
        )
```

---

## 7. PRODUCTION EVALUATION

### 7.1 Online Evaluation

```python
class OnlineEvaluator:
    """Evaluate model quality from production traffic"""

    def __init__(self):
        self.metrics_store = MetricsStore()

    def track_interaction(
        self,
        request_id: str,
        question: str,
        response: str,
        latency_ms: float,
        tokens_used: int
    ):
        # Store for later analysis
        self.metrics_store.store({
            "request_id": request_id,
            "question": question,
            "response": response,
            "latency_ms": latency_ms,
            "tokens_used": tokens_used,
            "timestamp": datetime.now()
        })

    def track_feedback(
        self,
        request_id: str,
        thumbs_up: Optional[bool] = None,
        rating: Optional[int] = None,
        comment: Optional[str] = None
    ):
        self.metrics_store.update(request_id, {
            "thumbs_up": thumbs_up,
            "rating": rating,
            "comment": comment
        })

    def compute_daily_metrics(self, date: date) -> Dict:
        interactions = self.metrics_store.get_by_date(date)

        return {
            "total_requests": len(interactions),
            "avg_latency": np.mean([i["latency_ms"] for i in interactions]),
            "satisfaction_rate": self._compute_satisfaction(interactions),
            "thumbs_up_rate": self._compute_thumbs_up(interactions),
            "avg_rating": np.mean([i["rating"] for i in interactions if i.get("rating")])
        }
```

### 7.2 A/B Testing

```python
class ABTestEvaluator:
    def __init__(self, test_name: str, variants: List[str]):
        self.test_name = test_name
        self.variants = variants
        self.results = {v: [] for v in variants}

    def record_result(
        self,
        variant: str,
        success: bool,
        metric_value: float
    ):
        self.results[variant].append({
            "success": success,
            "metric_value": metric_value
        })

    def analyze(self) -> ABTestResult:
        from scipy import stats

        variant_metrics = {}
        for variant, results in self.results.items():
            values = [r["metric_value"] for r in results]
            variant_metrics[variant] = {
                "mean": np.mean(values),
                "std": np.std(values),
                "n": len(values)
            }

        # Statistical significance test
        if len(self.variants) == 2:
            a_vals = [r["metric_value"] for r in self.results[self.variants[0]]]
            b_vals = [r["metric_value"] for r in self.results[self.variants[1]]]

            t_stat, p_value = stats.ttest_ind(a_vals, b_vals)
            significant = p_value < 0.05
        else:
            significant = None
            p_value = None

        return ABTestResult(
            test_name=self.test_name,
            variant_metrics=variant_metrics,
            winner=max(variant_metrics, key=lambda v: variant_metrics[v]["mean"]),
            p_value=p_value,
            statistically_significant=significant
        )
```

---

## 8. HARMONY INTEGRATION

### 8.1 UCV Evaluation

```python
class UCVEvaluator:
    """Evaluate Use Case Verifications in Harmony"""

    def __init__(self, judge: LLMJudge):
        self.judge = judge

    def evaluate_verification(
        self,
        verification: UCVerification,
        implementation: str,
        test_result: TestResult
    ) -> VerificationScore:
        # Check if implementation satisfies verification
        prompt = f"""Evaluate if this implementation satisfies the verification.

Verification:
{verification.description}

Implementation:
{implementation}

Test Result:
{test_result}

Does the implementation fully satisfy the verification?
Rate from 0-1 and explain.
"""
        score = self.judge.invoke(prompt)

        return VerificationScore(
            verification_id=verification.id,
            score=self._parse_score(score),
            explanation=self._parse_explanation(score),
            status="pass" if self._parse_score(score) > 0.9 else "fail"
        )
```

---

## 9. ANTI-PATTERNS

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **BLEU for open-ended** | Too restrictive | Use LLM-as-Judge |
| **Single metric** | Incomplete picture | Multi-aspect evaluation |
| **No calibration** | Biased judges | Position swap, multi-judge |
| **No human eval** | Misses nuances | Periodic human review |
| **Static benchmarks** | Model overfits | Fresh test sets |
| **Ignoring costs** | Expensive eval | Efficient sampling |

---

**Evaluation Expert**
*"You can't improve what you can't measure."*
