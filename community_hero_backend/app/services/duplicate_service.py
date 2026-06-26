from sqlalchemy.orm import Session
from sqlalchemy import func
import difflib
from app.models.issue import Issue
from app.schemas.issue import IssueCreate

class DuplicateDetectionService:
    @staticmethod
    def find_duplicate(db: Session, new_issue: IssueCreate, radius_meters: float = 50.0, similarity_threshold: float = 0.8) -> Issue | None:
        """
        Detects if a highly similar issue already exists within a specified radius.
        """
        lat1 = new_issue.lat
        lng1 = new_issue.lng
        
        safe_distance_expr = 6371000 * func.acos(
            func.least(
                1.0, 
                func.greatest(
                    -1.0, 
                    func.cos(func.radians(lat1)) * func.cos(func.radians(Issue.lat)) *
                    func.cos(func.radians(Issue.lng) - func.radians(lng1)) +
                    func.sin(func.radians(lat1)) * func.sin(func.radians(Issue.lat))
                )
            )
        )

        nearby_issues = db.query(Issue).filter(
            Issue.category == new_issue.category,
            safe_distance_expr < radius_meters
        ).all()
        
        for issue in nearby_issues:
            similarity = difflib.SequenceMatcher(None, new_issue.description.lower(), issue.description.lower()).ratio()
            if similarity >= similarity_threshold:
                return issue
                
        return None
