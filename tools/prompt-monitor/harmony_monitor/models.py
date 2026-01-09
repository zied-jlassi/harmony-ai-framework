"""
Pydantic models for Harmony Prompt Monitor.
"""

from datetime import datetime
from enum import Enum
from typing import Optional
from pydantic import BaseModel, Field


class AlignmentCategory(str, Enum):
    """Categories for prompt-response alignment."""
    OPTIMAL = "optimal"           # Clear prompt + Clear response
    IMPRESSIVE = "impressive"     # Vague prompt + Clear response
    PROBLEM = "problem"           # Clear prompt + Vague response
    EXPECTED = "expected"         # Vague prompt + Vague response


class AnalysisResult(BaseModel):
    """Result of analyzing a prompt-response pair."""
    prompt_clarity_score: int = Field(ge=0, le=100)
    response_quality_score: int = Field(ge=0, le=100)
    alignment_score: int = Field(ge=0, le=100)
    alignment_category: AlignmentCategory
    cost_efficiency: float = Field(ge=0)
    suggestion: str

    # Detailed breakdown
    clarity_breakdown: dict = Field(default_factory=dict)
    quality_breakdown: dict = Field(default_factory=dict)


class TrackInput(BaseModel):
    """Simplified input for tracking a request via API."""
    prompt: str = Field(description="The prompt text sent to LLM")
    response: str = Field(description="The response received from LLM")
    cost_usd: float = Field(ge=0, default=0.0, description="Cost in USD")
    response_tokens: int = Field(ge=0, default=0, description="Output tokens")
    prompt_tokens: int = Field(ge=0, default=0, description="Input tokens")
    latency_ms: int = Field(ge=0, default=0, description="Response latency")
    model: str = Field(default="claude-sonnet-4", description="Model used")
    session_id: Optional[str] = Field(default=None, description="Session ID (auto-created if not provided)")
    agent: Optional[str] = Field(default=None, description="Agent name if applicable")
    tool_name: Optional[str] = Field(default=None, description="Tool name if applicable")


class RequestData(BaseModel):
    """Data for a single LLM request."""
    session_id: str
    prompt_text: str
    response_text: str
    prompt_tokens: int = Field(ge=0)
    response_tokens: int = Field(ge=0)
    model: str = "claude-sonnet-4"
    latency_ms: int = Field(ge=0)
    cost_usd: float = Field(ge=0)
    timestamp: datetime = Field(default_factory=datetime.utcnow)

    # Optional metadata
    agent: Optional[str] = None
    tool_name: Optional[str] = None
    project_path: Optional[str] = None


class RequestRecord(BaseModel):
    """Full record of a request with analysis."""
    id: int
    session_id: str
    timestamp: datetime

    # Request data
    prompt_text: str
    prompt_tokens: int
    response_text: str
    response_tokens: int
    model: str
    latency_ms: int
    cost_usd: float

    # Analysis results
    prompt_clarity_score: int
    response_quality_score: int
    alignment_score: int
    alignment_category: str
    suggestion: str

    # Metadata
    agent: Optional[str] = None
    tool_name: Optional[str] = None


class SessionData(BaseModel):
    """Data for a monitoring session."""
    id: str
    started_at: datetime
    project_path: Optional[str] = None
    total_requests: int = 0
    avg_prompt_clarity: float = 0.0
    avg_response_quality: float = 0.0
    avg_alignment: float = 0.0


class SessionStats(BaseModel):
    """Statistics for a session."""
    session_id: str
    total_requests: int
    total_prompt_tokens: int
    total_response_tokens: int
    avg_latency_ms: float
    avg_prompt_clarity: float
    avg_response_quality: float
    avg_alignment: float

    # Category breakdown
    optimal_count: int = 0
    impressive_count: int = 0
    problem_count: int = 0
    expected_count: int = 0


class TrendData(BaseModel):
    """Trend data over time."""
    period: str  # "7d", "30d", etc.
    dates: list[str]
    prompt_clarity: list[float]
    response_quality: list[float]
    alignment: list[float]
    daily_cost: list[float]
    daily_requests: list[int]


class InsightData(BaseModel):
    """Insights and recommendations."""
    most_expensive_category: str
    most_expensive_avg_cost: float
    most_efficient_category: str
    most_efficient_score: float
    clarity_trend: float  # % change vs previous period
    quality_trend: float
    cost_trend: float
    top_suggestions: list[str]


class DashboardData(BaseModel):
    """Complete data for dashboard display."""
    current_session: SessionStats
    latest_request: Optional[RequestRecord] = None
    trends: TrendData
    insights: InsightData
