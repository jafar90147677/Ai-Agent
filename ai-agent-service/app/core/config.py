import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    # Database settings
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql://user:password@localhost:5432/github_tracker")
    
    # GitHub settings
    GITHUB_TOKEN: str = os.getenv("GITHUB_TOKEN", "")
    GITHUB_REPO: str = os.getenv("GITHUB_REPO", "your-username/your-repo")
    
    # Application settings
    APP_NAME: str = "GitHub Commit Tracker AI Agent"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = os.getenv("DEBUG", "False").lower() == "true"
    
    # AI settings
    AI_CHECK_INTERVAL: int = int(os.getenv("AI_CHECK_INTERVAL", "300"))  # 5 minutes
    AI_CONFIDENCE_THRESHOLD: float = float(os.getenv("AI_CONFIDENCE_THRESHOLD", "0.7"))
    
    # File settings
    JSON_FILE_PATH: str = "/app/data/commit.json"
    
    class Config:
        env_file = ".env"

settings = Settings()
