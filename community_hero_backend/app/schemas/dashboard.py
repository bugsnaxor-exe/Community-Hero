from pydantic import BaseModel
from typing import List, Optional

class DashboardStatsResponse(BaseModel):
    total_issues: int
    verified_issues: int
    resolved_issues: int
    pending_issues: int
    total_volunteers: Optional[int] = 0
    avg_resolution_time_hours: Optional[float]

class CategoryCountResponse(BaseModel):
    category: str
    count: int

class SeverityCountResponse(BaseModel):
    severity: float
    count: int

class LeaderboardUserResponse(BaseModel):
    id: str
    email: str
    reputation_score: int

class RecentActivityResponse(BaseModel):
    id: str
    title: str
    status: str
    category: str
    created_at: str

class AnalyticsDashboardResponse(BaseModel):
    stats: DashboardStatsResponse
    categories: List[CategoryCountResponse]
    severity: List[SeverityCountResponse]
    leaderboard: List[LeaderboardUserResponse]
    recent_activity: List[RecentActivityResponse]
