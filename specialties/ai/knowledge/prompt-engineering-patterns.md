---
name: prompt-engineering-patterns
displayName: "Prompt Engineering Patterns"
category: llm-application-dev
tier: 1
model: opus
triggers:
  - "prompt engineering"
  - "system prompt"
  - "few-shot"
  - "chain of thought"
  - "prompt template"
---

# Prompt Engineering Patterns

> Master advanced prompt engineering techniques for better LLM outputs.

## Core Techniques

### Zero-Shot Prompting
```
Classify the sentiment of this review as positive, negative, or neutral:

Review: "The product arrived quickly but the quality was disappointing."

Sentiment:
```

### Few-Shot Prompting
```
Classify the sentiment of reviews:

Review: "Absolutely love it! Best purchase ever."
Sentiment: positive

Review: "Terrible experience. Would not recommend."
Sentiment: negative

Review: "It's okay, nothing special."
Sentiment: neutral

Review: "The product arrived quickly but the quality was disappointing."
Sentiment:
```

### Chain-of-Thought (CoT)
```
Solve this step by step:

Question: If a train travels at 60 mph for 2.5 hours, then at 80 mph for 1.5 hours, what is the total distance?

Let me think through this step by step:
1. Distance = Speed × Time
2. First leg: 60 mph × 2.5 hours = 150 miles
3. Second leg: 80 mph × 1.5 hours = 120 miles
4. Total distance: 150 + 120 = 270 miles

Answer: 270 miles
```

### Self-Consistency
```
Solve this problem 3 different ways and verify the answer:

Problem: A store has 150 apples. They sell 40% on Monday and 25% of the remainder on Tuesday. How many apples are left?

Approach 1: ...
Approach 2: ...
Approach 3: ...

Verified answer:
```

## Prompt Structure

### System Prompt Template
```markdown
# Role
You are a [ROLE] with expertise in [DOMAIN].

# Context
[Background information relevant to the task]

# Task
[Clear description of what to do]

# Constraints
- [Constraint 1]
- [Constraint 2]

# Output Format
[Expected format: JSON, markdown, bullet points, etc.]

# Examples (optional)
Input: [example input]
Output: [example output]
```

### Conversation Design
```python
messages = [
    {
        "role": "system",
        "content": """You are a helpful coding assistant.

Rules:
- Always explain your code
- Use TypeScript unless specified otherwise
- Follow best practices
- Ask clarifying questions if needed"""
    },
    {
        "role": "user",
        "content": "Create a function to validate email addresses"
    },
    {
        "role": "assistant",
        "content": "I'll create a TypeScript function to validate emails..."
    }
]
```

## Advanced Patterns

### ReAct (Reasoning + Acting)
```
Question: What is the capital of the country where the Eiffel Tower is located?

Thought: I need to find where the Eiffel Tower is located, then find the capital of that country.

Action: Search for "Eiffel Tower location"
Observation: The Eiffel Tower is located in Paris, France.

Thought: Now I know it's in France. I need to find the capital of France.

Action: Search for "capital of France"
Observation: The capital of France is Paris.

Thought: I now have the answer.

Final Answer: Paris
```

### Tree of Thoughts
```
Problem: [Complex problem]

Branch 1: [First approach]
  → Evaluation: [Pros/cons]
  → Viability: [Score 1-10]

Branch 2: [Second approach]
  → Evaluation: [Pros/cons]
  → Viability: [Score 1-10]

Branch 3: [Third approach]
  → Evaluation: [Pros/cons]
  → Viability: [Score 1-10]

Best path: [Selected approach based on evaluation]
```

### Structured Output Prompting
```
Extract information from the following text and return as JSON:

Text: "John Smith, aged 35, works at Acme Corp as a Senior Engineer. He can be reached at john.smith@acme.com or 555-0123."

Return JSON with this exact schema:
{
  "name": "string",
  "age": "number",
  "company": "string",
  "role": "string",
  "email": "string",
  "phone": "string"
}
```

## Prompting Anti-Patterns

| Anti-Pattern | Problem | Better Approach |
|--------------|---------|-----------------|
| **Vague instructions** | "Make it better" | "Improve clarity by using simpler words" |
| **No examples** | Ambiguous expectations | Provide 2-3 concrete examples |
| **Too many tasks** | Confused output | One task per prompt |
| **No constraints** | Unpredictable output | Specify format, length, style |
| **Negative framing** | "Don't do X" | "Do Y instead of X" |

## Prompt Optimization

### A/B Testing Template
```python
prompts = {
    "version_a": "Summarize this article in 3 bullet points.",
    "version_b": "Extract the 3 most important facts from this article.",
    "version_c": """As a news editor, identify the 3 key takeaways
                    from this article that readers must know."""
}

# Test with same inputs, measure:
# - Output quality (human rating)
# - Consistency (variance across runs)
# - Token efficiency
```

### Iterative Refinement
```
v1: "Summarize this text"
    → Too generic, variable length

v2: "Summarize this text in exactly 3 sentences"
    → Better, but sometimes misses key points

v3: "Summarize this text in exactly 3 sentences,
     ensuring you cover: main topic, key finding,
     and practical implication"
    → Consistent, comprehensive output
```

## Claude-Specific Tips

```markdown
# Claude Optimization

1. **XML tags** for structure:
   <context>Background info here</context>
   <task>What to do</task>

2. **Clear sections** with headers

3. **Examples in tags**:
   <example>
   Input: ...
   Output: ...
   </example>

4. **Explicit constraints**:
   - Maximum 200 words
   - Use bullet points
   - Technical but accessible

5. **Role prompting**:
   "You are an expert [X] with 10 years of experience..."
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Be specific** | Exact format, length, style |
| **Use examples** | 2-3 diverse examples |
| **Structure clearly** | Headers, sections, XML |
| **Iterate** | Test and refine prompts |
| **Version control** | Track prompt changes |
| **Test edge cases** | Unusual inputs |
| **Measure quality** | Define success metrics |
