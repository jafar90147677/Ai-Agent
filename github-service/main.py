from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
import aiohttp
import asyncio
import os
from datetime import datetime
from typing import List, Dict, Any
import json

from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="GitHub Service", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN", "")
GITHUB_REPO = os.getenv("GITHUB_REPO", "your-username/your-repo")
BASE_URL = "https://api.github.com"

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "GitHub Service",
        "status": "running",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "github-service",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/commits")
async def get_commits():
    """Get commits from GitHub"""
    if not GITHUB_TOKEN:
        raise HTTPException(status_code=400, detail="GitHub token not configured")
        
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    url = f"{BASE_URL}/repos/{GITHUB_REPO}/commits"
    
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(url, headers=headers) as response:
                if response.status == 200:
                    commits = await response.json()
                    
                    # Fetch detailed commit information including files
                    detailed_commits = []
                    for commit in commits[:10]:  # Limit to 10 commits for performance
                        detailed_commit = await get_commit_details(session, headers, commit["sha"])
                        detailed_commits.append(detailed_commit)
                    
                    return {
                        "success": True,
                        "commits": detailed_commits,
                        "total": len(detailed_commits)
                    }
                else:
                    raise HTTPException(status_code=response.status, detail="GitHub API error")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching commits: {str(e)}")

async def get_commit_details(session, headers, commit_sha: str) -> Dict[str, Any]:
    """Get detailed commit information including files"""
    try:
        url = f"{BASE_URL}/repos/{GITHUB_REPO}/commits/{commit_sha}"
        async with session.get(url, headers=headers) as response:
            if response.status == 200:
                commit_data = await response.json()
                return commit_data
            else:
                return {"sha": commit_sha, "error": "Failed to fetch details"}
    except Exception as e:
        return {"sha": commit_sha, "error": str(e)}

@app.post("/fetch-commits")
async def fetch_commits(background_tasks: BackgroundTasks):
    """Fetch commits and send to AI service for processing"""
    try:
        # Fetch commits from GitHub
        commits_data = await get_commits()
        
        if commits_data["success"]:
            # Process commits (send to AI service)
            background_tasks.add_task(process_commits, commits_data["commits"])
            
            return {
                "success": True,
                "message": f"Fetched {len(commits_data['commits'])} commits",
                "timestamp": datetime.now().isoformat()
            }
        else:
            raise HTTPException(status_code=500, detail="Failed to fetch commits")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

async def process_commits(commits: List[Dict[str, Any]]):
    """Process commits by sending to AI service"""
    try:
        # Send commits to AI service for analysis
        ai_service_url = "http://ai-service:8002/process-commits"
        
        async with aiohttp.ClientSession() as session:
            async with session.post(ai_service_url, json={"commits": commits}) as response:
                if response.status == 200:
                    print(f"Sent {len(commits)} commits to AI service")
                else:
                    print(f"Error sending commits to AI service: {response.status}")
                    
    except Exception as e:
        print(f"Error processing commits: {e}")

@app.get("/repository-info")
async def get_repository_info():
    """Get repository information"""
    if not GITHUB_TOKEN:
        raise HTTPException(status_code=400, detail="GitHub token not configured")
        
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    url = f"{BASE_URL}/repos/{GITHUB_REPO}"
    
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(url, headers=headers) as response:
                if response.status == 200:
                    repo_info = await response.json()
                    return {
                        "success": True,
                        "repository": repo_info
                    }
                else:
                    raise HTTPException(status_code=response.status, detail="GitHub API error")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
