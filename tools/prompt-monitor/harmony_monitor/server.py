"""
MCP Server for Harmony Prompt Monitor.

This module provides MCP (Model Context Protocol) integration
for tracking LLM interactions directly from Claude Code.
"""

import asyncio
import json
import os
from datetime import datetime
from typing import Any, Optional

try:
    from mcp.server import Server
    from mcp.server.stdio import stdio_server
    from mcp.types import Tool, TextContent
    MCP_AVAILABLE = True
except ImportError:
    MCP_AVAILABLE = False
    Server = None

from .analyzer import get_analyzer
from .db import Database, get_database
from .models import RequestData


def create_mcp_server() -> Optional[Any]:
    """Create and configure the MCP server."""
    if not MCP_AVAILABLE:
        print("Warning: MCP not available. Install with: pip install mcp")
        return None

    server = Server("harmony-prompt-monitor")
    db: Optional[Database] = None

    @server.list_tools()
    async def list_tools() -> list[Tool]:
        """List available MCP tools."""
        return [
            Tool(
                name="track_prompt",
                description="Track and analyze a prompt-response pair",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "prompt": {
                            "type": "string",
                            "description": "The prompt text sent to the LLM"
                        },
                        "response": {
                            "type": "string",
                            "description": "The response received from the LLM"
                        },
                        "prompt_tokens": {
                            "type": "integer",
                            "description": "Number of input tokens"
                        },
                        "response_tokens": {
                            "type": "integer",
                            "description": "Number of output tokens"
                        },
                        "model": {
                            "type": "string",
                            "description": "Model used (e.g., claude-sonnet-4)"
                        },
                        "latency_ms": {
                            "type": "integer",
                            "description": "Response latency in milliseconds"
                        },
                        "cost_usd": {
                            "type": "number",
                            "description": "Cost in USD"
                        }
                    },
                    "required": ["prompt", "response"]
                }
            ),
            Tool(
                name="get_prompt_analysis",
                description="Analyze a prompt without recording it",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "prompt": {
                            "type": "string",
                            "description": "The prompt text to analyze"
                        },
                        "response": {
                            "type": "string",
                            "description": "The response to analyze"
                        }
                    },
                    "required": ["prompt"]
                }
            ),
            Tool(
                name="get_session_summary",
                description="Get summary of current monitoring session",
                inputSchema={
                    "type": "object",
                    "properties": {},
                    "required": []
                }
            ),
            Tool(
                name="get_improvement_tips",
                description="Get tips to improve prompt effectiveness",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "count": {
                            "type": "integer",
                            "description": "Number of tips to return",
                            "default": 5
                        }
                    },
                    "required": []
                }
            )
        ]

    @server.call_tool()
    async def call_tool(name: str, arguments: dict) -> list[TextContent]:
        """Handle tool calls."""
        nonlocal db

        # Ensure database is connected
        if db is None:
            db = await get_database()

        if name == "track_prompt":
            return await _track_prompt(db, arguments)
        elif name == "get_prompt_analysis":
            return await _analyze_prompt(arguments)
        elif name == "get_session_summary":
            return await _get_summary(db)
        elif name == "get_improvement_tips":
            return await _get_tips(db, arguments.get("count", 5))
        else:
            return [TextContent(type="text", text=f"Unknown tool: {name}")]

    return server


async def _track_prompt(db: Database, args: dict) -> list:
    """Track a prompt-response pair."""
    from mcp.types import TextContent

    session_id = await db.get_or_create_session()

    data = RequestData(
        session_id=session_id,
        prompt_text=args["prompt"],
        response_text=args.get("response", ""),
        prompt_tokens=args.get("prompt_tokens", len(args["prompt"]) // 4),
        response_tokens=args.get("response_tokens", len(args.get("response", "")) // 4),
        model=args.get("model", "claude-sonnet-4"),
        latency_ms=args.get("latency_ms", 0),
        cost_usd=args.get("cost_usd", 0.0),
        timestamp=datetime.utcnow(),
    )

    request_id = await db.record_request(data)
    record = await db.get_request(request_id)

    result = {
        "request_id": request_id,
        "scores": {
            "prompt_clarity": record.prompt_clarity_score,
            "response_quality": record.response_quality_score,
            "alignment": record.alignment_score,
        },
        "category": record.alignment_category,
        "suggestion": record.suggestion,
    }

    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def _analyze_prompt(args: dict) -> list:
    """Analyze a prompt without recording."""
    from mcp.types import TextContent

    analyzer = get_analyzer()

    prompt = args["prompt"]
    response = args.get("response", "")

    analysis = analyzer.analyze(
        prompt=prompt,
        response=response,
        cost_usd=0,
        response_tokens=len(response) // 4
    )

    result = {
        "prompt_clarity_score": analysis.prompt_clarity_score,
        "response_quality_score": analysis.response_quality_score,
        "alignment_score": analysis.alignment_score,
        "alignment_category": analysis.alignment_category.value,
        "suggestion": analysis.suggestion,
        "breakdown": {
            "clarity": analysis.clarity_breakdown,
            "quality": analysis.quality_breakdown,
        }
    }

    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def _get_summary(db: Database) -> list:
    """Get session summary."""
    from mcp.types import TextContent

    session_id = await db.get_or_create_session()
    stats = await db.get_session_stats(session_id)
    insights = await db.get_insights(7)

    summary = f"""
HARMONY PROMPT MONITOR - Session Summary
========================================

Session: {session_id}
Total Requests: {stats.total_requests}
Total Cost: ${stats.total_cost:.4f}

Average Scores:
  Prompt Clarity:    {stats.avg_prompt_clarity:.1f}/100
  Response Quality:  {stats.avg_response_quality:.1f}/100
  Alignment:         {stats.avg_alignment:.1f}/100

Category Breakdown:
  Optimal:    {stats.optimal_count} ({_pct(stats.optimal_count, stats.total_requests)})
  Impressive: {stats.impressive_count} ({_pct(stats.impressive_count, stats.total_requests)})
  Problem:    {stats.problem_count} ({_pct(stats.problem_count, stats.total_requests)})
  Expected:   {stats.expected_count} ({_pct(stats.expected_count, stats.total_requests)})

Trends (7 days):
  Clarity:  {insights.clarity_trend:+.1f}%
  Quality:  {insights.quality_trend:+.1f}%
  Cost:     {insights.cost_trend:+.1f}%
"""

    return [TextContent(type="text", text=summary)]


async def _get_tips(db: Database, count: int) -> list:
    """Get improvement tips."""
    from mcp.types import TextContent

    insights = await db.get_insights(7)

    tips = insights.top_suggestions[:count]

    # Add general tips if we don't have enough
    general_tips = [
        "Ajoute du contexte a tes prompts: 'Given that...', 'In the context of...'",
        "Sois specifique: 'How do I X using Y?' plutot que 'How to X?'",
        "Fournis des exemples de ce que tu attends (input/output desire)",
        "Precise tes contraintes: 'must', 'should not', 'using only'...",
        "Pour les taches simples, utilise Haiku pour reduire les couts",
    ]

    while len(tips) < count and general_tips:
        tips.append(general_tips.pop(0))

    result = "IMPROVEMENT TIPS\n" + "=" * 40 + "\n\n"
    for i, tip in enumerate(tips, 1):
        result += f"{i}. {tip}\n\n"

    return [TextContent(type="text", text=result)]


def _pct(value: int, total: int) -> str:
    """Calculate percentage string."""
    if total == 0:
        return "0%"
    return f"{value / total * 100:.1f}%"


async def run_mcp_server():
    """Run the MCP server."""
    if not MCP_AVAILABLE:
        print("Error: MCP not available. Install with: pip install mcp")
        return

    server = create_mcp_server()
    if server is None:
        return

    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream)


def main():
    """Entry point for MCP server."""
    asyncio.run(run_mcp_server())


if __name__ == "__main__":
    main()
