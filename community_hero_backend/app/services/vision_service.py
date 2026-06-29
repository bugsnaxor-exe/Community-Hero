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
        Analyze this image for civic and community issues. Return a RAW JSON object (no markdown formatting, no backticks).
        The JSON must contain exactly these 4 keys:
        - "category": Must be one of ["pothole", "water_leakage", "garbage_dump", "broken_streetlight", "road_damage", "drainage_issue", "other", "invalid"].
        - "confidence": A float between 0.0 and 1.0 representing your confidence.
        - "severity": A float between 0.0 and 10.0 representing the severity.
        - "reasoning": A short sentence explaining your choice.
        
        CLASSIFICATION RULES:
        1. Set category to "invalid" ONLY if the image is clearly NOT a community/infrastructure/civic scene. Obvious examples of "invalid" are: selfies/portraits of people, indoor screenshots of games/software/chats/websites, QR codes, document scans, memes, isolated household items (e.g. inside a cup, computer keyboard), isolated pets or food, or graphical charts.
        2. If the image shows an outdoor public environment, a street, sidewalk, road, public utility, construction site, park, or infrastructure element, it is a VALID issue. Even if it is unclear, if it is outdoor/utility, classify it under a matching category or "other". Do NOT set it to "invalid" if it shows a real outdoor or public utility scene.
        3. Close-up photos of potholes, road cracks, broken pavement, garbage piles, or utility pipes are VALID community issues. Do NOT mark close-up photos of infrastructure damage as invalid just because the surrounding street or background is not visible.
        4. If the image contains a street, road, sidewalk, pavement, pothole, street light, or outdoor garbage, it is 100% VALID. You must classify it under 'pothole', 'road_damage', 'garbage_dump', or 'other'. It is CRITICAL that you never classify these as 'invalid'.
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

