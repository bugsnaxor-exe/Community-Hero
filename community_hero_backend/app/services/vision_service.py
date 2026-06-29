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
import re

def analyze_issue_image(image_path: str) -> dict:
    """
    Sends the image to Google Gemini Vision to extract rich metadata.
    Returns a dictionary with: category, confidence, severity, reasoning.
    Defaults to treating images as VALID to avoid false rejections.
    """
    if not settings.OPENROUTER_API_KEY:
        logger.warning("OPENROUTER_API_KEY is not set. Skipping vision analysis.")
        return {"category": "other", "confidence": 0.5, "severity": 3.0, "reasoning": "No API key configured."}

    try:
        base64_image = encode_image_to_base64(image_path)
        logger.info(f"Analyzing image: {image_path} (base64 length: {len(base64_image)})")

        prompt = """You are analyzing a photo uploaded by a citizen to report a community infrastructure problem.

Your job: classify the photo into one of these categories and return RAW JSON (no markdown, no backticks).

JSON keys:
- "category": one of ["pothole", "water_leakage", "garbage_dump", "broken_streetlight", "road_damage", "drainage_issue", "other", "invalid"]
- "confidence": float 0.0 to 1.0
- "severity": float 0.0 to 10.0
- "reasoning": one sentence explanation

WHEN TO USE "invalid":
Use "invalid" ONLY for images that are clearly NOT photographs of real-world scenes. Examples:
- Screenshots of apps, websites, games, or text messages
- Memes, cartoons, or digitally generated graphics
- QR codes or barcodes
- Selfies or portraits with no infrastructure visible

WHEN TO USE ANY OTHER CATEGORY:
If the image is a photograph taken outdoors showing ANY of these, it is VALID:
- Roads, streets, pavements, sidewalks (even close-ups)
- Holes, cracks, broken surfaces on roads
- Garbage, litter, waste on streets or public areas
- Street lights, utility poles, pipes, drains
- Construction debris, broken infrastructure
- ANY outdoor public space

IMPORTANT: When in doubt, classify as "other" — NEVER as "invalid". Real photos of roads, even blurry or dark ones, are ALWAYS valid."""

        response = client.chat.completions.create(
            model="google/gemini-2.0-flash-001",
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
        logger.info(f"Raw AI response: {answer}")
        
        # Clean up any potential markdown code blocks
        if answer.startswith("```json"):
            answer = answer[7:]
        if answer.startswith("```"):
            answer = answer[3:]
        if answer.endswith("```"):
            answer = answer[:-3]
        
        # Try to extract JSON from the response even if surrounded by text
        answer = answer.strip()
        json_match = re.search(r'\{[^{}]*\}', answer, re.DOTALL)
        if json_match:
            answer = json_match.group(0)
            
        data = json.loads(answer.strip())
        logger.info(f"Parsed AI result: category={data.get('category')}, confidence={data.get('confidence')}, severity={data.get('severity')}")
        return data
        
    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse AI JSON response: {e}. Raw: {answer if 'answer' in dir() else 'N/A'}")
        # Default to valid on parse failure
        return {"category": "other", "confidence": 0.5, "severity": 3.0, "reasoning": "AI response could not be parsed. Defaulting to valid."}
    except Exception as e:
        logger.error(f"Error in vision analysis: {str(e)}")
        # Default to valid on any error — never block the user due to API issues
        return {"category": "other", "confidence": 0.5, "severity": 3.0, "reasoning": "Analysis service temporarily unavailable. Defaulting to valid."}

