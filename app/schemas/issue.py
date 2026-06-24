from pydantic import BaseModel, Field
from typing import Optional, List
from uuid import UUID
from datetime import datetime
from app.models.issue import IssueCategory, IssueStatus, VoteType

class IssueCreate(BaseModel):
    category: IssueCategory
    description: str
    lat: float = Field(..., ge=-90, le=90, description="Latitude must be between -90 and 90")
    lng: float = Field(..., ge=-180, le=180, description="Longitude must be between -180 and 180")

class IssueUpdate(BaseModel):
    category: Optional[IssueCategory] = None
    description: Optional[str] = None
    status: Optional[IssueStatus] = None

class IssueResponse(BaseModel):
    id: UUID
    reporter_id: UUID
    category: IssueCategory
    description: str
    status: IssueStatus
    lat: float
    lng: float
    ai_category: Optional[str] = None
    ai_confidence: Optional[float] = None
    severity: Optional[float] = None
    ai_reasoning: Optional[str] = None
    
    class Config:
        from_attributes = True

class IssueImageResponse(BaseModel):
    id: UUID
    image_url: str
    created_at: datetime
    
    class Config:
        from_attributes = True

class IssueDetailResponse(IssueResponse):
    verification_count: int
    images: List[IssueImageResponse] = []

class IssueVerificationCreate(BaseModel):
    vote: VoteType = VoteType.CONFIRM

class IssueVerificationResponse(BaseModel):
    id: UUID
    issue_id: UUID
    user_id: UUID
    vote: VoteType
    created_at: datetime
    
    class Config:
        from_attributes = True

class IssueStatusUpdate(BaseModel):
    status: IssueStatus

class StatusHistoryResponse(BaseModel):
    id: UUID
    issue_id: UUID
    old_status: str
    new_status: str
    changed_by: UUID
    created_at: datetime
    
    class Config:
        from_attributes = True
