from sqlalchemy.orm import Session
from sqlalchemy import func
import difflib
from uuid import UUID
from app.models.issue import Issue, IssueStatus
from app.schemas.issue import IssueCreate

class DuplicateDetectionService:
    @staticmethod
    def find_duplicate(
        db: Session,
        new_issue: IssueCreate,
        reporter_id: UUID,
        radius_meters: float = 10.0,
        similarity_threshold: float = 0.9
    ) -> Issue | None:
        """
        Detects if the SAME USER has already submitted a nearly identical issue
        within a very tight radius (10m) with highly similar description (90%+).
        
        Different users reporting the same issue is ALLOWED — they should upvote.
        Only blocks the exact same user submitting the same thing twice.
        """
        lat1 = new_issue.lat
        lng1 = new_issue.lng

        desc1 = (new_issue.description or "").strip()
        # Only check duplicate if the description is substantial (>= 30 characters)
        if len(desc1) < 30:
            return None

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

        # Only look at issues from THIS same reporter within the tight radius
        nearby_issues = db.query(Issue).filter(
            Issue.reporter_id == reporter_id,
            Issue.category == new_issue.category,
            safe_distance_expr < radius_meters
        ).all()

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
