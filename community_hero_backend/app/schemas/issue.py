from pydantic import BaseModel, Field, field_validator
from typing import Optional, List
from uuid import UUID
from datetime import datetime
from app.models.issue import IssueCategory, IssueStatus, VoteType

class IssueCreate(BaseModel):
    title: Optional[str] = "Unknown Title"
    category: IssueCategory
    description: str
    lat: float = Field(..., ge=-90, le=90, description="Latitude must be between -90 and 90")
    lng: float = Field(..., ge=-180, le=180, description="Longitude must be between -180 and 180")

class IssueUpdate(BaseModel):
    title: Optional[str] = None
    category: Optional[IssueCategory] = None
    description: Optional[str] = None
    status: Optional[IssueStatus] = None

class IssueResponse(BaseModel):
    id: UUID
    reporter_id: UUID
    title: Optional[str] = "Unknown Title"
    category: IssueCategory
    description: str
    status: IssueStatus
    lat: float
    lng: float
    ai_category: Optional[str] = None
    ai_confidence: Optional[float] = None
    severity: Optional[str] = None
    ai_reasoning: Optional[str] = None
    created_at: datetime
    image_url: Optional[str] = None
    
    @field_validator('severity', mode='before')
    @classmethod
    def serialize_severity(cls, v):
        if isinstance(v, (int, float)):
            if v >= 9.0:
                return "Critical"
            elif v >= 7.0:
                return "High"
            elif v >= 4.0:
                return "Medium"
            else:
                return "Low"
        return v or "Low"

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
    latitude: Optional[float] = None
    longitude: Optional[float] = None

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
