from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Community Hero API"
    DATABASE_URL: str = "postgresql://neondb_owner:npg_X3pdsm0IQyWJ@ep-raspy-wildflower-at7g1igd.c-9.us-east-1.aws.neon.tech/neondb?sslmode=require"
    SECRET_KEY: str = "supersecretkey"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    OPENROUTER_API_KEY: str = ""

    class Config:
        env_file = ".env"

settings = Settings()
