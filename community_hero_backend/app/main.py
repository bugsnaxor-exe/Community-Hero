from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text
from sqlalchemy.orm import Session
import logging
import os
from app.routers import auth, issues, users, dashboard, notifications
from app.core.config import settings
from app.core.database import get_db

# Configure production logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Backend API for Community Hero",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

os.makedirs("static/uploads", exist_ok=True)
app.mount("/static", StaticFiles(directory="static"), name="static")

app.include_router(auth.router, prefix="/api/auth", tags=["auth"])

@app.on_event("startup")
def configure_db():
    from app.core.database import SessionLocal
    db = SessionLocal()
    try:
        db.execute(text("ALTER TABLE issues ADD COLUMN IF NOT EXISTS title VARCHAR DEFAULT 'Unknown Title';"))
        db.commit()
        logger.info("Database migration completed: title column exists in issues table.")
    except Exception as e:
        logger.warning(f"Could not run inline migration for title column: {e}")
    finally:
        db.close()
app.include_router(users.router, prefix="/api/users", tags=["users"])
app.include_router(issues.router, prefix="/api/issues", tags=["issues"])
app.include_router(dashboard.router, prefix="/api/dashboard", tags=["dashboard"])
app.include_router(notifications.router, prefix="/api/notifications", tags=["notifications"])

@app.get("/api/test-smtp")
def test_smtp_endpoint():
    import smtplib
    from email.mime.text import MIMEText
    from app.core.config import settings
    
    smtp_host = getattr(settings, "SMTP_HOST", "")
    smtp_port = getattr(settings, "SMTP_PORT", 587)
    smtp_user = getattr(settings, "SMTP_USER", "")
    smtp_password = getattr(settings, "SMTP_PASSWORD", "")
    resend_api_key = getattr(settings, "RESEND_API_KEY", "")
    
    openrouter_api_key = getattr(settings, "OPENROUTER_API_KEY", "")
    status_info = {
        "smtp_host": smtp_host,
        "smtp_port": smtp_port,
        "smtp_user": smtp_user,
        "smtp_password_configured": bool(smtp_password),
        "resend_key_configured": bool(resend_api_key),
        "resend_key_preview": f"{resend_api_key[:5]}...{resend_api_key[-3:]}" if resend_api_key else None,
        "openrouter_key_configured": bool(openrouter_api_key),
        "openrouter_key_preview": f"{openrouter_api_key[:5]}...{openrouter_api_key[-3:]}" if openrouter_api_key else None
    }
    
    # 1. Try Resend if configured
    if resend_api_key:
        try:
            import urllib.request
            import json
            payload = {
                "from": "Community Hero <onboarding@resend.dev>",
                "to": ["sayantan05092004@gmail.com"],
                "subject": "[Community Hero] Live Render Resend Diagnostic",
                "text": "This is a live diagnostic email sent from the Render server using the Resend HTTP API fallback."
            }
            req = urllib.request.Request(
                "https://api.resend.com/emails",
                data=json.dumps(payload).encode("utf-8"),
                headers={
                    "Authorization": f"Bearer {resend_api_key}",
                    "Content-Type": "application/json",
                    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
                },
                method="POST"
            )
            with urllib.request.urlopen(req, timeout=10) as response:
                response_code = response.getcode()
                response_text = response.read().decode("utf-8")
                
            if response_code in [200, 201]:
                return {
                    "status": "success",
                    "method": "Resend HTTP API",
                    "response_code": response_code,
                    "response_text": response_text,
                    "details": status_info
                }
            else:
                return {
                    "status": "failed",
                    "method": "Resend HTTP API",
                    "response_code": response_code,
                    "response_text": response_text,
                    "details": status_info
                }
        except urllib.error.HTTPError as e:
            try:
                error_body = e.read().decode("utf-8")
            except Exception:
                error_body = "Could not read error body"
            return {
                "status": "failed",
                "method": "Resend HTTP API",
                "error": f"HTTP Error {e.code}: {e.reason}",
                "body": error_body,
                "details": status_info
            }
        except Exception as e:
            return {
                "status": "failed",
                "method": "Resend HTTP API",
                "error": str(e),
                "details": status_info
            }
            
    # 2. Try SMTP fallback
    if not smtp_host or not smtp_user or not smtp_password:
        return {"status": "failed", "error": "No SMTP credentials or Resend API key configured", "details": status_info}
        
    try:
        if smtp_port == 465:
            server = smtplib.SMTP_SSL(smtp_host, smtp_port, timeout=10)
        else:
            server = smtplib.SMTP(smtp_host, smtp_port, timeout=10)
            server.starttls()
            
        server.login(smtp_user, smtp_password)
        
        msg = MIMEText("This is an automated Render environment SMTP test.")
        msg['From'] = smtp_user
        msg['To'] = "sayantan05092004@gmail.com"
        msg['Subject'] = "[Community Hero] Render SMTP Verification"
        server.send_message(msg)
        server.quit()
        
        return {"status": "success", "method": "SMTP", "message": "SMTP connection and test email sent successfully from Render!", "details": status_info}
    except Exception as e:
        return {"status": "failed", "method": "SMTP", "error": str(e), "details": status_info}

@app.get("/")
def read_root():
    return {"message": "Welcome to the Community Hero API"}

@app.get("/health")
def health_check(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1"))
        return {"status": "ok", "database": "connected"}
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        raise HTTPException(status_code=503, detail="Database connection failed")
