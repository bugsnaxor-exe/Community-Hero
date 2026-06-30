import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql import text
from app.core.config import settings

def clear_mock_data():
    engine = create_engine(settings.DATABASE_URL)
    Session = sessionmaker(bind=engine)
    session = Session()

    try:
        # Get the 2 most recent issues
        result = session.execute(text("SELECT id FROM issues ORDER BY created_at DESC LIMIT 2"))
        keep_ids = [str(row[0]) for row in result.fetchall()]
        
        if not keep_ids:
            print("No issues found to keep.")
            return

        keep_ids_str = "', '".join(keep_ids)
        keep_ids_sql = f"'{keep_ids_str}'"
        
        print(f"Keeping issues: {keep_ids}")

        # Delete issue_images for issues not in keep_ids
        res = session.execute(text(f"DELETE FROM issue_images WHERE issue_id NOT IN ({keep_ids_sql})"))
        print(f"Deleted {res.rowcount} issue images.")
        
        # Delete verifications for issues not in keep_ids
        res = session.execute(text(f"DELETE FROM issue_verifications WHERE issue_id NOT IN ({keep_ids_sql})"))
        print(f"Deleted {res.rowcount} verifications.")
        
        # Delete issues not in keep_ids
        res = session.execute(text(f"DELETE FROM issues WHERE id NOT IN ({keep_ids_sql})"))
        print(f"Deleted {res.rowcount} issues.")
        
        session.commit()
        print("Mock data cleared successfully!")
        
    except Exception as e:
        print(f"Error: {e}")
        session.rollback()
    finally:
        session.close()

if __name__ == '__main__':
    clear_mock_data()
