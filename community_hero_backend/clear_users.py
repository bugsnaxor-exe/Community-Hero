import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql import text
from app.core.config import settings

def clear_users():
    engine = create_engine(settings.DATABASE_URL)
    Session = sessionmaker(bind=engine)
    session = Session()
    try:
        res = session.execute(text("DELETE FROM users WHERE email LIKE 'tester_%' OR email LIKE 'regression_%' OR email LIKE 'testuser%' OR email LIKE 'test_user%' OR email LIKE 'sayan_test%'"))
        print(f"Deleted {res.rowcount} mock users.")
        session.commit()
    except Exception as e:
        print(f"Error: {e}")
        session.rollback()
    finally:
        session.close()

if __name__ == '__main__':
    clear_users()
