import os

base_dir = r"c:\Users\Sayan\Documents\vibe2ship\community_hero_backend"

files = {
    "requirements.txt": """fastapi
uvicorn[standard]
sqlalchemy
alembic
psycopg2-binary
pydantic
pydantic-settings
python-jose[cryptography]
passlib[bcrypt]
python-multipart
""",
    "Dockerfile": """FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
""",
    "docker-compose.yml": """version: '3.8'
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: community_hero
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://postgres:password@db:5432/community_hero
      SECRET_KEY: your-super-secret-jwt-key
    depends_on:
      - db
volumes:
  postgres_data:
""",
    "app/__init__.py": "",
    "app/core/__init__.py": "",
    "app/core/config.py": """from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Community Hero API"
    DATABASE_URL: str = "postgresql://postgres:password@localhost:5432/community_hero"
    SECRET_KEY: str = "supersecretkey"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    class Config:
        env_file = ".env"

settings = Settings()
""",
    "app/core/database.py": """from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

engine = create_engine(settings.DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
""",
    "app/core/security.py": """from datetime import datetime, timedelta
from typing import Any, Union
from jose import jwt
from passlib.context import CryptContext
from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def create_access_token(subject: Union[str, Any], expires_delta: timedelta = None) -> str:
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode = {"exp": expire, "sub": str(subject)}
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)
""",
    "app/models/__init__.py": """from .base import Base
from .user import User
from .issue import Issue, IssueImage, IssueVerification, StatusHistory
from .notification import Notification
""",
    "app/models/base.py": """import uuid
from datetime import datetime
from sqlalchemy import Column, DateTime
from sqlalchemy.dialects.postgresql import UUID
from app.core.database import Base

class BaseModel(Base):
    __abstract__ = True
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
""",
    "app/models/user.py": """from sqlalchemy import Column, String
from sqlalchemy.orm import relationship
from app.models.base import BaseModel

class User(BaseModel):
    __tablename__ = "users"
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    # issues_reported = relationship("Issue", back_populates="reporter")
""",
    "app/models/issue.py": """from sqlalchemy import Column, String, Text, Float, ForeignKey, Enum as SQLEnum
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID
from app.models.base import BaseModel
import enum

class IssueCategory(str, enum.Enum):
    pothole = "pothole"
    water_leakage = "water_leakage"
    garbage_dump = "garbage_dump"
    broken_streetlight = "broken_streetlight"
    road_damage = "road_damage"
    drainage_issue = "drainage_issue"
    other = "other"

class IssueStatus(str, enum.Enum):
    REPORTED = "REPORTED"
    VERIFIED = "VERIFIED"
    ASSIGNED = "ASSIGNED"
    IN_PROGRESS = "IN_PROGRESS"
    RESOLVED = "RESOLVED"
    CLOSED = "CLOSED"

class Issue(BaseModel):
    __tablename__ = "issues"
    reporter_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    category = Column(SQLEnum(IssueCategory))
    description = Column(Text)
    lat = Column(Float)
    lng = Column(Float)
    status = Column(SQLEnum(IssueStatus), default=IssueStatus.REPORTED)
    
    images = relationship("IssueImage", back_populates="issue")
    verifications = relationship("IssueVerification", back_populates="issue")
    history = relationship("StatusHistory", back_populates="issue")

class IssueImage(BaseModel):
    __tablename__ = "issue_images"
    issue_id = Column(UUID(as_uuid=True), ForeignKey("issues.id"))
    image_url = Column(String)
    issue = relationship("Issue", back_populates="images")

class IssueVerification(BaseModel):
    __tablename__ = "issue_verifications"
    issue_id = Column(UUID(as_uuid=True), ForeignKey("issues.id"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    issue = relationship("Issue", back_populates="verifications")

class StatusHistory(BaseModel):
    __tablename__ = "status_history"
    issue_id = Column(UUID(as_uuid=True), ForeignKey("issues.id"))
    old_status = Column(String)
    new_status = Column(String)
    changed_by = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    issue = relationship("Issue", back_populates="history")
""",
    "app/models/notification.py": """from sqlalchemy import Column, String, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from app.models.base import BaseModel

class Notification(BaseModel):
    __tablename__ = "notifications"
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    message = Column(String)
    is_read = Column(Boolean, default=False)
""",
    "app/schemas/__init__.py": "",
    "app/schemas/user.py": """from pydantic import BaseModel, EmailStr
from uuid import UUID

class UserCreate(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: UUID
    email: EmailStr
    
    class Config:
        from_attributes = True
""",
    "app/schemas/issue.py": """from pydantic import BaseModel
from typing import Optional, List
from uuid import UUID
from app.models.issue import IssueCategory, IssueStatus

class IssueCreate(BaseModel):
    category: IssueCategory
    description: str
    lat: float
    lng: float

class IssueResponse(BaseModel):
    id: UUID
    reporter_id: UUID
    category: IssueCategory
    description: str
    status: IssueStatus
    lat: float
    lng: float
    
    class Config:
        from_attributes = True
""",
    "app/api/__init__.py": "",
    "app/api/deps.py": """from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from jose import jwt, JWTError
from app.core.config import settings
from app.core.database import get_db
from app.models.user import User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/token")

def get_current_user(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise credentials_exception
    return user
""",
    "app/api/endpoints/__init__.py": "",
    "app/api/endpoints/auth.py": """from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordRequestForm
from app.core.database import get_db
from app.core.security import verify_password, get_password_hash, create_access_token
from app.models.user import User
from app.schemas.user import UserCreate, UserResponse

router = APIRouter()

@router.post("/register", response_model=UserResponse)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == user_in.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    user = User(email=user_in.email, password_hash=get_password_hash(user_in.password))
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@router.post("/token")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    access_token = create_access_token(subject=str(user.id))
    return {"access_token": access_token, "token_type": "bearer"}
""",
    "app/api/endpoints/issues.py": """from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.issue import Issue
from app.schemas.issue import IssueCreate, IssueResponse

router = APIRouter()

@router.post("/", response_model=IssueResponse)
def create_issue(issue_in: IssueCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    new_issue = Issue(**issue_in.model_dump(), reporter_id=current_user.id)
    db.add(new_issue)
    db.commit()
    db.refresh(new_issue)
    return new_issue

@router.get("/", response_model=List[IssueResponse])
def get_issues(db: Session = Depends(get_db)):
    return db.query(Issue).all()
""",
    "app/api/api.py": """from fastapi import APIRouter
from app.api.endpoints import auth, issues

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(issues.router, prefix="/issues", tags=["issues"])
""",
    "app/main.py": """from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.api import api_router
from app.core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Backend API for Community Hero",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix="/api")

@app.get("/")
def root():
    return {"message": "Welcome to Community Hero API"}
""",
    "alembic.ini": """[alembic]
script_location = alembic
sqlalchemy.url = postgresql://postgres:password@localhost:5432/community_hero

[post_write_hooks]
[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console
qualname =

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
""",
    "alembic/env.py": """import logging
from logging.config import fileConfig
from sqlalchemy import engine_from_config
from sqlalchemy import pool
from alembic import context
from app.models import Base
from app.core.config import settings

config = context.config
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata

def run_migrations_offline() -> None:
    url = settings.DATABASE_URL
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    configuration = config.get_section(config.config_ini_section)
    configuration["sqlalchemy.url"] = settings.DATABASE_URL
    connectable = engine_from_config(
        configuration,
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(
            connection=connection, target_metadata=target_metadata
        )
        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
"""
}

for path_str, content in files.items():
    full_path = os.path.join(base_dir, path_str)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w") as f:
        f.write(content)

print(f"Successfully scaffolded {len(files)} files in {base_dir}")
