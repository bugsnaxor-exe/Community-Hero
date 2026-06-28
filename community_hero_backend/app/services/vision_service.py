import base64
from openai import OpenAI
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

# Initialize OpenAI client pointing to OpenRouter
client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=settings.OPENROUTER_API_KEY,
)

def encode_image_to_base64(image_path: str) -> str:
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode("utf-8")

import json

def analyze_issue_image(image_path: str) -> dict:
    """
    Sends the image to Google Gemini Vision to extract rich metadata.
    Returns a dictionary with: category, confidence, severity, reasoning.
    """
    if not settings.OPENROUTER_API_KEY:
        logger.warning("OPENROUTER_API_KEY is not set. Skipping vision analysis.")
        return {}

    try:
        base64_image = encode_image_to_base64(image_path)

        prompt = """
        Analyze this image for community issues. Return a RAW JSON object (no markdown formatting, no backticks).
        The JSON must contain exactly these 4 keys:
        - "category": Must be one of ["pothole", "water_leakage", "garbage_dump", "broken_streetlight", "road_damage", "drainage_issue", "other", "invalid"].
        - "confidence": A float between 0.0 and 1.0 representing your confidence in the category.
        - "severity": A float between 0.0 and 10.0 representing the physical severity or danger of the issue.
        - "reasoning": A short sentence explaining why you chose this category and severity.
        
        CRITICAL: If the image is clearly NOT a community issue (e.g., a selfie, a screenshot of a game like Clash of Clans, a random object, a QR code, or any image completely unrelated to infrastructure or community problems), you MUST set "category" to "invalid", "confidence" to 1.0, and "severity" to 0.0. Do not attempt to classify random images into valid categories.
        """

        response = client.chat.completions.create(
            model="google/gemini-1.5-flash",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": prompt
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{base64_image}"
                            }
                        }
                    ]
                }
            ],
            max_tokens=300,
        )
        
        answer = response.choices[0].message.content.strip()
        # Clean up any potential markdown code blocks
        if answer.startswith("```json"):
            answer = answer[7:]
        if answer.startswith("```"):
            answer = answer[3:]
        if answer.endswith("```"):
            answer = answer[:-3]
            
        data = json.loads(answer.strip())
        return data
        
    except Exception as e:
        logger.error(f"Error in vision analysis: {str(e)}")
        return {}

