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
        
        desc1 = (new_issue.description or "").strip()
        # Only check duplicate if the description is substantial (>= 15 characters)
        if len(desc1) < 15:
            return None
            
        desc1_lower = desc1.lower()
        for issue in nearby_issues:
            desc2 = (issue.description or "").strip()
            if len(desc2) < 15:
                continue
            desc2_lower = desc2.lower()
            similarity = difflib.SequenceMatcher(None, desc1_lower, desc2_lower).ratio()
            if similarity >= similarity_threshold:
                return issue
                
        return None
