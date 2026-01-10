"""
Database layer for Harmony Prompt Monitor.

Uses SQLite with aiosqlite for async operations.
"""

import os
import uuid
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional

import aiosqlite

from .models import (
    AlignmentCategory,
    RequestData,
    RequestRecord,
    SessionData,
    SessionStats,
    TrendData,
    InsightData,
)
from .analyzer import get_analyzer


class Database:
    """Async SQLite database manager."""

    SCHEMA = """
    CREATE TABLE IF NOT EXISTS sessions (
        id TEXT PRIMARY KEY,
        started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        project_path TEXT,
        total_requests INTEGER DEFAULT 0,
        avg_prompt_clarity REAL DEFAULT 0,
        avg_response_quality REAL DEFAULT 0,
        avg_alignment REAL DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,

        -- Prompt data
        prompt_text TEXT,
        prompt_tokens INTEGER,
        prompt_clarity_score INTEGER,

        -- Response data
        response_text TEXT,
        response_tokens INTEGER,
        response_quality_score INTEGER,

        -- Metrics
        latency_ms INTEGER,
        cost_usd REAL,
        model TEXT,

        -- Alignment
        alignment_score INTEGER,
        alignment_category TEXT,
        suggestion TEXT,

        -- Metadata
        agent TEXT,
        tool_name TEXT,

        FOREIGN KEY (session_id) REFERENCES sessions(id)
    );

    CREATE INDEX IF NOT EXISTS idx_requests_session ON requests(session_id);
    CREATE INDEX IF NOT EXISTS idx_requests_timestamp ON requests(timestamp);
    CREATE INDEX IF NOT EXISTS idx_requests_category ON requests(alignment_category);
    """

    def __init__(self, db_path: Optional[str] = None):
        """
        Initialize database.

        Args:
            db_path: Path to SQLite database file. Defaults to .harmony/monitor/data.db
        """
        if db_path is None:
            harmony_dir = os.environ.get("HARMONY_DIR", ".harmony")
            db_path = os.path.join(harmony_dir, "monitor", "data.db")

        self.db_path = Path(db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._connection: Optional[aiosqlite.Connection] = None

    async def connect(self) -> None:
        """Connect to database and ensure schema exists."""
        self._connection = await aiosqlite.connect(self.db_path)
        self._connection.row_factory = aiosqlite.Row
        await self._connection.executescript(self.SCHEMA)
        await self._connection.commit()

    async def close(self) -> None:
        """Close database connection."""
        if self._connection:
            await self._connection.close()
            self._connection = None

    async def __aenter__(self):
        await self.connect()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.close()

    # =========================================================================
    # Session Management
    # =========================================================================

    async def create_session(self, project_path: Optional[str] = None) -> str:
        """Create a new monitoring session."""
        session_id = f"session-{datetime.now().strftime('%Y%m%d-%H%M%S')}-{uuid.uuid4().hex[:8]}"

        await self._connection.execute(
            "INSERT INTO sessions (id, project_path) VALUES (?, ?)",
            (session_id, project_path)
        )
        await self._connection.commit()

        return session_id

    async def get_session(self, session_id: str) -> Optional[SessionData]:
        """Get session by ID."""
        cursor = await self._connection.execute(
            "SELECT * FROM sessions WHERE id = ?",
            (session_id,)
        )
        row = await cursor.fetchone()

        if row is None:
            return None

        return SessionData(
            id=row["id"],
            started_at=datetime.fromisoformat(row["started_at"]),
            project_path=row["project_path"],
            total_requests=row["total_requests"],
            avg_prompt_clarity=row["avg_prompt_clarity"],
            avg_response_quality=row["avg_response_quality"],
            avg_alignment=row["avg_alignment"],
        )

    async def get_or_create_session(self, project_path: Optional[str] = None) -> str:
        """Get latest session or create new one if none exists today."""
        today = datetime.now().strftime("%Y-%m-%d")

        cursor = await self._connection.execute(
            """SELECT id FROM sessions
               WHERE date(started_at) = date(?)
               ORDER BY started_at DESC LIMIT 1""",
            (today,)
        )
        row = await cursor.fetchone()

        if row:
            return row["id"]

        return await self.create_session(project_path)

    async def list_sessions(self, limit: int = 10) -> list[SessionData]:
        """List recent sessions."""
        cursor = await self._connection.execute(
            "SELECT * FROM sessions ORDER BY started_at DESC LIMIT ?",
            (limit,)
        )
        rows = await cursor.fetchall()

        return [
            SessionData(
                id=row["id"],
                started_at=datetime.fromisoformat(row["started_at"]),
                project_path=row["project_path"],
                total_requests=row["total_requests"],
                avg_prompt_clarity=row["avg_prompt_clarity"],
                avg_response_quality=row["avg_response_quality"],
                avg_alignment=row["avg_alignment"],
            )
            for row in rows
        ]

    # =========================================================================
    # Request Management
    # =========================================================================

    async def record_request(self, data: RequestData) -> int:
        """
        Record a new request with automatic analysis.

        Returns:
            The ID of the created record
        """
        # Check if this is a tool call (starts with [ToolName] but NOT [User])
        is_tool_call = (
            data.prompt_text.startswith("[") and
            "]" in data.prompt_text[:20] and
            not data.prompt_text.startswith("[User]")
        )

        if is_tool_call:
            # Skip detailed analysis for tool calls - use neutral scores
            from .models import AlignmentCategory
            class ToolAnalysis:
                prompt_clarity_score = 50
                response_quality_score = 50
                alignment_score = 50
                alignment_category = AlignmentCategory.EXPECTED
                suggestion = "Tool call - no analysis needed"
            analysis = ToolAnalysis()
        else:
            # Full analysis for user prompts
            analyzer = get_analyzer()
            # Strip [User] prefix if present for analysis
            prompt_for_analysis = data.prompt_text
            if prompt_for_analysis.startswith("[User] "):
                prompt_for_analysis = prompt_for_analysis[7:]
            analysis = analyzer.analyze(
                prompt=prompt_for_analysis,
                response=data.response_text,
                cost_usd=data.cost_usd,
                response_tokens=data.response_tokens
            )

        # Insert request
        cursor = await self._connection.execute(
            """INSERT INTO requests (
                session_id, timestamp,
                prompt_text, prompt_tokens, prompt_clarity_score,
                response_text, response_tokens, response_quality_score,
                latency_ms, cost_usd, model,
                alignment_score, alignment_category, suggestion,
                agent, tool_name
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (
                data.session_id,
                data.timestamp.isoformat(),
                data.prompt_text,
                data.prompt_tokens,
                analysis.prompt_clarity_score,
                data.response_text,
                data.response_tokens,
                analysis.response_quality_score,
                data.latency_ms,
                data.cost_usd,
                data.model,
                analysis.alignment_score,
                analysis.alignment_category.value,
                analysis.suggestion,
                data.agent,
                data.tool_name,
            )
        )

        request_id = cursor.lastrowid

        # Update session stats
        await self._update_session_stats(data.session_id)

        await self._connection.commit()

        return request_id

    async def get_request(self, request_id: int) -> Optional[RequestRecord]:
        """Get request by ID."""
        cursor = await self._connection.execute(
            "SELECT * FROM requests WHERE id = ?",
            (request_id,)
        )
        row = await cursor.fetchone()

        if row is None:
            return None

        return self._row_to_request_record(row)

    async def list_requests(
        self,
        session_id: Optional[str] = None,
        limit: int = 50,
        offset: int = 0,
        prompt_type: Optional[str] = None,
        category: Optional[str] = None,
        time_filter: Optional[str] = None
    ) -> list[RequestRecord]:
        """List requests with optional filters."""
        from datetime import datetime, timedelta

        conditions = []
        params = []

        if session_id:
            conditions.append("session_id = ?")
            params.append(session_id)

        if prompt_type:
            conditions.append("prompt_text LIKE ?")
            params.append(f"[{prompt_type}]%")

        if category:
            conditions.append("alignment_category = ?")
            params.append(category)

        if time_filter:
            now = datetime.utcnow()
            if time_filter == "1h":
                since = now - timedelta(hours=1)
            elif time_filter == "24h":
                since = now - timedelta(hours=24)
            elif time_filter == "7d":
                since = now - timedelta(days=7)
            elif time_filter == "30d":
                since = now - timedelta(days=30)
            else:
                since = None
            if since:
                conditions.append("timestamp >= ?")
                params.append(since.isoformat())

        where_clause = " AND ".join(conditions) if conditions else "1=1"
        query = f"""SELECT * FROM requests
                    WHERE {where_clause}
                    ORDER BY timestamp DESC
                    LIMIT ? OFFSET ?"""
        params.extend([limit, offset])

        cursor = await self._connection.execute(query, params)
        rows = await cursor.fetchall()
        return [self._row_to_request_record(row) for row in rows]

    async def get_latest_request(self, session_id: str) -> Optional[RequestRecord]:
        """Get the most recent request for a session."""
        cursor = await self._connection.execute(
            """SELECT * FROM requests
               WHERE session_id = ?
               ORDER BY timestamp DESC
               LIMIT 1""",
            (session_id,)
        )
        row = await cursor.fetchone()

        if row is None:
            return None

        return self._row_to_request_record(row)

    # =========================================================================
    # Statistics
    # =========================================================================

    async def get_session_stats(self, session_id: str) -> SessionStats:
        """Get comprehensive statistics for a session."""
        cursor = await self._connection.execute(
            """SELECT
                COUNT(*) as total_requests,
                COALESCE(SUM(prompt_tokens), 0) as total_prompt_tokens,
                COALESCE(SUM(response_tokens), 0) as total_response_tokens,
                COALESCE(AVG(latency_ms), 0) as avg_latency_ms,
                COALESCE(AVG(prompt_clarity_score), 0) as avg_prompt_clarity,
                COALESCE(AVG(response_quality_score), 0) as avg_response_quality,
                COALESCE(AVG(alignment_score), 0) as avg_alignment,
                SUM(CASE WHEN alignment_category = 'optimal' THEN 1 ELSE 0 END) as optimal_count,
                SUM(CASE WHEN alignment_category = 'impressive' THEN 1 ELSE 0 END) as impressive_count,
                SUM(CASE WHEN alignment_category = 'problem' THEN 1 ELSE 0 END) as problem_count,
                SUM(CASE WHEN alignment_category = 'expected' THEN 1 ELSE 0 END) as expected_count
               FROM requests
               WHERE session_id = ?""",
            (session_id,)
        )
        row = await cursor.fetchone()

        total = row["total_requests"] or 0

        return SessionStats(
            session_id=session_id,
            total_requests=total,
            total_prompt_tokens=row["total_prompt_tokens"] or 0,
            total_response_tokens=row["total_response_tokens"] or 0,
            avg_latency_ms=row["avg_latency_ms"] or 0,
            avg_prompt_clarity=row["avg_prompt_clarity"] or 0,
            avg_response_quality=row["avg_response_quality"] or 0,
            avg_alignment=row["avg_alignment"] or 0,
            optimal_count=row["optimal_count"] or 0,
            impressive_count=row["impressive_count"] or 0,
            problem_count=row["problem_count"] or 0,
            expected_count=row["expected_count"] or 0,
        )

    async def get_trends(self, days: int = 7) -> TrendData:
        """Get trend data for the specified number of days."""
        start_date = datetime.now() - timedelta(days=days)

        cursor = await self._connection.execute(
            """SELECT
                date(timestamp) as date,
                AVG(prompt_clarity_score) as avg_clarity,
                AVG(response_quality_score) as avg_quality,
                AVG(alignment_score) as avg_alignment,
                SUM(cost_usd) as daily_cost,
                COUNT(*) as daily_requests
               FROM requests
               WHERE timestamp >= ?
               GROUP BY date(timestamp)
               ORDER BY date(timestamp)""",
            (start_date.isoformat(),)
        )
        rows = await cursor.fetchall()

        dates = []
        clarity = []
        quality = []
        alignment = []
        costs = []
        requests = []

        for row in rows:
            dates.append(row["date"])
            clarity.append(row["avg_clarity"] or 0)
            quality.append(row["avg_quality"] or 0)
            alignment.append(row["avg_alignment"] or 0)
            costs.append(row["daily_cost"] or 0)
            requests.append(row["daily_requests"] or 0)

        return TrendData(
            period=f"{days}d",
            dates=dates,
            prompt_clarity=clarity,
            response_quality=quality,
            alignment=alignment,
            daily_cost=costs,
            daily_requests=requests,
        )

    async def get_learning_tips(self, days: int = 7) -> dict:
        """
        Generate learning tips based on real patterns from accumulated data.

        Analyzes:
        - Common issues in low-clarity prompts
        - Patterns from successful prompts
        - Most frequent suggestions
        - Category-specific insights
        """
        start_date = datetime.now() - timedelta(days=days)
        tips = []

        # Get stats summary
        cursor = await self._connection.execute(
            """SELECT
                COUNT(*) as total,
                AVG(prompt_clarity_score) as avg_clarity,
                AVG(response_quality_score) as avg_quality,
                AVG(alignment_score) as avg_alignment,
                SUM(CASE WHEN alignment_category = 'optimal' THEN 1 ELSE 0 END) as optimal,
                SUM(CASE WHEN alignment_category = 'problem' THEN 1 ELSE 0 END) as problem
               FROM requests WHERE timestamp >= ?""",
            (start_date.isoformat(),)
        )
        stats = await cursor.fetchone()
        total = stats["total"] or 0

        if total == 0:
            return {
                "tips": [{"type": "info", "text": "Pas encore assez de données. Continue à utiliser le monitor!"}],
                "stats": {"total": 0, "avg_clarity": 0, "avg_quality": 0},
                "period_days": days
            }

        # Analyze low-clarity prompts
        cursor = await self._connection.execute(
            """SELECT prompt_text, prompt_clarity_score, suggestion
               FROM requests
               WHERE timestamp >= ? AND prompt_clarity_score < 40
               ORDER BY timestamp DESC LIMIT 10""",
            (start_date.isoformat(),)
        )
        low_clarity = await cursor.fetchall()

        if len(low_clarity) >= 3:
            tips.append({
                "type": "warning",
                "text": f"{len(low_clarity)} prompts avec clarté < 40. Ajoute plus de contexte et de contraintes.",
                "count": len(low_clarity)
            })

        # Analyze high-performing prompts
        cursor = await self._connection.execute(
            """SELECT prompt_text, prompt_clarity_score, alignment_score
               FROM requests
               WHERE timestamp >= ? AND alignment_score >= 80
               ORDER BY alignment_score DESC LIMIT 5""",
            (start_date.isoformat(),)
        )
        high_perf = await cursor.fetchall()

        if high_perf:
            # Find common patterns in successful prompts
            tips.append({
                "type": "success",
                "text": f"{len(high_perf)} prompts avec alignement > 80. Analyse leurs patterns!",
                "count": len(high_perf)
            })

        # Get most common suggestions (real patterns)
        cursor = await self._connection.execute(
            """SELECT suggestion, COUNT(*) as count
               FROM requests
               WHERE timestamp >= ? AND suggestion IS NOT NULL AND suggestion != ''
               GROUP BY suggestion
               HAVING count > 1
               ORDER BY count DESC LIMIT 5""",
            (start_date.isoformat(),)
        )
        common_suggestions = await cursor.fetchall()

        for row in common_suggestions:
            tips.append({
                "type": "pattern",
                "text": row["suggestion"],
                "count": row["count"]
            })

        # Problem category analysis
        if stats["problem"] and stats["problem"] > 0:
            problem_pct = (stats["problem"] / total) * 100
            if problem_pct > 20:
                tips.append({
                    "type": "alert",
                    "text": f"{problem_pct:.0f}% de tes requêtes sont 'problem'. Relis les prompts problématiques.",
                    "count": stats["problem"]
                })

        # Optimal category encouragement
        if stats["optimal"] and stats["optimal"] > 0:
            optimal_pct = (stats["optimal"] / total) * 100
            tips.append({
                "type": "success",
                "text": f"{optimal_pct:.0f}% de tes requêtes sont 'optimal'. Continue comme ça!",
                "count": stats["optimal"]
            })

        # Tool usage patterns
        cursor = await self._connection.execute(
            """SELECT
                CASE
                    WHEN prompt_text LIKE '[User]%' THEN 'User'
                    WHEN prompt_text LIKE '[%' THEN substr(prompt_text, 2, instr(prompt_text, ']') - 2)
                    ELSE 'Other'
                END as tool_type,
                AVG(prompt_clarity_score) as avg_clarity,
                COUNT(*) as count
               FROM requests
               WHERE timestamp >= ?
               GROUP BY tool_type
               HAVING count >= 3
               ORDER BY avg_clarity DESC""",
            (start_date.isoformat(),)
        )
        tool_stats = await cursor.fetchall()

        user_prompts = next((r for r in tool_stats if r["tool_type"] == "User"), None)
        if user_prompts and user_prompts["avg_clarity"] < 50:
            tips.append({
                "type": "tip",
                "text": f"Tes prompts utilisateur ont une clarté moyenne de {user_prompts['avg_clarity']:.0f}. Ajoute du contexte!",
                "count": user_prompts["count"]
            })

        return {
            "tips": tips[:10],  # Limit to top 10 tips
            "stats": {
                "total": total,
                "avg_clarity": round(stats["avg_clarity"] or 0, 1),
                "avg_quality": round(stats["avg_quality"] or 0, 1),
                "avg_alignment": round(stats["avg_alignment"] or 0, 1),
                "optimal_count": stats["optimal"] or 0,
                "problem_count": stats["problem"] or 0,
            },
            "period_days": days
        }

    async def get_insights(self, days: int = 7) -> InsightData:
        """Generate insights and recommendations."""
        start_date = datetime.now() - timedelta(days=days)
        prev_start = start_date - timedelta(days=days)

        # Get category stats
        cursor = await self._connection.execute(
            """SELECT
                alignment_category,
                AVG(cost_usd) as avg_cost,
                AVG(alignment_score) as avg_alignment
               FROM requests
               WHERE timestamp >= ?
               GROUP BY alignment_category""",
            (start_date.isoformat(),)
        )
        rows = await cursor.fetchall()

        most_expensive = ("unknown", 0.0)
        most_efficient = ("unknown", 0.0)

        for row in rows:
            if row["avg_cost"] > most_expensive[1]:
                most_expensive = (row["alignment_category"], row["avg_cost"])
            if row["avg_alignment"] > most_efficient[1]:
                most_efficient = (row["alignment_category"], row["avg_alignment"])

        # Calculate trends
        current = await self._get_period_averages(start_date)
        previous = await self._get_period_averages(prev_start, start_date)

        clarity_trend = self._calc_trend(current["clarity"], previous["clarity"])
        quality_trend = self._calc_trend(current["quality"], previous["quality"])
        cost_trend = self._calc_trend(current["cost"], previous["cost"])

        # Generate suggestions
        suggestions = []
        if current["clarity"] < 60:
            suggestions.append("Tes prompts manquent de clarte. Ajoute plus de contexte.")
        if clarity_trend < 0:
            suggestions.append("Tes prompts sont moins clairs qu'avant. Revois tes patterns.")
        if current["quality"] > 80 and cost_trend > 0:
            suggestions.append("Bonne qualite mais couts en hausse. Essaie Haiku pour les taches simples.")

        return InsightData(
            most_expensive_category=most_expensive[0],
            most_expensive_avg_cost=most_expensive[1],
            most_efficient_category=most_efficient[0],
            most_efficient_score=most_efficient[1],
            clarity_trend=clarity_trend,
            quality_trend=quality_trend,
            cost_trend=cost_trend,
            top_suggestions=suggestions,
        )

    # =========================================================================
    # Private Helpers
    # =========================================================================

    def _row_to_request_record(self, row) -> RequestRecord:
        """Convert database row to RequestRecord."""
        return RequestRecord(
            id=row["id"],
            session_id=row["session_id"],
            timestamp=datetime.fromisoformat(row["timestamp"]),
            prompt_text=row["prompt_text"],
            prompt_tokens=row["prompt_tokens"],
            response_text=row["response_text"],
            response_tokens=row["response_tokens"],
            model=row["model"],
            latency_ms=row["latency_ms"],
            cost_usd=row["cost_usd"],
            prompt_clarity_score=row["prompt_clarity_score"],
            response_quality_score=row["response_quality_score"],
            alignment_score=row["alignment_score"],
            alignment_category=row["alignment_category"],
            suggestion=row["suggestion"],
            agent=row["agent"],
            tool_name=row["tool_name"],
        )

    async def _update_session_stats(self, session_id: str) -> None:
        """Update session aggregate statistics."""
        cursor = await self._connection.execute(
            """SELECT
                COUNT(*) as total,
                AVG(prompt_clarity_score) as clarity,
                AVG(response_quality_score) as quality,
                AVG(alignment_score) as alignment
               FROM requests WHERE session_id = ?""",
            (session_id,)
        )
        row = await cursor.fetchone()

        await self._connection.execute(
            """UPDATE sessions SET
                total_requests = ?,
                avg_prompt_clarity = ?,
                avg_response_quality = ?,
                avg_alignment = ?
               WHERE id = ?""",
            (
                row["total"],
                row["clarity"] or 0,
                row["quality"] or 0,
                row["alignment"] or 0,
                session_id
            )
        )

    async def _get_period_averages(
        self,
        start: datetime,
        end: Optional[datetime] = None
    ) -> dict:
        """Get average metrics for a time period."""
        if end is None:
            cursor = await self._connection.execute(
                """SELECT
                    AVG(prompt_clarity_score) as clarity,
                    AVG(response_quality_score) as quality,
                    AVG(cost_usd) as cost
                   FROM requests WHERE timestamp >= ?""",
                (start.isoformat(),)
            )
        else:
            cursor = await self._connection.execute(
                """SELECT
                    AVG(prompt_clarity_score) as clarity,
                    AVG(response_quality_score) as quality,
                    AVG(cost_usd) as cost
                   FROM requests WHERE timestamp >= ? AND timestamp < ?""",
                (start.isoformat(), end.isoformat())
            )

        row = await cursor.fetchone()
        return {
            "clarity": row["clarity"] or 0,
            "quality": row["quality"] or 0,
            "cost": row["cost"] or 0,
        }

    @staticmethod
    def _calc_trend(current: float, previous: float) -> float:
        """Calculate percentage trend."""
        if previous == 0:
            return 0.0
        return round((current - previous) / previous * 100, 1)


# Singleton instance
_db: Optional[Database] = None


async def get_database(db_path: Optional[str] = None) -> Database:
    """Get or create database singleton."""
    global _db
    if _db is None:
        _db = Database(db_path)
        await _db.connect()
    return _db
