import base64
from openai import OpenAI
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

import json
import re

def encode_image_to_base64(image_path: str) -> str:
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode("utf-8")

# Models to try in order — first available one wins
MODELS = [
    "google/gemini-2.5-flash-preview",
    "google/gemini-1.5-flash",
]

def analyze_issue_image(image_path: str) -> dict:
    """
    Sends the image to Google Gemini Vision to extract rich metadata.
    Returns a dictionary with: category, confidence, severity, reasoning.
    Returns empty dict {} on failure so the caller can decide what to do.
    """
    if not settings.OPENROUTER_API_KEY:
        logger.warning("OPENROUTER_API_KEY is not set. Skipping vision analysis.")
        return {}

    try:
        client = OpenAI(
            base_url="https://openrouter.ai/api/v1",
            api_key=settings.OPENROUTER_API_KEY,
        )
        base64_image = encode_image_to_base64(image_path)
        logger.info(f"Analyzing image: {image_path} (base64 length: {len(base64_image)})")

        prompt = """You are a strict image validator for a civic issue reporting app. Analyze this image and return RAW JSON only (no markdown, no backticks, no extra text).

JSON format:
{"category": "...", "confidence": 0.0, "severity": 0.0, "reasoning": "..."}

CATEGORY must be exactly one of: "pothole", "water_leakage", "garbage_dump", "broken_streetlight", "road_damage", "drainage_issue", "other", "invalid"

RULES:
1. "invalid" — Use this if the image is a DIGITAL screenshot (showing app UI, website, chat, game, code editor), a meme, a QR code, a document scan, a selfie/portrait, food, or an indoor household object with no civic relevance. If you see UI elements like buttons, navigation bars, status bars, or app interfaces, it is DEFINITELY "invalid".

2. ANY other category — Use if the image is a real-world photograph showing outdoor infrastructure, roads, streets, potholes, broken pavement, garbage, streetlights, drainage, water damage, or any public space. Close-up photos of road damage ARE valid potholes. Dark, blurry, or poorly-lit outdoor photos ARE still valid.

3. When uncertain between "invalid" and a real category, choose "other" (NOT "invalid").

Return ONLY the JSON object, nothing else."""

        # Try models in priority order
        last_error = None
        for model_id in MODELS:
            try:
                logger.info(f"Trying model: {model_id}")
                response = client.chat.completions.create(
                    model=model_id,
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
                logger.info(f"Raw AI response from {model_id}: {answer}")
                
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
                logger.info(f"Parsed AI result: category={data.get('category')}, confidence={data.get('confidence')}, severity={data.get('severity')}, reasoning={data.get('reasoning')}")
                return data
                
            except Exception as model_error:
                logger.warning(f"Model {model_id} failed: {model_error}")
                last_error = model_error
                continue
        
        # All models failed
        logger.error(f"All models failed. Last error: {last_error}")
        return {}
        
    except Exception as e:
        logger.error(f"Error in vision analysis: {str(e)}")
        return {}

