from pydantic import BaseModel
from typing import List, Optional

class DashboardStatsResponse(BaseModel):
    total_issues: int
    verified_issues: int
    resolved_issues: int
    pending_issues: int
    avg_resolution_time_hours: Optional[float]

class CategoryCountResponse(BaseModel):
    category: str
    count: int

class SeverityCountResponse(BaseModel):
    severity: float
    count: int
