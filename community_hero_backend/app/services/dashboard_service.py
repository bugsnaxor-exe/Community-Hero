from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.issue import Issue, IssueStatus

class DashboardService:
    @staticmethod
    def get_stats(db: Session) -> dict:
        from app.models.user import User
        total = db.query(Issue).count()
        verified = db.query(Issue).filter(Issue.status == IssueStatus.VERIFIED).count()
        resolved = db.query(Issue).filter(Issue.status == IssueStatus.RESOLVED).count()
        volunteers = db.query(User).count()
        
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
            "total_volunteers": volunteers,
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

    @staticmethod
    def get_leaderboard(db: Session, limit: int = 10) -> list:
        from app.models.user import User
        users = db.query(User).order_by(User.reputation_score.desc()).limit(limit).all()
        return [
            {
                "id": str(u.id),
                "email": u.email,
                "reputation_score": u.reputation_score
            } for u in users
        ]

    @staticmethod
    def get_recent_activity(db: Session, limit: int = 5) -> list:
        issues = db.query(Issue).order_by(Issue.created_at.desc()).limit(limit).all()
        # Fallback for old schema where title might be missing, assume description prefix
        return [
            {
                "id": str(i.id),
                "title": getattr(i, 'title', i.description[:20] if i.description else 'Issue'),
                "status": str(i.status.value),
                "category": str(getattr(i, 'category', getattr(i, 'type', 'OTHER'))),
                "created_at": i.created_at.isoformat()
            } for i in issues
        ]

    @staticmethod
    def get_full_dashboard(db: Session) -> dict:
        return {
            "stats": DashboardService.get_stats(db),
            "categories": DashboardService.get_categories(db),
            "severity": DashboardService.get_severity(db),
            "leaderboard": DashboardService.get_leaderboard(db),
            "recent_activity": DashboardService.get_recent_activity(db)
        }
