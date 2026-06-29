from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.routers.deps import get_current_user
from app.models.user import User
from app.models.issue import Issue
from app.schemas.user import UserResponse
from app.schemas.issue import IssueResponse

router = APIRouter()

@router.get("/me", response_model=UserResponse)
def read_users_me(current_user: User = Depends(get_current_user)):
    """
    Get current logged in user details.
    """
    return current_user

@router.get("/me/issues", response_model=List[IssueResponse])
def read_user_issues(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get all issues reported by the current user.
    """
    issues = db.query(Issue).filter(Issue.reporter_id == current_user.id).all()
    return issues

@router.get("/me/verifications", response_model=List[IssueResponse])
def read_user_verifications(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get all issues verified by the current user.
    """
    from app.models.issue import IssueVerification
    verifications = db.query(IssueVerification).filter(IssueVerification.user_id == current_user.id).all()
    issue_ids = [v.issue_id for v in verifications]
    issues = db.query(Issue).filter(Issue.id.in_(issue_ids)).all() if issue_ids else []
    return issues

@router.get("/leaderboard", response_model=List[UserResponse])
def get_leaderboard(
    limit: int = 10,
    db: Session = Depends(get_db)
):
    """
    Get the top users by reputation score.
    """
    users = db.query(User).order_by(User.reputation_score.desc()).limit(limit).all()
    return users

@router.get("/{user_id}/profile", response_model=UserResponse)
def get_user_profile(
    user_id: str,
    db: Session = Depends(get_db)
):
    """
    Get a specific user's profile.
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="User not found")
    return user
