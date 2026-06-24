from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.schemas.dashboard import DashboardStatsResponse, CategoryCountResponse, SeverityCountResponse
from app.services.dashboard_service import DashboardService

router = APIRouter()

@router.get("/stats", response_model=DashboardStatsResponse)
def get_dashboard_stats(db: Session = Depends(get_db)):
    return DashboardService.get_stats(db)

@router.get("/categories", response_model=List[CategoryCountResponse])
def get_dashboard_categories(db: Session = Depends(get_db)):
    return DashboardService.get_categories(db)

@router.get("/severity", response_model=List[SeverityCountResponse])
def get_dashboard_severity(db: Session = Depends(get_db)):
    return DashboardService.get_severity(db)
