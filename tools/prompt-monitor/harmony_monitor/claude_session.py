"""
Claude Code session parser for token usage statistics.

Parses the JSONL session files to extract token consumption data.
"""

import json
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Optional
from datetime import datetime


@dataclass
class ClaudeUsageStats:
    """Token usage statistics from Claude Code session."""
    input_tokens: int = 0
    output_tokens: int = 0
    cache_creation_tokens: int = 0
    cache_read_tokens: int = 0
    total_requests: int = 0
    session_id: str = ""
    project_path: str = ""

    @property
    def total_tokens(self) -> int:
        return self.input_tokens + self.output_tokens

    @property
    def effective_input_tokens(self) -> int:
        """Input tokens actually billed (excluding cache reads)."""
        return self.input_tokens + self.cache_creation_tokens

    @property
    def estimated_cost_usd(self) -> float:
        """Estimate cost based on Claude pricing (Opus 4.5 rates)."""
        # Opus 4.5 pricing per 1M tokens (as of 2025)
        INPUT_COST = 15.0 / 1_000_000  # $15 per 1M input
        OUTPUT_COST = 75.0 / 1_000_000  # $75 per 1M output
        CACHE_WRITE_COST = 18.75 / 1_000_000  # $18.75 per 1M cache write
        CACHE_READ_COST = 1.875 / 1_000_000  # $1.875 per 1M cache read

        cost = (
            self.input_tokens * INPUT_COST +
            self.output_tokens * OUTPUT_COST +
            self.cache_creation_tokens * CACHE_WRITE_COST +
            self.cache_read_tokens * CACHE_READ_COST
        )
        return round(cost, 4)


def get_claude_projects_dir() -> Path:
    """Get the Claude Code projects directory."""
    return Path.home() / ".claude" / "projects"


def find_current_session(project_path: Optional[str] = None) -> Optional[Path]:
    """
    Find the most recent session file for a project.

    Args:
        project_path: Project path to look for. If None, uses current working directory.

    Returns:
        Path to the session JSONL file, or None if not found.
    """
    if project_path is None:
        project_path = os.getcwd()

    # Claude Code encodes project paths with dashes
    encoded_path = project_path.replace("/", "-")
    if encoded_path.startswith("-"):
        encoded_path = encoded_path[1:]  # Remove leading dash

    projects_dir = get_claude_projects_dir()
    project_dir = projects_dir / encoded_path

    if not project_dir.exists():
        # Try to find by partial match
        for d in projects_dir.iterdir():
            if d.is_dir() and encoded_path in d.name:
                project_dir = d
                break
        else:
            return None

    # Find most recent session file
    session_files = list(project_dir.glob("*.jsonl"))
    if not session_files:
        return None

    # Sort by modification time, newest first
    session_files.sort(key=lambda f: f.stat().st_mtime, reverse=True)

    return session_files[0]


def parse_session_file(session_path: Path) -> ClaudeUsageStats:
    """
    Parse a Claude Code session JSONL file for usage statistics.

    Args:
        session_path: Path to the session JSONL file.

    Returns:
        ClaudeUsageStats with aggregated token counts.
    """
    stats = ClaudeUsageStats()
    stats.session_id = session_path.stem

    seen_request_ids = set()

    with open(session_path, 'r') as f:
        for line in f:
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue

            # Only process assistant messages with usage data
            if entry.get("type") != "assistant":
                continue

            message = entry.get("message", {})
            usage = message.get("usage", {})

            if not usage:
                continue

            # Deduplicate by request ID (same request can appear multiple times)
            request_id = entry.get("requestId")
            if request_id and request_id in seen_request_ids:
                continue
            if request_id:
                seen_request_ids.add(request_id)

            # Aggregate tokens
            stats.input_tokens += usage.get("input_tokens", 0)
            stats.output_tokens += usage.get("output_tokens", 0)
            stats.cache_creation_tokens += usage.get("cache_creation_input_tokens", 0)
            stats.cache_read_tokens += usage.get("cache_read_input_tokens", 0)
            stats.total_requests += 1

    return stats


def get_current_session_stats(project_path: Optional[str] = None) -> Optional[ClaudeUsageStats]:
    """
    Get usage statistics for the current Claude Code session.

    Args:
        project_path: Project path. Defaults to current working directory.

    Returns:
        ClaudeUsageStats or None if no session found.
    """
    session_path = find_current_session(project_path)

    if session_path is None:
        return None

    stats = parse_session_file(session_path)
    stats.project_path = project_path or os.getcwd()

    return stats


def get_all_sessions_stats(project_path: Optional[str] = None) -> list[ClaudeUsageStats]:
    """
    Get usage statistics for all sessions of a project.

    Args:
        project_path: Project path. Defaults to current working directory.

    Returns:
        List of ClaudeUsageStats for each session.
    """
    if project_path is None:
        project_path = os.getcwd()

    # Claude Code encodes project paths with dashes
    encoded_path = project_path.replace("/", "-")
    if encoded_path.startswith("-"):
        encoded_path = encoded_path[1:]

    projects_dir = get_claude_projects_dir()
    project_dir = projects_dir / encoded_path

    if not project_dir.exists():
        return []

    results = []
    for session_file in project_dir.glob("*.jsonl"):
        if session_file.name.startswith("agent-"):
            continue  # Skip agent files

        stats = parse_session_file(session_file)
        stats.project_path = project_path
        results.append(stats)

    # Sort by total tokens descending
    results.sort(key=lambda s: s.total_tokens, reverse=True)

    return results
