from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import verify_password, get_password_hash, create_access_token
from app.models.user import User
from app.schemas.user import UserCreate, UserResponse, UserLogin

router = APIRouter()

@router.post("/register", response_model=UserResponse)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == user_in.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    user = User(
        email=user_in.email, 
        password_hash=get_password_hash(user_in.password),
        name=user_in.name
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@router.post("/login")
def login(login_data: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == login_data.email).first()
    if not user or not verify_password(login_data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Incorrect email or password")
    
    if login_data.name:
        user.name = login_data.name
        db.commit()
        db.refresh(user)
        
    access_token = create_access_token(subject=str(user.id))
    return {"access_token": access_token, "token_type": "bearer"}

import random
import string
from datetime import datetime, timedelta, timezone
from app.schemas.user import ForgotPasswordRequest, ResetPasswordRequest
from app.services.email_service import send_reset_password_email

@router.post("/forgot-password")
def forgot_password(request: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        # Return 200 even if user not found to prevent email enumeration
        return {"message": "If an account with that email exists, a password reset code has been sent."}
    
    # Generate 6-digit code
    code = ''.join(random.choices(string.digits, k=6))
    
    # Save code to user model
    user.reset_code = code
    user.reset_code_expires = datetime.now(timezone.utc) + timedelta(minutes=15)
    db.commit()
    
    # Send email
    send_reset_password_email(to_email=user.email, code=code)
    
    return {"message": "If an account with that email exists, a password reset code has been sent."}

@router.post("/reset-password")
def reset_password(request: ResetPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(status_code=400, detail="Invalid request")
        
    if not user.reset_code or user.reset_code != request.code:
        raise HTTPException(status_code=400, detail="Invalid or expired reset code")
        
    if not user.reset_code_expires or user.reset_code_expires.replace(tzinfo=timezone.utc) < datetime.now(timezone.utc):
        raise HTTPException(status_code=400, detail="Invalid or expired reset code")
        
    # Valid code, reset password
    user.password_hash = get_password_hash(request.new_password)
    user.reset_code = None
    user.reset_code_expires = None
    db.commit()
    
    return {"message": "Password successfully reset"}
