import logging
import os
import sys

# Add the parent directory to sys.path so we can import 'app'
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.models.user import User
from app.core.security import get_password_hash

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def init_db(db: Session) -> None:
    """
    Initialize the database with default data.
    E.g., create an initial admin user so you can log in immediately.
    """
    admin_email = "admin@communityhero.com"
    user = db.query(User).filter(User.email == admin_email).first()
    
    if not user:
        logger.info("Creating initial admin user...")
        admin_user = User(
            email=admin_email,
            password_hash=get_password_hash("admin123")
        )
        db.add(admin_user)
        db.commit()
        db.refresh(admin_user)
        logger.info(f"Admin user created successfully. Email: {admin_email} | Password: admin123")
    else:
        logger.info(f"Admin user ({admin_email}) already exists. Skipping creation.")

def main() -> None:
    logger.info("Starting database initialization...")
    db = SessionLocal()
    try:
        init_db(db)
    finally:
        db.close()
    logger.info("Database initialization completed.")

if __name__ == "__main__":
    main()
