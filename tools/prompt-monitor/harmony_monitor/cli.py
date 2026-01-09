"""
CLI entry point for Harmony Prompt Monitor.

Usage:
    harmony-monitor serve [--port PORT]    Start the web server
    harmony-monitor mcp                    Start as MCP server
    harmony-monitor analyze <prompt>       Analyze a prompt
"""

import argparse
import asyncio
import sys


def main():
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(
        description="Harmony Prompt Monitor - Analyze prompt effectiveness"
    )
    subparsers = parser.add_subparsers(dest="command", help="Commands")

    # serve command
    serve_parser = subparsers.add_parser("serve", help="Start web server")
    serve_parser.add_argument(
        "--port", "-p",
        type=int,
        default=8080,
        help="Port to listen on (default: 8080)"
    )
    serve_parser.add_argument(
        "--host",
        type=str,
        default="127.0.0.1",
        help="Host to bind to (default: 127.0.0.1)"
    )
    serve_parser.add_argument(
        "--reload",
        action="store_true",
        help="Enable auto-reload for development"
    )

    # mcp command
    subparsers.add_parser("mcp", help="Start as MCP server")

    # analyze command
    analyze_parser = subparsers.add_parser("analyze", help="Analyze a prompt")
    analyze_parser.add_argument("prompt", help="Prompt text to analyze")
    analyze_parser.add_argument(
        "--response", "-r",
        type=str,
        default="",
        help="Optional response text"
    )

    # stats command
    stats_parser = subparsers.add_parser("stats", help="Show session statistics")
    stats_parser.add_argument(
        "--days", "-d",
        type=int,
        default=7,
        help="Number of days to analyze (default: 7)"
    )

    args = parser.parse_args()

    if args.command == "serve":
        run_server(args.host, args.port, args.reload)
    elif args.command == "mcp":
        run_mcp()
    elif args.command == "analyze":
        asyncio.run(analyze_prompt(args.prompt, args.response))
    elif args.command == "stats":
        asyncio.run(show_stats(args.days))
    else:
        parser.print_help()
        sys.exit(1)


def run_server(host: str, port: int, reload: bool):
    """Start the FastAPI server."""
    try:
        import uvicorn
    except ImportError:
        print("Error: uvicorn not installed. Run: pip install uvicorn[standard]")
        sys.exit(1)

    print(f"Starting Harmony Prompt Monitor on http://{host}:{port}")
    uvicorn.run(
        "harmony_monitor.api:app",
        host=host,
        port=port,
        reload=reload,
    )


def run_mcp():
    """Start the MCP server."""
    from .server import main as mcp_main
    mcp_main()


async def analyze_prompt(prompt: str, response: str):
    """Analyze a prompt and print results."""
    from .analyzer import get_analyzer

    analyzer = get_analyzer()
    analysis = analyzer.analyze(
        prompt=prompt,
        response=response,
        cost_usd=0,
        response_tokens=len(response) // 4
    )

    print("\n" + "=" * 60)
    print("PROMPT ANALYSIS")
    print("=" * 60)
    print()
    print(f"Prompt Clarity Score:    {analysis.prompt_clarity_score}/100")
    print(f"Response Quality Score:  {analysis.response_quality_score}/100")
    print(f"Alignment Score:         {analysis.alignment_score}/100")
    print(f"Category:                {analysis.alignment_category.value.upper()}")
    print()
    print("Suggestion:")
    print(f"  {analysis.suggestion}")
    print()

    print("Clarity Breakdown:")
    for key, value in analysis.clarity_breakdown.items():
        print(f"  {key}: {value}")
    print()

    if response:
        print("Quality Breakdown:")
        for key, value in analysis.quality_breakdown.items():
            print(f"  {key}: {value}")
        print()


async def show_stats(days: int):
    """Show session statistics."""
    from .db import get_database

    db = await get_database()

    try:
        session_id = await db.get_or_create_session()
        stats = await db.get_session_stats(session_id)
        trends = await db.get_trends(days)
        insights = await db.get_insights(days)

        print("\n" + "=" * 60)
        print("HARMONY PROMPT MONITOR - Statistics")
        print("=" * 60)
        print()
        print(f"Session: {session_id}")
        print(f"Period:  Last {days} days")
        print()
        print("Session Stats:")
        print(f"  Total Requests:    {stats.total_requests}")
        print()
        print("Average Scores:")
        print(f"  Prompt Clarity:    {stats.avg_prompt_clarity:.1f}/100")
        print(f"  Response Quality:  {stats.avg_response_quality:.1f}/100")
        print(f"  Alignment:         {stats.avg_alignment:.1f}/100")
        print()
        print("Category Breakdown:")
        print(f"  Optimal:    {stats.optimal_count}")
        print(f"  Impressive: {stats.impressive_count}")
        print(f"  Problem:    {stats.problem_count}")
        print(f"  Expected:   {stats.expected_count}")
        print()
        print("Trends:")
        print(f"  Clarity:  {insights.clarity_trend:+.1f}%")
        print(f"  Quality:  {insights.quality_trend:+.1f}%")
        print(f"  Cost:     {insights.cost_trend:+.1f}%")
        print()

        if insights.top_suggestions:
            print("Top Suggestions:")
            for i, tip in enumerate(insights.top_suggestions, 1):
                print(f"  {i}. {tip}")
            print()

    finally:
        await db.close()


if __name__ == "__main__":
    main()
