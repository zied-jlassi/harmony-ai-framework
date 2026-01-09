"""
FastAPI REST API for Harmony Prompt Monitor.

Provides endpoints for:
- Dashboard data
- Request tracking
- Session management
- Statistics and trends
"""

import os
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.staticfiles import StaticFiles

from .db import Database, get_database
from .models import (
    RequestData,
    RequestRecord,
    SessionData,
    SessionStats,
    TrendData,
    InsightData,
    DashboardData,
    TrackInput,
)

# Create FastAPI app
app = FastAPI(
    title="Harmony Prompt Monitor",
    description="Monitor and analyze prompt effectiveness",
    version="0.1.0",
)

# Static files directory
STATIC_DIR = Path(__file__).parent / "static"


# Mount static files if directory exists
if STATIC_DIR.exists():
    app.mount("/static", StaticFiles(directory=str(STATIC_DIR)), name="static")


# =========================================================================
# Dashboard
# =========================================================================

@app.get("/", response_class=HTMLResponse)
async def dashboard():
    """Serve the main dashboard page."""
    index_path = STATIC_DIR / "index.html"
    if index_path.exists():
        return FileResponse(index_path)

    # Fallback simple dashboard
    return HTMLResponse(content="""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Harmony Prompt Monitor</title>
        <style>
            body { font-family: monospace; background: #1a1a2e; color: #eee; padding: 20px; }
            .container { max-width: 900px; margin: 0 auto; }
            h1 { color: #00d4ff; }
            .card { background: #16213e; padding: 20px; margin: 10px 0; border-radius: 8px; }
            .metric { display: inline-block; margin: 10px 20px; text-align: center; }
            .metric-value { font-size: 2em; color: #00d4ff; }
            .metric-label { color: #888; }
            pre { background: #0f0f23; padding: 15px; border-radius: 5px; overflow-x: auto; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>HARMONY PROMPT MONITOR</h1>
            <div class="card">
                <h2>API Status: Online</h2>
                <p>Dashboard UI coming soon. Use the API endpoints:</p>
                <ul>
                    <li><code>GET /api/sessions</code> - List sessions</li>
                    <li><code>GET /api/requests</code> - List requests</li>
                    <li><code>GET /api/stats/{session_id}</code> - Session stats</li>
                    <li><code>GET /api/trends</code> - Trend data</li>
                    <li><code>POST /api/track</code> - Record request</li>
                </ul>
            </div>
            <div class="card">
                <h3>Quick Test</h3>
                <pre id="test-output">Loading...</pre>
            </div>
        </div>
        <script>
            fetch('/api/sessions')
                .then(r => r.json())
                .then(data => {
                    document.getElementById('test-output').textContent =
                        JSON.stringify(data, null, 2);
                })
                .catch(e => {
                    document.getElementById('test-output').textContent =
                        'Error: ' + e.message;
                });
        </script>
    </body>
    </html>
    """)


@app.get("/api/dashboard")
async def get_dashboard_data(session_id: Optional[str] = None) -> DashboardData:
    """Get complete dashboard data for display."""
    db = await get_database()

    # Get or create session
    if session_id is None:
        session_id = await db.get_or_create_session()

    # Get all dashboard components
    stats = await db.get_session_stats(session_id)
    latest = await db.get_latest_request(session_id)
    trends = await db.get_trends(7)
    insights = await db.get_insights(7)

    return DashboardData(
        current_session=stats,
        latest_request=latest,
        trends=trends,
        insights=insights,
    )


# =========================================================================
# Sessions
# =========================================================================

@app.get("/api/sessions")
async def list_sessions(limit: int = Query(default=10, le=100)) -> list[SessionData]:
    """List recent monitoring sessions."""
    db = await get_database()
    return await db.list_sessions(limit)


@app.get("/api/sessions/{session_id}")
async def get_session(session_id: str) -> SessionData:
    """Get session details by ID."""
    db = await get_database()
    session = await db.get_session(session_id)

    if session is None:
        raise HTTPException(status_code=404, detail="Session not found")

    return session


@app.post("/api/sessions")
async def create_session(project_path: Optional[str] = None) -> dict:
    """Create a new monitoring session."""
    db = await get_database()
    session_id = await db.create_session(project_path)
    return {"session_id": session_id}


# =========================================================================
# Requests
# =========================================================================

@app.get("/api/requests")
async def list_requests(
    session_id: Optional[str] = None,
    limit: int = Query(default=50, le=200),
    offset: int = Query(default=0, ge=0),
    type: Optional[str] = None,
    category: Optional[str] = None,
    time: Optional[str] = None,
) -> list[RequestRecord]:
    """List requests with optional filters."""
    db = await get_database()
    return await db.list_requests(session_id, limit, offset, type, category, time)


@app.get("/api/requests/{request_id}")
async def get_request(request_id: int) -> RequestRecord:
    """Get request details by ID."""
    db = await get_database()
    request = await db.get_request(request_id)

    if request is None:
        raise HTTPException(status_code=404, detail="Request not found")

    return request


@app.post("/api/track")
async def track_request(input_data: TrackInput) -> dict:
    """
    Track a new request and analyze it.

    This is the main endpoint for recording LLM interactions.
    Only `prompt` and `response` are required, all other fields have defaults.
    """
    db = await get_database()

    # Get or create session
    if input_data.session_id:
        session = await db.get_session(input_data.session_id)
        if session is None:
            session_id = await db.create_session()
        else:
            session_id = input_data.session_id
    else:
        session_id = await db.get_or_create_session()

    # Convert TrackInput to RequestData
    data = RequestData(
        session_id=session_id,
        prompt_text=input_data.prompt,
        response_text=input_data.response,
        prompt_tokens=input_data.prompt_tokens,
        response_tokens=input_data.response_tokens,
        model=input_data.model,
        latency_ms=input_data.latency_ms,
        cost_usd=input_data.cost_usd,
        agent=input_data.agent,
        tool_name=input_data.tool_name,
    )

    # Record and analyze
    request_id = await db.record_request(data)

    # Get the analysis result
    record = await db.get_request(request_id)

    return {
        "request_id": request_id,
        "prompt_clarity_score": record.prompt_clarity_score,
        "response_quality_score": record.response_quality_score,
        "alignment_score": record.alignment_score,
        "alignment_category": record.alignment_category,
        "suggestion": record.suggestion,
    }


# =========================================================================
# Statistics
# =========================================================================

@app.get("/api/stats/{session_id}")
async def get_session_stats(session_id: str) -> SessionStats:
    """Get comprehensive statistics for a session."""
    db = await get_database()
    return await db.get_session_stats(session_id)


@app.get("/api/trends")
async def get_trends(days: int = Query(default=7, le=90)) -> TrendData:
    """Get trend data for the specified period."""
    db = await get_database()
    return await db.get_trends(days)


@app.get("/api/insights")
async def get_insights(days: int = Query(default=7, le=90)) -> InsightData:
    """Get insights and recommendations."""
    db = await get_database()
    return await db.get_insights(days)


# =========================================================================
# Health Check
# =========================================================================

@app.get("/health")
async def health_check() -> dict:
    """Health check endpoint."""
    return {
        "status": "healthy",
        "service": "harmony-prompt-monitor",
        "version": "0.1.0",
    }


@app.delete("/api/reset")
async def reset_all_data(confirm: bool = False) -> dict:
    """
    Reset all monitoring data (sessions, requests, stats).

    Requires confirm=true query parameter to actually delete.
    """
    if not confirm:
        return {
            "warning": "This will delete ALL monitoring data!",
            "action": "Add ?confirm=true to proceed",
            "confirm_required": True
        }

    db = await get_database()

    # Delete all data
    await db._connection.execute("DELETE FROM requests")
    await db._connection.execute("DELETE FROM sessions")
    await db._connection.commit()

    # Reset singleton to force new session
    from . import db as db_module
    db_module._db = None

    return {
        "status": "success",
        "message": "All monitoring data has been reset",
        "confirm_required": False
    }


@app.get("/api/requests/{request_id}/detail")
async def get_request_detail(request_id: int) -> dict:
    """
    Get detailed analysis for a specific request.

    Includes full prompt/response text, breakdown scores, and improvement suggestions.
    """
    db = await get_database()
    record = await db.get_request(request_id)

    if record is None:
        raise HTTPException(status_code=404, detail="Request not found")

    # Get detailed analysis
    from .analyzer import get_analyzer
    analyzer = get_analyzer()

    # Re-analyze for detailed breakdown
    clarity_score, clarity_breakdown = analyzer.calculate_prompt_clarity(record.prompt_text)
    quality_score, quality_breakdown = analyzer.calculate_response_quality(
        record.response_text, record.prompt_text
    )

    # Generate improved prompt suggestion
    improved_prompt = analyzer.generate_improved_prompt(
        record.prompt_text, clarity_breakdown
    )

    # Generate learning insights
    learning_insights = analyzer.generate_learning_insights(
        record.prompt_text,
        record.response_text,
        clarity_breakdown,
        quality_breakdown
    )

    # Calculate efficiency (quality/clarity ratio)
    efficiency = round((quality_score / max(clarity_score, 1)) * 100)

    return {
        "id": record.id,
        "timestamp": record.timestamp.isoformat(),
        "prompt_text": record.prompt_text,  # Full text
        "response_text": record.response_text,  # Full text
        "model": record.model,
        "cost_usd": record.cost_usd,
        "prompt_tokens": record.prompt_tokens,
        "response_tokens": record.response_tokens,
        "latency_ms": record.latency_ms,
        "clarity": {
            "score": clarity_score,
            "breakdown": {
                "length": {"score": clarity_breakdown.length_score, "max": 20},
                "context": {"score": clarity_breakdown.context_score, "max": 20},
                "specificity": {"score": clarity_breakdown.specificity_score, "max": 25},
                "examples": {"score": clarity_breakdown.examples_score, "max": 20},
                "constraints": {"score": clarity_breakdown.constraints_score, "max": 15},
            }
        },
        "quality": {
            "score": quality_score,
            "breakdown": {
                "completeness": {"score": quality_breakdown.completeness_score, "max": 30},
                "structure": {"score": quality_breakdown.structure_score, "max": 30},
                "concreteness": {"score": quality_breakdown.concreteness_score, "max": 25},
                "vagueness_penalty": {"score": -quality_breakdown.vagueness_penalty, "max": 0},
            }
        },
        "alignment_score": record.alignment_score,
        "alignment_category": record.alignment_category,
        "suggestion": record.suggestion,
        "improved_prompt": improved_prompt,
        "efficiency_percent": efficiency,
        "learning": learning_insights,
    }


# =========================================================================
# Startup/Shutdown
# =========================================================================

@app.on_event("startup")
async def startup():
    """Initialize database on startup."""
    await get_database()


@app.on_event("shutdown")
async def shutdown():
    """Close database on shutdown."""
    from .db import _db
    if _db is not None:
        await _db.close()
