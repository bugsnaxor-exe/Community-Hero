from sqlalchemy import Column, String, Integer
from sqlalchemy.orm import relationship
from app.models.base import BaseModel

class User(BaseModel):
    __tablename__ = "users"
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    name = Column(String, nullable=True)
    reputation_score = Column(Integer, default=0, nullable=False)
    level = Column(Integer, default=1, nullable=False)
    # issues_reported = relationship("Issue", back_populates="reporter")
