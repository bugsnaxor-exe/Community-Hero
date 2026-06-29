import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email.encoders import encode_base64
import os
import logging
from app.core.config import settings

logger = logging.getLogger(__name__)

def send_issue_email(
    to_email: str,
    title: str,
    description: str,
    category: str,
    severity: str,
    latitude: float,
    longitude: float,
    reporter_email: str,
    image_paths: list = None
) -> bool:
    if image_paths is None:
        image_paths = []
        
    subject = f"[Community Hero] New Issue Reported: {title or category}"
    
    body = f"""A new community issue has been submitted.

Title: {title or 'N/A'}
Category: {category}
Severity: {severity}
Location Coordinates: {latitude}, {longitude}
Description: {description}
Reporter Account: {reporter_email}
"""
    
    # Check if credentials are set
    smtp_host = getattr(settings, "SMTP_HOST", "")
    smtp_port = getattr(settings, "SMTP_PORT", 587)
    smtp_user = getattr(settings, "SMTP_USER", "")
    smtp_password = getattr(settings, "SMTP_PASSWORD", "")

    if not smtp_host or not smtp_user or not smtp_password:
        logger.warning("=" * 60)
        logger.warning("SMTP credentials not configured. Printing email content instead:")
        logger.warning(f"To: {to_email}")
        logger.warning(f"Subject: {subject}")
        logger.warning(f"Body:\n{body}")
        logger.warning("=" * 60)
        return False

    try:
        msg = MIMEMultipart()
        msg['From'] = smtp_user
        msg['To'] = to_email
        msg['Subject'] = subject
        msg.attach(MIMEText(body, 'plain'))

        for path in image_paths:
            if os.path.exists(path):
                filename = os.path.basename(path)
                with open(path, "rb") as f:
                    part = MIMEBase("application", "octet-stream")
                    part.set_payload(f.read())
                encode_base64(part)
                part.add_header(
                    "Content-Disposition",
                    f"attachment; filename= {filename}",
                )
                msg.attach(part)

        server = smtplib.SMTP(smtp_host, smtp_port)
        server.starttls()
        server.login(smtp_user, smtp_password)
        server.send_message(msg)
        server.quit()
        logger.info(f"Email sent successfully to {to_email}")
        return True
    except Exception as e:
        logger.error(f"Failed to send email: {e}")
        return False
