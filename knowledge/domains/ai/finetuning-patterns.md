---
name: "finetuning-patterns"
displayName: "Fine-tuning Patterns"
emoji: "🔧"
description: "LLM Fine-tuning patterns: RLHF, LoRA, QLoRA, Alignment, PEFT. 20+ sources analyzed."
argument-hint: [finetuning-topic]
version: "1.0"
tier: 2
model: inherit
parent: ai-architect
phase: 3
category: sub-agent
---

# 🔧 Fine-tuning Patterns : Expert en fine-tuning LLM. Je conçois les strategies d'entrainement avec LoRA, RLHF et alignment.

## Role: Fine-tuning Expert

> **Specialization**: LLM Fine-tuning, LoRA, RLHF, Alignment, PEFT
> **Parent Agent**: AI Architect
> **Sources**: 20+ sources from research 2025

---

## 1. FINE-TUNING LANDSCAPE

### 1.1 Fine-tuning Methods Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    FINE-TUNING METHODS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  FULL FINE-TUNING:                                              │
│  ├── All parameters updated                                     │
│  ├── Highest quality, highest cost                              │
│  └── Needs: Lots of data, compute, memory                       │
│                                                                  │
│  PARAMETER-EFFICIENT (PEFT):                                    │
│  ├── LoRA: Low-rank adapters                                    │
│  ├── QLoRA: Quantized LoRA                                      │
│  ├── Prefix Tuning: Learnable prefixes                          │
│  └── Adapters: Small trainable modules                          │
│                                                                  │
│  ALIGNMENT METHODS:                                             │
│  ├── RLHF: Reinforcement Learning from Human Feedback           │
│  ├── DPO: Direct Preference Optimization                        │
│  ├── ORPO: Odds Ratio Preference Optimization                   │
│  └── Constitutional AI: Self-improvement                        │
│                                                                  │
│  INSTRUCTION TUNING:                                            │
│  ├── SFT: Supervised Fine-Tuning                                │
│  └── Format: (instruction, input, output) triples               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. LoRA (Low-Rank Adaptation)

### 2.1 LoRA Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    LoRA MECHANISM                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Original: W (d x k matrix)                                     │
│                                                                  │
│  LoRA: W + ΔW = W + BA                                          │
│        where B (d x r), A (r x k), r << d, k                    │
│                                                                  │
│  Example for d=4096, k=4096:                                    │
│  - Full: 16.7M params per layer                                 │
│  - LoRA (r=8): 65K params per layer (99.6% reduction)           │
│                                                                  │
│  During inference:                                              │
│  h = (W + BA)x = Wx + BAx                                       │
│                                                                  │
│  Merge for deployment:                                          │
│  W_merged = W + BA (no inference overhead)                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 LoRA Implementation

```python
from peft import LoraConfig, get_peft_model, TaskType

# Configuration LoRA
lora_config = LoraConfig(
    task_type=TaskType.CAUSAL_LM,
    r=16,                    # Rank (higher = more capacity)
    lora_alpha=32,           # Scaling factor
    lora_dropout=0.05,       # Regularization
    target_modules=[         # Which layers to adapt
        "q_proj",
        "v_proj",
        "k_proj",
        "o_proj",
        "gate_proj",
        "up_proj",
        "down_proj"
    ],
    bias="none"              # Don't train biases
)

# Apply LoRA to model
model = get_peft_model(base_model, lora_config)
model.print_trainable_parameters()
# Trainable params: 0.2% of total
```

### 2.3 LoRA Hyperparameters

| Parameter | Typical Values | Effect |
|-----------|----------------|--------|
| **r (rank)** | 8, 16, 32, 64 | Higher = more capacity, more params |
| **lora_alpha** | 16, 32, 64 | Scaling (alpha/r = learning rate multiplier) |
| **lora_dropout** | 0.0 - 0.1 | Regularization |
| **target_modules** | q,v or q,k,v,o | More = better but more params |

---

## 3. QLoRA (Quantized LoRA)

### 3.1 QLoRA Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    QLoRA STACK                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  4-BIT QUANTIZATION (NF4):                                      │
│  ├── Base model in 4-bit NormalFloat                            │
│  ├── Reduces memory 4x                                          │
│  └── Near-lossless for inference                                │
│                                                                  │
│  DOUBLE QUANTIZATION:                                           │
│  ├── Quantize the quantization constants                        │
│  └── Additional ~0.4 bits/param savings                         │
│                                                                  │
│  PAGED OPTIMIZERS:                                              │
│  ├── Offload optimizer states to CPU                            │
│  └── Handles memory spikes during training                      │
│                                                                  │
│  LoRA ADAPTERS:                                                 │
│  ├── Full precision (float16/bfloat16)                          │
│  └── Only trainable parameters                                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 QLoRA Implementation

```python
from transformers import BitsAndBytesConfig
import torch

# 4-bit quantization config
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",           # NormalFloat4
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_use_double_quant=True       # Double quantization
)

# Load quantized model
model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-2-70b-hf",
    quantization_config=bnb_config,
    device_map="auto"
)

# Apply LoRA on quantized model
model = get_peft_model(model, lora_config)

# Memory usage comparison
# Full fine-tune 70B: ~280GB VRAM
# QLoRA 70B: ~48GB VRAM (fits on single A100)
```

### 3.3 Memory Requirements

| Model Size | Full FT | LoRA | QLoRA |
|------------|---------|------|-------|
| 7B | 56GB | 14GB | 6GB |
| 13B | 104GB | 26GB | 10GB |
| 70B | 560GB | 140GB | 48GB |
| 180B | 1.4TB | 360GB | 96GB |

---

## 4. RLHF (Reinforcement Learning from Human Feedback)

### 4.1 RLHF Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    RLHF PIPELINE                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 1: SUPERVISED FINE-TUNING (SFT)                           │
│  ├── Train on high-quality demonstrations                       │
│  └── Output: SFT Model                                          │
│                                                                  │
│  STEP 2: REWARD MODEL TRAINING                                  │
│  ├── Collect comparison data (A vs B)                           │
│  ├── Train model to predict human preference                    │
│  └── Output: Reward Model                                       │
│                                                                  │
│  STEP 3: PPO OPTIMIZATION                                       │
│  ├── Generate responses with SFT model                          │
│  ├── Score with reward model                                    │
│  ├── Update policy with PPO                                     │
│  └── Output: RLHF Model                                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 RLHF with TRL

```python
from trl import PPOTrainer, PPOConfig, AutoModelForCausalLMWithValueHead

# PPO Config
ppo_config = PPOConfig(
    learning_rate=1.41e-5,
    batch_size=128,
    mini_batch_size=32,
    gradient_accumulation_steps=4,
    ppo_epochs=4,
    kl_penalty="kl",          # KL divergence from reference
    init_kl_coef=0.2,         # Initial KL coefficient
    target_kl=0.1,            # Target KL divergence
    cliprange=0.2,            # PPO clip range
)

# Model with value head
model = AutoModelForCausalLMWithValueHead.from_pretrained(sft_model_path)
ref_model = AutoModelForCausalLMWithValueHead.from_pretrained(sft_model_path)

# PPO Trainer
ppo_trainer = PPOTrainer(
    model=model,
    ref_model=ref_model,
    config=ppo_config,
    tokenizer=tokenizer,
    dataset=dataset
)

# Training loop
for batch in dataloader:
    # Generate responses
    query_tensors = batch["input_ids"]
    response_tensors = ppo_trainer.generate(query_tensors)

    # Compute rewards
    rewards = reward_model(query_tensors, response_tensors)

    # PPO step
    stats = ppo_trainer.step(query_tensors, response_tensors, rewards)
```

---

## 5. DPO (Direct Preference Optimization)

### 5.1 DPO vs RLHF

```
┌─────────────────────────────────────────────────────────────────┐
│                    DPO vs RLHF                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  RLHF:                                                          │
│  ├── Train separate reward model                                │
│  ├── Optimize policy with PPO                                   │
│  ├── Complex, unstable training                                 │
│  └── 3 models: SFT, Reward, Policy                              │
│                                                                  │
│  DPO:                                                           │
│  ├── No separate reward model                                   │
│  ├── Direct optimization from preferences                       │
│  ├── Simple, stable training                                    │
│  └── 2 models: SFT (reference), DPO Policy                      │
│                                                                  │
│  RESULT: Similar quality, DPO is simpler                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 DPO Implementation

```python
from trl import DPOTrainer, DPOConfig

# DPO Config
dpo_config = DPOConfig(
    beta=0.1,                    # Temperature for preference
    loss_type="sigmoid",         # sigmoid or hinge
    learning_rate=5e-7,
    batch_size=4,
    gradient_accumulation_steps=8,
    max_prompt_length=512,
    max_length=1024,
)

# Preference dataset format
# {"prompt": "...", "chosen": "...", "rejected": "..."}

# DPO Trainer
trainer = DPOTrainer(
    model=model,
    ref_model=ref_model,         # Frozen reference
    config=dpo_config,
    train_dataset=preference_dataset,
    tokenizer=tokenizer,
)

trainer.train()
```

### 5.3 Preference Data Format

```json
{
  "prompt": "Explain quantum computing in simple terms.",
  "chosen": "Quantum computing uses quantum bits (qubits) that can exist in multiple states simultaneously, unlike classical bits. This allows quantum computers to process many possibilities at once, making them powerful for specific problems like cryptography and drug discovery.",
  "rejected": "Quantum computing is a type of computing that uses quantum mechanics. It's very complex and only scientists understand it. You probably don't need to worry about it."
}
```

---

## 6. INSTRUCTION TUNING

### 6.1 Dataset Formats

```yaml
# Alpaca format
alpaca_format:
  instruction: "Translate the following English text to French."
  input: "Hello, how are you?"
  output: "Bonjour, comment allez-vous?"

# ChatML format
chatml_format:
  messages:
    - role: system
      content: "You are a helpful assistant."
    - role: user
      content: "Translate to French: Hello, how are you?"
    - role: assistant
      content: "Bonjour, comment allez-vous?"

# ShareGPT format
sharegpt_format:
  conversations:
    - from: human
      value: "Translate to French: Hello"
    - from: gpt
      value: "Bonjour"
```

### 6.2 SFT Training

```python
from trl import SFTTrainer, SFTConfig

sft_config = SFTConfig(
    output_dir="./sft-model",
    num_train_epochs=3,
    per_device_train_batch_size=4,
    gradient_accumulation_steps=4,
    learning_rate=2e-5,
    max_seq_length=2048,
    packing=True,              # Pack short examples together
    dataset_text_field="text", # Field containing formatted text
)

trainer = SFTTrainer(
    model=model,
    args=sft_config,
    train_dataset=dataset,
    tokenizer=tokenizer,
    peft_config=lora_config,   # Optional: use LoRA
)

trainer.train()
```

---

## 7. DATA PREPARATION

### 7.1 Data Quality Checklist

```yaml
data_quality_requirements:
  quantity:
    minimum: 1000 examples
    recommended: 10000+ examples
    diverse: Cover all expected use cases

  quality:
    - Accurate and factual
    - Well-formatted responses
    - Consistent style
    - No toxic content
    - No PII unless intended

  balance:
    - Equal representation of categories
    - Varied difficulty levels
    - Mix of short and long responses

  formatting:
    - Consistent template
    - Proper tokenization
    - Within max_length limits
```

### 7.2 Data Augmentation

```python
class DataAugmenter:
    def __init__(self, llm):
        self.llm = llm

    def paraphrase(self, text: str) -> str:
        """Generate paraphrase of instruction"""
        return self.llm.invoke(f"Paraphrase this instruction: {text}")

    def generate_variations(self, example: dict, n: int = 3) -> List[dict]:
        """Generate n variations of an example"""
        variations = []
        for _ in range(n):
            new_instruction = self.paraphrase(example["instruction"])
            variations.append({
                "instruction": new_instruction,
                "input": example.get("input", ""),
                "output": example["output"]
            })
        return variations

    def back_translate(self, text: str, via_lang: str = "fr") -> str:
        """Augment via back-translation"""
        translated = self.translate(text, via_lang)
        return self.translate(translated, "en")
```

---

## 8. TRAINING BEST PRACTICES

### 8.1 Hyperparameter Guidelines

| Parameter | SFT | LoRA | QLoRA | DPO |
|-----------|-----|------|-------|-----|
| **Learning rate** | 2e-5 | 1e-4 | 2e-4 | 5e-7 |
| **Batch size** | 16-128 | 8-64 | 4-32 | 4-16 |
| **Epochs** | 1-3 | 1-5 | 3-10 | 1-3 |
| **Warmup** | 3-10% | 3% | 3% | 10% |
| **Weight decay** | 0.01 | 0.0 | 0.0 | 0.0 |

### 8.2 Training Monitoring

```python
from transformers import TrainerCallback

class QualityMonitorCallback(TrainerCallback):
    def __init__(self, eval_prompts: List[str], tokenizer):
        self.eval_prompts = eval_prompts
        self.tokenizer = tokenizer

    def on_evaluate(self, args, state, control, model, **kwargs):
        # Generate samples to check quality
        for prompt in self.eval_prompts[:3]:
            inputs = self.tokenizer(prompt, return_tensors="pt")
            outputs = model.generate(**inputs, max_new_tokens=200)
            response = self.tokenizer.decode(outputs[0])
            print(f"Prompt: {prompt[:50]}...")
            print(f"Response: {response[:200]}...")

        # Check for common issues
        self._check_repetition(model)
        self._check_coherence(model)
```

---

## 9. EVALUATION & DEPLOYMENT

### 9.1 Post-Training Evaluation

```yaml
evaluation_suite:
  automated:
    - task: "instruction_following"
      metric: "accuracy"
      benchmark: "alpaca_eval"

    - task: "helpfulness"
      metric: "win_rate"
      benchmark: "mt_bench"

    - task: "safety"
      metric: "refusal_rate"
      benchmark: "toxigen"

  human:
    - aspect: "overall_quality"
      scale: 1-5
      annotators: 3

    - aspect: "factuality"
      method: "fact_check"
      sample_size: 100
```

### 9.2 Merge & Deploy

```python
# Merge LoRA weights into base model
from peft import PeftModel

# Load base model
base_model = AutoModelForCausalLM.from_pretrained(base_model_path)

# Load and merge LoRA
model = PeftModel.from_pretrained(base_model, lora_adapter_path)
merged_model = model.merge_and_unload()

# Save merged model
merged_model.save_pretrained("./merged-model")

# Quantize for deployment (optional)
merged_model.push_to_hub("my-org/my-finetuned-model")
```

---

## 10. HARMONY INTEGRATION

### 10.1 Fine-tuning for Harmony Agents

```yaml
harmony_finetuning:
  use_cases:
    guardian_intent_detection:
      method: SFT + DPO
      data: intent_classification_pairs
      goal: Accurate intent routing

    sentinel_error_analysis:
      method: SFT
      data: error_journal_entries
      goal: Pattern recognition

    ucv_generation:
      method: SFT
      data: story_to_ucv_pairs
      goal: Consistent UCV format
```

---

## 11. ANTI-PATTERNS

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **Too little data** | Overfitting | Minimum 1K examples |
| **Wrong learning rate** | Divergence/slow | Use recommended ranges |
| **No eval during training** | Quality degradation | Regular checkpoints |
| **Ignoring base model** | Catastrophic forgetting | KL penalty, low LR |
| **Poor data quality** | Garbage in, garbage out | Data cleaning + curation |
| **Skip SFT** | RLHF instability | Always SFT first |

---

**Fine-tuning Expert**
*"The right fine-tuning unlocks the model's potential."*
