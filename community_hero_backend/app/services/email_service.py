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
    
    # Try sending via Resend HTTP API first if configured (bypasses cloud SMTP port blocks)
    resend_api_key = getattr(settings, "RESEND_API_KEY", "")
    if resend_api_key:
        try:
            import urllib.request
            import json
            # Resend free tier allows sending to the account owner from onboarding@resend.dev
            payload = {
                "from": "Community Hero <onboarding@resend.dev>",
                "to": [to_email],
                "subject": subject,
                "text": body
            }
            # Attach base64 files if present
            # (Resend accepts attachments list in JSON)
            attachments = []
            for path in image_paths:
                if os.path.exists(path):
                    import base64
                    with open(path, "rb") as f:
                        content_b64 = base64.b64encode(f.read()).decode("utf-8")
                    attachments.append({
                        "content": content_b64,
                        "filename": os.path.basename(path)
                    })
            if attachments:
                payload["attachments"] = attachments

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
            
            with urllib.request.urlopen(req, timeout=15) as response:
                response_code = response.getcode()
                response_text = response.read().decode("utf-8")
                
            if response_code in [200, 201]:
                logger.info(f"Email sent successfully via Resend API to {to_email}")
                return True
            else:
                logger.error(f"Resend API returned error {response_code}: {response_text}")
        except Exception as e:
            logger.error(f"Failed to send email via Resend API: {e}")

    # Check if SMTP credentials are set
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
        msg.attach(MIMEText(body, 'plain', 'utf-8'))

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

        if smtp_port == 465:
            server = smtplib.SMTP_SSL(smtp_host, smtp_port, timeout=10)
        else:
            server = smtplib.SMTP(smtp_host, smtp_port, timeout=10)
            server.starttls()
            
        server.login(smtp_user, smtp_password)
        server.send_message(msg)
        server.quit()
        logger.info(f"Email sent successfully via SMTP to {to_email}")
        return True
    except Exception as e:
        logger.error(f"Failed to send email via SMTP: {e}")
        return False
