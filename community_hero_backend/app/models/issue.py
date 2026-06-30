from sqlalchemy import Column, String, Text, Float, ForeignKey, Enum as SQLEnum
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID
from app.models.base import BaseModel
import enum

class IssueCategory(str, enum.Enum):
    pothole = "pothole"
    water_leakage = "water_leakage"
    garbage_dump = "garbage_dump"
    broken_streetlight = "broken_streetlight"
    road_damage = "road_damage"
    drainage_issue = "drainage_issue"
    other = "other"

class VoteType(str, enum.Enum):
    CONFIRM = "CONFIRM"
    FALSE_REPORT = "FALSE_REPORT"
    ALREADY_FIXED = "ALREADY_FIXED"

class IssueStatus(str, enum.Enum):
    REPORTED = "REPORTED"
    VERIFIED = "VERIFIED"
    ASSIGNED = "ASSIGNED"
    IN_PROGRESS = "IN_PROGRESS"
    RESOLVED = "RESOLVED"
    CLOSED = "CLOSED"

class Issue(BaseModel):
    __tablename__ = "issues"
    reporter_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    title = Column(String, default="Unknown Title")
    category = Column(SQLEnum(IssueCategory))
    description = Column(Text)
    lat = Column(Float)
    lng = Column(Float)
    status = Column(SQLEnum(IssueStatus), default=IssueStatus.REPORTED)
    
    # AI Enrichment Fields
    ai_category = Column(String, nullable=True)
    ai_confidence = Column(Float, nullable=True)
    severity = Column(Float, nullable=True)
    ai_reasoning = Column(Text, nullable=True)
    
    images = relationship("IssueImage", back_populates="issue")
    verifications = relationship("IssueVerification", back_populates="issue")
    history = relationship("StatusHistory", back_populates="issue")
    
    @property
    def image_url(self):
        if self.images:
            return self.images[0].image_url
        return None

class IssueImage(BaseModel):
    __tablename__ = "issue_images"
    issue_id = Column(UUID(as_uuid=True), ForeignKey("issues.id"))
    image_url = Column(String)
    issue = relationship("Issue", back_populates="images")

class IssueVerification(BaseModel):
    __tablename__ = "issue_verifications"
    issue_id = Column(UUID(as_uuid=True), ForeignKey("issues.id"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    vote = Column(SQLEnum(VoteType), default=VoteType.CONFIRM)
    issue = relationship("Issue", back_populates="verifications")

class StatusHistory(BaseModel):
    __tablename__ = "status_history"
    issue_id = Column(UUID(as_uuid=True), ForeignKey("issues.id"))
    old_status = Column(String)
    new_status = Column(String)
    changed_by = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    issue = relationship("Issue", back_populates="history")
