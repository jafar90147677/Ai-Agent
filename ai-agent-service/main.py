from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
import asyncio
import os
from datetime import datetime
import json

from app.core.config import settings
from app.core.database import init_db
from app.services.github_fetcher import GitHubFetcher
from app.services.ai_processor import AIProcessor
from app.services.data_storage import DataStorage
from app.schemas.commit_schemas import CommitResponse, TrackNowResponse
from app.utils.hash_generator import HashGenerator

app = FastAPI(title="GitHub Commit Tracker AI Agent", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global instances
github_fetcher = None
ai_processor = None
data_storage = None
hash_generator = None

@app.on_event("startup")
async def startup_event():
    """Initialize services and start background tasks"""
    global github_fetcher, ai_processor, data_storage, hash_generator
    
    # Initialize database
    await init_db()
    
    # Initialize services
    github_fetcher = GitHubFetcher()
    ai_processor = AIProcessor()
    data_storage = DataStorage()
    hash_generator = HashGenerator()
    
    # Start background task for continuous fetching
    asyncio.create_task(run_continuous_fetching())

async def run_continuous_fetching():
    """Background task that continuously fetches commits from GitHub"""
    while True:
        try:
            await github_fetcher.fetch_and_process_commits()
            print(f"[{datetime.now()}] Fetched and processed commits from GitHub")
        except Exception as e:
            print(f"[{datetime.now()}] Error in continuous fetching: {str(e)}")
        
        # Wait for 5 minutes before next fetch
        await asyncio.sleep(300)

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "GitHub Commit Tracker AI Agent",
        "status": "running",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "ai-agent",
        "timestamp": datetime.now().isoformat(),
        "database": "connected" if data_storage else "disconnected"
    }

@app.get("/track-now", response_model=TrackNowResponse)
async def track_now():
    """Track Now button endpoint - returns latest commits with AI analysis"""
    try:
        # Get latest commits from database
        commits = await data_storage.get_latest_commits(limit=50)
        
        # Get commit.json file content
        json_data = data_storage.get_json_data()
        
        return TrackNowResponse(
            success=True,
            message="Data retrieved successfully",
            commits=commits,
            json_data=json_data,
            total_commits=len(commits),
            last_updated=datetime.now().isoformat()
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error retrieving data: {str(e)}")

@app.post("/fetch-commits")
async def fetch_commits(background_tasks: BackgroundTasks):
    """Manually trigger commit fetching"""
    try:
        background_tasks.add_task(github_fetcher.fetch_and_process_commits)
        return {
            "success": True,
            "message": "Commit fetching started in background",
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error starting fetch: {str(e)}")

@app.get("/commits")
async def get_commits(limit: int = 50, repository: str = None):
    """Get commits from database"""
    try:
        commits = await data_storage.get_commits(limit=limit, repository=repository)
        return {
            "success": True,
            "commits": commits,
            "total": len(commits)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error retrieving commits: {str(e)}")

@app.get("/stats")
async def get_stats():
    """Get system statistics"""
    try:
        stats = await data_storage.get_statistics()
        return {
            "success": True,
            "statistics": stats,
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error retrieving stats: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
