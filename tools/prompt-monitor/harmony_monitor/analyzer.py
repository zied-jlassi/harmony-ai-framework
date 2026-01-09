"""
Prompt Analyzer - Core scoring algorithms for prompt effectiveness.

This module provides algorithms to measure:
- Prompt Clarity Score (0-100)
- Response Quality Score (0-100)
- Alignment Score (0-100)
- Cost Efficiency
"""

import re
from dataclasses import dataclass
from typing import Optional

from .models import AlignmentCategory, AnalysisResult


@dataclass
class ClarityBreakdown:
    """Detailed breakdown of prompt clarity score."""
    length_score: int = 0
    context_score: int = 0
    specificity_score: int = 0
    examples_score: int = 0
    constraints_score: int = 0


@dataclass
class QualityBreakdown:
    """Detailed breakdown of response quality score."""
    completeness_score: int = 0
    structure_score: int = 0
    concreteness_score: int = 0
    vagueness_penalty: int = 0


class PromptAnalyzer:
    """Analyzer for prompt-response effectiveness."""

    # Patterns indicating context in prompts
    CONTEXT_PATTERNS = [
        r"context:",
        r"background:",
        r"given that",
        r"considering",
        r"based on",
        r"in the context of",
        r"assuming",
        r"le contexte est",
        r"sachant que",
    ]

    # Patterns indicating specific questions
    SPECIFIC_PATTERNS = [
        r"how do I",
        r"how can I",
        r"what is the .{1,30} for",
        r"create a .{1,50} that",
        r"fix the .{1,30} in",
        r"implement .{1,50} using",
        r"write a .{1,30} to",
        r"explain .{1,30} in",
        r"comment .{1,30} pour",
        r"cr[ée]er un",
        r"impl[ée]menter",
    ]

    # Patterns indicating vague responses
    VAGUE_PATTERNS = [
        r"je ne suis pas s[uû]r",
        r"peut-[eê]tre",
        r"I'?m not (certain|sure)",
        r"could you (clarify|specify)",
        r"pourriez-vous pr[ée]ciser",
        r"it depends",
        r"generally speaking",
        r"in general",
        r"that depends on",
        r"hard to say",
        r"difficult to determine",
        r"I would need more",
        r"j'aurais besoin de plus",
    ]

    # Patterns indicating concrete actions
    ACTION_PATTERNS = [
        r"\brun\b",
        r"\bexecute\b",
        r"\bcreate\b",
        r"\binstall\b",
        r"\buse\b",
        r"\badd\b",
        r"\bremove\b",
        r"\bmodify\b",
        r"\bchange\b",
        r"\bupdate\b",
        r"\bex[ée]cute",
        r"\blance",
        r"\bcr[ée]e",
    ]

    # Constraint keywords
    CONSTRAINT_WORDS = [
        "must", "should", "only", "without", "using", "with",
        "never", "always", "ensure", "make sure",
        "doit", "devrait", "uniquement", "sans", "avec", "jamais"
    ]

    def __init__(self):
        """Initialize the analyzer."""
        # Compile patterns for efficiency
        self._context_re = [re.compile(p, re.I) for p in self.CONTEXT_PATTERNS]
        self._specific_re = [re.compile(p, re.I) for p in self.SPECIFIC_PATTERNS]
        self._vague_re = [re.compile(p, re.I) for p in self.VAGUE_PATTERNS]
        self._action_re = [re.compile(p, re.I) for p in self.ACTION_PATTERNS]

    def analyze(
        self,
        prompt: str,
        response: str,
        cost_usd: float = 0.0,
        response_tokens: int = 0
    ) -> AnalysisResult:
        """
        Analyze a prompt-response pair and return comprehensive metrics.

        Args:
            prompt: The user's prompt text
            response: The LLM's response text
            cost_usd: Cost of this request in USD
            response_tokens: Number of output tokens

        Returns:
            AnalysisResult with all scores and suggestions
        """
        # Calculate individual scores
        clarity_score, clarity_breakdown = self.calculate_prompt_clarity(prompt)
        quality_score, quality_breakdown = self.calculate_response_quality(response, prompt)

        # Calculate alignment
        alignment = self.calculate_alignment(clarity_score, quality_score)

        # Calculate cost efficiency
        cost_efficiency = self.calculate_cost_efficiency(
            cost_usd, response_tokens, quality_score
        )

        return AnalysisResult(
            prompt_clarity_score=clarity_score,
            response_quality_score=quality_score,
            alignment_score=alignment["score"],
            alignment_category=alignment["category"],
            cost_efficiency=cost_efficiency,
            suggestion=alignment["suggestion"],
            clarity_breakdown=clarity_breakdown.__dict__,
            quality_breakdown=quality_breakdown.__dict__,
        )

    def calculate_prompt_clarity(self, prompt: str) -> tuple[int, ClarityBreakdown]:
        """
        Calculate prompt clarity score (0-100).

        Factors:
        - Length: Sufficient detail without being excessive
        - Context: Background information provided
        - Specificity: Clear, targeted questions
        - Examples: Code samples or examples included
        - Constraints: Explicit requirements specified

        Returns:
            Tuple of (score, breakdown)
        """
        breakdown = ClarityBreakdown()
        prompt_lower = prompt.lower()

        # 1. Length score (0-20)
        # Optimal: 50-500 characters
        length = len(prompt)
        if 100 <= length <= 500:
            breakdown.length_score = 20
        elif 50 <= length < 100:
            breakdown.length_score = 15
        elif 500 < length <= 1000:
            breakdown.length_score = 15
        elif 20 <= length < 50:
            breakdown.length_score = 10
        elif length > 1000:
            breakdown.length_score = 10
        else:
            breakdown.length_score = 5

        # 2. Context score (0-20)
        context_matches = sum(1 for p in self._context_re if p.search(prompt))
        breakdown.context_score = min(20, context_matches * 10)

        # 3. Specificity score (0-25)
        specific_matches = sum(1 for p in self._specific_re if p.search(prompt))
        breakdown.specificity_score = min(25, specific_matches * 12)

        # 4. Examples score (0-20)
        # Check for code blocks or explicit examples
        has_code = "```" in prompt or "example:" in prompt_lower
        has_inline_code = "`" in prompt and prompt.count("`") >= 2
        if has_code:
            breakdown.examples_score = 20
        elif has_inline_code:
            breakdown.examples_score = 10
        elif "e.g." in prompt_lower or "par exemple" in prompt_lower:
            breakdown.examples_score = 8

        # 5. Constraints score (0-15)
        constraint_count = sum(1 for w in self.CONSTRAINT_WORDS if w in prompt_lower)
        breakdown.constraints_score = min(15, constraint_count * 3)

        # Calculate total
        total = (
            breakdown.length_score +
            breakdown.context_score +
            breakdown.specificity_score +
            breakdown.examples_score +
            breakdown.constraints_score
        )

        return min(100, total), breakdown

    def calculate_response_quality(
        self,
        response: str,
        prompt: str
    ) -> tuple[int, QualityBreakdown]:
        """
        Calculate response quality score (0-100).

        Factors:
        - Completeness: Substantial response
        - Structure: Code blocks, lists, formatting
        - Concreteness: Actionable suggestions
        - Vagueness: Penalty for uncertain language

        Returns:
            Tuple of (score, breakdown)
        """
        breakdown = QualityBreakdown()

        # 1. Completeness score (0-30)
        length = len(response)
        if length > 500:
            breakdown.completeness_score = 30
        elif length > 200:
            breakdown.completeness_score = 25
        elif length > 100:
            breakdown.completeness_score = 20
        elif length > 50:
            breakdown.completeness_score = 15
        else:
            breakdown.completeness_score = 10

        # 2. Structure score (0-30)
        structure_points = 0

        # Code blocks
        code_blocks = response.count("```")
        structure_points += min(15, code_blocks * 5)

        # Bullet lists
        if re.search(r"^\s*[-*]\s", response, re.M):
            structure_points += 8

        # Numbered lists
        if re.search(r"^\s*\d+\.\s", response, re.M):
            structure_points += 8

        # Headers
        if re.search(r"^#+\s", response, re.M):
            structure_points += 5

        breakdown.structure_score = min(30, structure_points)

        # 3. Concreteness score (0-25)
        action_matches = sum(1 for p in self._action_re if p.search(response))
        breakdown.concreteness_score = min(25, action_matches * 5)

        # 4. Vagueness penalty (0-25 points deducted)
        vague_matches = sum(1 for p in self._vague_re if p.search(response))
        breakdown.vagueness_penalty = min(25, vague_matches * 8)

        # Calculate total
        total = (
            breakdown.completeness_score +
            breakdown.structure_score +
            breakdown.concreteness_score -
            breakdown.vagueness_penalty
        )

        return max(0, min(100, total)), breakdown

    def calculate_alignment(
        self,
        prompt_clarity: int,
        response_quality: int
    ) -> dict:
        """
        Calculate alignment between prompt clarity and response quality.

        This is the KEY metric for learning about prompting effectiveness.

        Scenarios:
        - OPTIMAL: Clear prompt (>70) + Clear response (>70)
        - IMPRESSIVE: Vague prompt (<50) + Clear response (>70)
        - PROBLEM: Clear prompt (>70) + Vague response (<50)
        - EXPECTED: Vague prompt (<50) + Vague response (<50)

        Returns:
            Dict with score, category, and suggestion
        """
        result = {
            "score": 0,
            "category": AlignmentCategory.EXPECTED,
            "suggestion": ""
        }

        # Determine category
        if prompt_clarity >= 70 and response_quality >= 70:
            result["score"] = 90
            result["category"] = AlignmentCategory.OPTIMAL
            result["suggestion"] = (
                "Excellent! Prompt clair et reponse de qualite. "
                "Continue avec ce style de prompt."
            )

        elif prompt_clarity < 50 and response_quality >= 70:
            result["score"] = 95
            result["category"] = AlignmentCategory.IMPRESSIVE
            result["suggestion"] = (
                "Impressionnant! Le LLM a bien interprete malgre un prompt vague. "
                "Tu peux quand meme ameliorer le prompt pour plus de consistance."
            )

        elif prompt_clarity >= 70 and response_quality < 50:
            result["score"] = 30
            result["category"] = AlignmentCategory.PROBLEM
            result["suggestion"] = (
                "Attention: Prompt clair mais reponse vague. "
                "Verifier: contexte perdu? Limite de tokens? Sujet trop complexe?"
            )

        else:  # Both low
            result["score"] = 50
            result["category"] = AlignmentCategory.EXPECTED
            result["suggestion"] = (
                "Prompt vague = reponse vague (normal). "
                "Ameliore ton prompt: ajoute contexte, exemples, et contraintes."
            )

        # Adjust score based on actual values
        if result["category"] in [AlignmentCategory.OPTIMAL, AlignmentCategory.IMPRESSIVE]:
            # Bonus for high scores
            avg = (prompt_clarity + response_quality) / 2
            result["score"] = int(min(100, result["score"] + (avg - 70) / 3))

        return result

    def calculate_cost_efficiency(
        self,
        cost_usd: float,
        response_tokens: int,
        quality_score: int
    ) -> float:
        """
        Calculate cost efficiency metric.

        Formula: (quality_score * response_tokens) / (cost_usd * 10000)

        Returns:
            Efficiency score (higher is better)
        """
        if cost_usd <= 0:
            return 0.0

        # Value = quality * tokens produced
        value = quality_score * response_tokens

        # Efficiency = value per dollar spent
        efficiency = value / (cost_usd * 10000)

        return round(efficiency, 2)

    def get_improvement_suggestions(
        self,
        clarity_breakdown: ClarityBreakdown,
        quality_breakdown: QualityBreakdown
    ) -> list[str]:
        """
        Generate specific improvement suggestions based on analysis.

        Returns:
            List of actionable suggestions
        """
        suggestions = []

        # Prompt clarity suggestions
        if clarity_breakdown.length_score < 15:
            suggestions.append(
                "Prompt trop court. Ajoute plus de details sur ce que tu veux."
            )

        if clarity_breakdown.context_score < 10:
            suggestions.append(
                "Ajoute du contexte: 'Given that...', 'In the context of...'"
            )

        if clarity_breakdown.specificity_score < 15:
            suggestions.append(
                "Sois plus specifique: 'How do I X using Y?' au lieu de 'How to X?'"
            )

        if clarity_breakdown.examples_score < 10:
            suggestions.append(
                "Ajoute un exemple de ce que tu attends (input/output desire)."
            )

        if clarity_breakdown.constraints_score < 5:
            suggestions.append(
                "Precise tes contraintes: 'must', 'should not', 'using only'..."
            )

        # Response quality concerns
        if quality_breakdown.vagueness_penalty > 15:
            suggestions.append(
                "Reponse vague detectee. Reformule le prompt plus clairement."
            )

        if quality_breakdown.structure_score < 10:
            suggestions.append(
                "Demande explicitement du code ou une liste structuree."
            )

        return suggestions[:5]  # Limit to top 5 suggestions

    def generate_improved_prompt(
        self,
        prompt: str,
        breakdown: ClarityBreakdown
    ) -> str:
        """
        Generate an improved version of the prompt based on analysis.

        Args:
            prompt: Original prompt text
            breakdown: Clarity breakdown with scores

        Returns:
            Improved prompt suggestion
        """
        parts = []

        # 1. Add context if missing
        if breakdown.context_score < 10:
            domain = self._detect_domain(prompt)
            parts.append(f"Given that I'm working on {domain},")

        # 2. Add the main question (cleaned up)
        main_question = prompt.strip()
        if main_question and not main_question.endswith("?"):
            main_question = main_question.rstrip(".") + "?"
        parts.append(main_question)

        # 3. Add constraints if missing
        if breakdown.constraints_score < 10:
            parts.append("\n\nI need to:")
            constraints = self._suggest_constraints(prompt)
            for c in constraints:
                parts.append(f"\n- {c}")

        # 4. Add example if missing
        if breakdown.examples_score < 10:
            example = self._suggest_example(prompt)
            if example:
                parts.append(f"\n\nExpected output:\n```\n{example}\n```")

        return " ".join(parts)

    def _detect_domain(self, prompt: str) -> str:
        """Detect the technical domain of the prompt."""
        prompt_lower = prompt.lower()

        domains = {
            "a REST API": ["api", "endpoint", "rest", "graphql", "route"],
            "a web application": ["react", "vue", "frontend", "component", "html", "css"],
            "a backend service": ["database", "auth", "server", "backend", "postgresql"],
            "a Python script": ["python", "script", "pandas", "numpy"],
            "a TypeScript project": ["typescript", "ts", "type"],
            "a Node.js application": ["node", "npm", "express", "fastify"],
        }

        for domain, keywords in domains.items():
            if any(kw in prompt_lower for kw in keywords):
                return domain

        return "a software project"

    def _suggest_constraints(self, prompt: str) -> list[str]:
        """Suggest constraints based on prompt content."""
        prompt_lower = prompt.lower()

        suggestions = []

        if "auth" in prompt_lower:
            suggestions.extend([
                "Handle token expiration",
                "Support refresh tokens",
                "Secure password storage"
            ])
        elif "api" in prompt_lower:
            suggestions.extend([
                "Return proper HTTP status codes",
                "Include error handling",
                "Add request validation"
            ])
        elif "database" in prompt_lower:
            suggestions.extend([
                "Handle connection pooling",
                "Support transactions",
                "Include migrations"
            ])
        else:
            suggestions.extend([
                "[specific requirement 1]",
                "[specific requirement 2]",
                "[specific requirement 3]"
            ])

        return suggestions[:3]

    def _suggest_example(self, prompt: str) -> str:
        """Suggest an example format based on prompt content."""
        prompt_lower = prompt.lower()

        if "api" in prompt_lower or "endpoint" in prompt_lower:
            return '{"status": "success", "data": {...}}'
        elif "auth" in prompt_lower or "token" in prompt_lower:
            return '{"access_token": "...", "token_type": "bearer"}'
        elif "function" in prompt_lower or "def" in prompt_lower:
            return "result = my_function(param1, param2)"
        elif "component" in prompt_lower or "react" in prompt_lower:
            return "<MyComponent prop={value} />"

        return ""

    def generate_learning_insights(
        self,
        prompt: str,
        response: str,
        clarity_breakdown: ClarityBreakdown,
        quality_breakdown: QualityBreakdown
    ) -> dict:
        """
        Generate educational insights to help user understand and improve.

        Returns:
            Dict with thinking_patterns, why_response_differs, and learning_tips
        """
        insights = {
            "thinking_patterns": [],
            "why_response_differs": [],
            "learning_tips": [],
            "mental_model": ""
        }

        prompt_lower = prompt.lower()

        # Detect thinking patterns (what's missing in reasoning)
        if clarity_breakdown.context_score < 10:
            insights["thinking_patterns"].append({
                "pattern": "Missing Context",
                "issue": "Tu assumes que l'IA connait ton contexte",
                "fix": "Commence par 'Given that...' ou 'Dans le contexte de...'",
                "example": f"AVANT: {prompt[:50]}...\nAPRES: Given that I'm working on [projet], {prompt[:50]}..."
            })

        if clarity_breakdown.constraints_score < 10:
            insights["thinking_patterns"].append({
                "pattern": "Implicit Requirements",
                "issue": "Tu as des attentes non exprimees",
                "fix": "Liste explicitement ce que tu veux avec 'I need to...'",
                "example": "Ajoute: 'I need to: 1) handle errors, 2) return JSON, 3) log events'"
            })

        if clarity_breakdown.examples_score < 10:
            insights["thinking_patterns"].append({
                "pattern": "Abstract Thinking",
                "issue": "Tu penses en abstrait, l'IA a besoin de concret",
                "fix": "Donne un exemple input/output attendu",
                "example": "Ajoute: 'Example: input=[1,2,3] -> output=6'"
            })

        # Why response might differ from expectations
        if quality_breakdown.vagueness_penalty > 10:
            insights["why_response_differs"].append({
                "reason": "L'IA a detecte de l'ambiguite dans ta demande",
                "explanation": "Quand le prompt est vague, l'IA joue la securite avec des reponses generales",
                "solution": "Plus tu es precis, plus la reponse sera precise"
            })

        if clarity_breakdown.specificity_score < 15 and quality_breakdown.completeness_score > 20:
            insights["why_response_differs"].append({
                "reason": "Decalage question vague / reponse generique",
                "explanation": "L'IA a repondu a ce qu'elle a compris, pas a ce que tu voulais",
                "solution": "Reformule avec 'How do I specifically...' au lieu de 'How do I...'"
            })

        if "?" not in prompt and quality_breakdown.structure_score < 15:
            insights["why_response_differs"].append({
                "reason": "Pas de question claire detectee",
                "explanation": "Sans question explicite, l'IA devine ton intention",
                "solution": "Termine par une question claire: 'How should I...?'"
            })

        # Learning tips based on patterns
        insights["learning_tips"] = self._generate_learning_tips(
            prompt, clarity_breakdown, quality_breakdown
        )

        # Mental model for better prompting
        insights["mental_model"] = self._generate_mental_model(clarity_breakdown)

        return insights

    def _generate_learning_tips(
        self,
        prompt: str,
        clarity: ClarityBreakdown,
        quality: QualityBreakdown
    ) -> list:
        """Generate actionable learning tips."""
        tips = []

        total_clarity = (
            clarity.length_score + clarity.context_score +
            clarity.specificity_score + clarity.examples_score +
            clarity.constraints_score
        )

        # Pattern-based tips
        if total_clarity < 30:
            tips.append({
                "level": "fundamental",
                "tip": "Structure de base: CONTEXTE + QUESTION + CONTRAINTES + EXEMPLE",
                "why": "Cette structure force une reflexion complete avant de demander"
            })

        if clarity.context_score < 10 and clarity.specificity_score >= 15:
            tips.append({
                "level": "intermediate",
                "tip": "Ta question est bonne mais manque de contexte",
                "why": "L'IA ne sait pas dans quel projet/stack tu travailles"
            })

        if clarity.examples_score < 10 and "how" in prompt.lower():
            tips.append({
                "level": "advanced",
                "tip": "Pour les 'How to', montre le resultat attendu",
                "why": "L'IA comprend mieux avec un exemple concret du resultat"
            })

        if quality.vagueness_penalty > 15:
            tips.append({
                "level": "diagnostic",
                "tip": "La reponse vague indique un prompt interpretable de plusieurs facons",
                "why": "Elimine l'ambiguite en etant plus specifique"
            })

        return tips

    def _generate_mental_model(self, clarity: ClarityBreakdown) -> str:
        """Generate a mental model visualization for the prompt."""
        total = (
            clarity.length_score + clarity.context_score +
            clarity.specificity_score + clarity.examples_score +
            clarity.constraints_score
        )

        # Visual representation of prompt completeness
        context_bar = "█" * (clarity.context_score // 4) + "░" * (5 - clarity.context_score // 4)
        specific_bar = "█" * (clarity.specificity_score // 5) + "░" * (5 - clarity.specificity_score // 5)
        example_bar = "█" * (clarity.examples_score // 4) + "░" * (5 - clarity.examples_score // 4)
        constraint_bar = "█" * (clarity.constraints_score // 3) + "░" * (5 - clarity.constraints_score // 3)

        model = f"""
┌─ TON PROMPT: ANALYSE ─────────────────────┐
│                                            │
│  Context    [{context_bar}] {clarity.context_score}/20      │
│  Specific   [{specific_bar}] {clarity.specificity_score}/25      │
│  Examples   [{example_bar}] {clarity.examples_score}/20      │
│  Constraints[{constraint_bar}] {clarity.constraints_score}/15      │
│                                            │
│  TOTAL: {total}/100                            │
│                                            │
│  {'✓ BON PROMPT' if total >= 60 else '⚠ A AMELIORER' if total >= 30 else '✗ TROP VAGUE'}                              │
└────────────────────────────────────────────┘
"""
        return model.strip()


# Singleton instance for convenience
_analyzer: Optional[PromptAnalyzer] = None


def get_analyzer() -> PromptAnalyzer:
    """Get or create the singleton analyzer instance."""
    global _analyzer
    if _analyzer is None:
        _analyzer = PromptAnalyzer()
    return _analyzer
