import os
import shutil
import uuid
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List
from uuid import UUID
from app.core.database import get_db
from app.routers.deps import get_current_user
from app.models.user import User
from app.models.issue import Issue, IssueVerification, StatusHistory, IssueStatus, IssueImage, VoteType
from app.models.notification import Notification
from app.schemas.issue import IssueCreate, IssueUpdate, IssueResponse, IssueDetailResponse, IssueVerificationCreate, IssueVerificationResponse, IssueStatusUpdate, StatusHistoryResponse
from app.services.vision_service import analyze_issue_image
from app.services.duplicate_service import DuplicateDetectionService

router = APIRouter()

@router.post("/", response_model=IssueResponse)
def create_issue(issue_in: IssueCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # --- Duplicate Detection ---
    duplicate = DuplicateDetectionService.find_duplicate(db, issue_in, radius_meters=50.0, similarity_threshold=0.8)
    if duplicate:
        raise HTTPException(
            status_code=409, 
            detail={
                "message": "This appears to be a duplicate of an existing issue.", 
                "duplicate_issue_id": str(duplicate.id)
            }
        )
        
    new_issue = Issue(**issue_in.model_dump(), reporter_id=current_user.id)
    db.add(new_issue)
    db.commit()
    db.refresh(new_issue)
    return new_issue

@router.get("/", response_model=List[IssueResponse])
def get_issues(db: Session = Depends(get_db)):
    return db.query(Issue).all()

@router.get("/nearby")
def get_nearby_issues(
    lat: float, 
    lng: float, 
    radius: float = 50.0, 
    db: Session = Depends(get_db)
):
    if lat < -90 or lat > 90 or lng < -180 or lng > 180:
        raise HTTPException(status_code=400, detail="Invalid coordinates")
        
    safe_distance_expr = 6371000 * func.acos(
        func.least(
            1.0, 
            func.greatest(
                -1.0, 
                func.cos(func.radians(lat)) * func.cos(func.radians(Issue.lat)) *
                func.cos(func.radians(Issue.lng) - func.radians(lng)) +
                func.sin(func.radians(lat)) * func.sin(func.radians(Issue.lat))
            )
        )
    )

    nearby_issues = db.query(Issue).filter(safe_distance_expr <= radius).all()
    
    # Generate GeoJSON Response
    features = []
    for issue in nearby_issues:
        features.append({
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": [issue.lng, issue.lat]
            },
            "properties": {
                "id": str(issue.id),
                "category": issue.category.value,
                "status": issue.status.value,
                "description": issue.description,
                "severity": issue.severity
            }
        })
        
    return {
        "type": "FeatureCollection",
        "features": features
    }

@router.get("/{id}", response_model=IssueDetailResponse)
def get_issue(id: UUID, db: Session = Depends(get_db)):
    issue = db.query(Issue).filter(Issue.id == id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Issue not found")
    
    verification_count = db.query(IssueVerification).filter(IssueVerification.issue_id == id).count()
    
    # We use model_dump() to merge the issue data and the computed count
    issue_data = {
        **issue.__dict__,
        "verification_count": verification_count,
        "images": issue.images
    }
    return issue_data

@router.post("/{id}/verify")
def verify_issue(id: UUID, verify_in: IssueVerificationCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    issue = db.query(Issue).filter(Issue.id == id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Issue not found")
        
    if issue.reporter_id == current_user.id:
        raise HTTPException(status_code=400, detail="Cannot verify your own issue")
        
    existing_verification = db.query(IssueVerification).filter(
        IssueVerification.issue_id == id,
        IssueVerification.user_id == current_user.id
    ).first()
    
    if existing_verification:
        raise HTTPException(status_code=400, detail="You have already verified this issue")
        
    new_verification = IssueVerification(issue_id=id, user_id=current_user.id, vote=verify_in.vote)
    db.add(new_verification)
    
    # We add the new verification and calculate CONFIRM count including the new one (if it's a CONFIRM)
    confirm_count = db.query(IssueVerification).filter(
        IssueVerification.issue_id == id,
        IssueVerification.vote == VoteType.CONFIRM
    ).count()
    if verify_in.vote == VoteType.CONFIRM:
        confirm_count += 1
    
    # 3-verification logic (ONLY FOR CONFIRM VOTES)
    if issue.status == IssueStatus.REPORTED and confirm_count >= 3:
        history = StatusHistory(
            issue_id=id,
            old_status=IssueStatus.REPORTED.value,
            new_status=IssueStatus.VERIFIED.value,
            changed_by=current_user.id
        )
        db.add(history)
        issue.status = IssueStatus.VERIFIED
        
        # Notify the reporter
        notification = Notification(
            user_id=issue.reporter_id,
            message=f"Good news! Your issue '{issue.category.value}' has reached 3 CONFIRM votes and is now marked as VERIFIED."
        )
        db.add(notification)
        
    db.commit()
    
    return {
        "message": "Vote submitted successfully",
        "confirm_votes": confirm_count,
        "status": issue.status
    }

@router.get("/{id}/verifications", response_model=List[IssueVerificationResponse])
def get_issue_verifications(id: UUID, db: Session = Depends(get_db)):
    issue = db.query(Issue).filter(Issue.id == id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Issue not found")
    
    verifications = db.query(IssueVerification).filter(IssueVerification.issue_id == id).all()
    return verifications

@router.post("/{id}/upload-image")
def upload_issue_images(
    id: UUID, 
    files: List[UploadFile] = File(...), 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    issue = db.query(Issue).filter(Issue.id == id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Issue not found")
        
    if issue.reporter_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to upload images for this issue")
        
    upload_dir = "static/uploads"
    os.makedirs(upload_dir, exist_ok=True)
    
    ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png"}
    MAX_FILE_SIZE = 10 * 1024 * 1024 # 10 MB
    
    uploaded_images = []
    for file in files:
        file_extension = file.filename.split(".")[-1].lower()
        if file_extension not in ALLOWED_EXTENSIONS:
            raise HTTPException(status_code=400, detail=f"File type '{file_extension}' not allowed. Allowed types are: jpg, jpeg, png.")
            
        # Check file size by seeking
        file.file.seek(0, 2)
        file_size = file.file.tell()
        file.file.seek(0) # reset
        if file_size > MAX_FILE_SIZE:
            raise HTTPException(status_code=400, detail="File size exceeds the 10MB limit.")
            
        new_filename = f"{uuid.uuid4()}.{file_extension}"
        file_path = os.path.join(upload_dir, new_filename)
        
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # --- Vision AI Analysis ---
        ai_data = analyze_issue_image(file_path)
        if ai_data:
            issue.ai_category = ai_data.get("category")
            issue.ai_confidence = ai_data.get("confidence")
            issue.severity = ai_data.get("severity")
            issue.ai_reasoning = ai_data.get("reasoning")
            
        image_url = f"/static/uploads/{new_filename}"
        
        issue_image = IssueImage(issue_id=id, image_url=image_url)
        db.add(issue_image)
        uploaded_images.append(issue_image)
        
    db.commit()
    for img in uploaded_images:
        db.refresh(img)
        
    return {
        "message": "Images uploaded successfully", 
        "images": [{"id": img.id, "image_url": img.image_url} for img in uploaded_images]
    }

@router.get("/{id}/images")
def get_issue_images(
    id: UUID, 
    db: Session = Depends(get_db)
):
    issue = db.query(Issue).filter(Issue.id == id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Issue not found")
    
    images = db.query(IssueImage).filter(IssueImage.issue_id == id).all()
    return [{"id": img.id, "image_url": img.image_url, "created_at": img.created_at} for img in images]

@router.put("/{id}", response_model=IssueResponse)
def update_issue(
    id: UUID, 
    issue_update: IssueUpdate, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    issue = db.query(Issue).filter(Issue.id == id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Issue not found")
        
    if issue.reporter_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to update this issue")
        
    update_data = issue_update.model_dump(exclude_unset=True)
    
    # If status is being updated, we should record it in history
    if "status" in update_data and update_data["status"] != issue.status:
        history = StatusHistory(
            issue_id=id,
            old_status=issue.status.value,
            new_status=update_data["status"].value,
            changed_by=current_user.id
        )
        db.add(history)
        
        # Notify the reporter about the manual status change
        notification = Notification(
            user_id=issue.reporter_id,
            message=f"Update: Your issue '{issue.category.value}' status was changed from {issue.status.value} to {update_data['status'].value}."
        )
        db.add(notification)

    for key, value in update_data.items():
        setattr(issue, key, value)
        
    db.commit()
    db.refresh(issue)
    return issue

@router.delete("/{id}")
def delete_issue(
    id: UUID, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    issue = db.query(Issue).filter(Issue.id == id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Issue not found")
        
    if issue.reporter_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this issue")
        
    # We should delete related data or rely on DB cascading.
    db.query(IssueImage).filter(IssueImage.issue_id == id).delete()
    db.query(IssueVerification).filter(IssueVerification.issue_id == id).delete()
    db.query(StatusHistory).filter(StatusHistory.issue_id == id).delete()
    
    db.delete(issue)
    db.commit()
    
    return {"message": "Issue deleted successfully"}

@router.patch("/{id}/status", response_model=IssueResponse)
def update_issue_status(
    id: UUID, 
    status_update: IssueStatusUpdate, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    issue = db.query(Issue).filter(Issue.id == id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Issue not found")
        
    # Anyone authenticated (or just admins) might change status, but let's assume any authenticated user for now
    # Or restrict to admins if we had roles.
    
    if issue.status != status_update.status:
        history = StatusHistory(
            issue_id=id,
            old_status=issue.status.value,
            new_status=status_update.status.value,
            changed_by=current_user.id
        )
        db.add(history)
        
        issue.status = status_update.status
        
        # Notify the reporter about the manual status change
        notification = Notification(
            user_id=issue.reporter_id,
            message=f"Update: Your issue '{issue.category.value}' status was changed from {history.old_status} to {history.new_status}."
        )
        db.add(notification)
        
        db.commit()
        db.refresh(issue)
        
    return issue

@router.get("/{id}/timeline", response_model=List[StatusHistoryResponse])
def get_issue_timeline(id: UUID, db: Session = Depends(get_db)):
    issue = db.query(Issue).filter(Issue.id == id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Issue not found")
        
    history = db.query(StatusHistory).filter(StatusHistory.issue_id == id).order_by(StatusHistory.created_at.asc()).all()
    return history
