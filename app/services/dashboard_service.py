from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.issue import Issue, IssueStatus

class DashboardService:
    @staticmethod
    def get_stats(db: Session) -> dict:
        total = db.query(Issue).count()
        verified = db.query(Issue).filter(Issue.status == IssueStatus.VERIFIED).count()
        resolved = db.query(Issue).filter(Issue.status == IssueStatus.RESOLVED).count()
        
        # Pending issues could be anything that isn't resolved or closed
        pending = db.query(Issue).filter(Issue.status.in_([IssueStatus.REPORTED, IssueStatus.VERIFIED, IssueStatus.ASSIGNED, IssueStatus.IN_PROGRESS])).count()
        
        # Average resolution time (hours) for resolved issues
        # Using SQLAlchemy's func.extract to get the epoch difference between updated_at and created_at
        avg_seconds = db.query(func.avg(
            func.extract('epoch', Issue.updated_at) - func.extract('epoch', Issue.created_at)
        )).filter(Issue.status == IssueStatus.RESOLVED).scalar()
        
        avg_hours = (avg_seconds / 3600.0) if avg_seconds else None
        
        return {
            "total_issues": total,
            "verified_issues": verified,
            "resolved_issues": resolved,
            "pending_issues": pending,
            "avg_resolution_time_hours": avg_hours
        }

    @staticmethod
    def get_categories(db: Session) -> list:
        results = db.query(
            Issue.category, 
            func.count(Issue.id).label('count')
        ).group_by(Issue.category).all()
        
        return [{"category": str(r[0].value), "count": r[1]} for r in results]

    @staticmethod
    def get_severity(db: Session) -> list:
        # severity is stored as a float 1-10
        # group by severity
        results = db.query(
            Issue.severity, 
            func.count(Issue.id).label('count')
        ).filter(Issue.severity != None).group_by(Issue.severity).order_by(Issue.severity.desc()).all()
        
        return [{"severity": r[0], "count": r[1]} for r in results]
