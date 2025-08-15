from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import httpx
from datetime import datetime

app = FastAPI(title="API Gateway", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Service URLs
GITHUB_SERVICE_URL = "http://github-service:8001"
AI_SERVICE_URL = "http://ai-service:8002"
DATABASE_SERVICE_URL = "http://database-service:8003"
GITHUB_ANALYSIS_SERVICE_URL = "http://github-analysis-service:8004"

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "API Gateway - GitHub Commit Tracker",
        "status": "running",
        "timestamp": datetime.now().isoformat(),
        "services": {
            "github_service": GITHUB_SERVICE_URL,
            "ai_service": AI_SERVICE_URL,
            "database_service": DATABASE_SERVICE_URL,
            "github_analysis_service": GITHUB_ANALYSIS_SERVICE_URL
        }
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "api-gateway",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/track-now")
async def track_now():
    """Track Now endpoint - fetches fresh data from GitHub, processes with AI, and stores in database"""
    try:
        async with httpx.AsyncClient() as client:
            # Step 1: Fetch fresh commits from GitHub
            print("Fetching fresh commits from GitHub...")
            github_response = await client.get(f"{GITHUB_SERVICE_URL}/commits")
            if github_response.status_code != 200:
                raise HTTPException(status_code=500, detail="Failed to fetch from GitHub")
            
            github_data = github_response.json()
            if not github_data.get("success"):
                raise HTTPException(status_code=500, detail="GitHub service error")
            
            commits = github_data.get("commits", [])
            print(f"Fetched {len(commits)} commits from GitHub")
            
            # Step 2: Process commits with AI analysis
            if commits:
                print("Processing commits with AI...")
                for commit in commits:
                    try:
                        # Analyze commit message
                        ai_response = await client.post(
                            f"{AI_SERVICE_URL}/analyze", 
                            json={"message": commit.get("commit", {}).get("message", "")}
                        )
                        if ai_response.status_code == 200:
                            ai_data = ai_response.json()
                            # Extract just the analysis part from the AI response
                            if ai_data.get("success") and ai_data.get("analysis"):
                                commit["ai_analysis"] = ai_data["analysis"]
                            else:
                                commit["ai_analysis"] = ai_data
                    except Exception as e:
                        print(f"Error analyzing commit {commit.get('sha', 'unknown')}: {e}")
                        commit["ai_analysis"] = {}
            
            # Step 3: Store commits in database
            if commits:
                print("Storing commits in database...")
                # Transform GitHub data to database format
                db_commits = []
                for commit in commits:
                    db_commit = {
                        "commit_sha": commit.get("sha", ""),
                        "message": commit.get("commit", {}).get("message", ""),
                        "author": commit.get("commit", {}).get("author", {}).get("name", ""),
                        "author_email": commit.get("commit", {}).get("author", {}).get("email", ""),
                        "committed_at": commit.get("commit", {}).get("author", {}).get("date", ""),
                        "ai_analysis": commit.get("ai_analysis", {}),
                        "files": commit.get("files", [])
                    }
                    db_commits.append(db_commit)
                
                # Store in database
                db_response = await client.post(
                    f"{DATABASE_SERVICE_URL}/store-commits",
                    json={"commits": db_commits}
                )
                if db_response.status_code != 200:
                    print(f"Warning: Failed to store commits in database: {db_response.text}")
            
            # Step 4: Return fresh data from database
            print("Retrieving fresh data from database...")
            db_response = await client.get(f"{DATABASE_SERVICE_URL}/track-now")
            if db_response.status_code == 200:
                result = db_response.json()
                result["message"] = f"Successfully fetched {len(commits)} fresh commits from GitHub and stored in database"
                result["source"] = "github_api_fresh"
                return result
            else:
                raise HTTPException(status_code=500, detail="Failed to retrieve data from database")
                
    except Exception as e:
        print(f"Error in track_now: {e}")
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.get("/commits")
async def get_commits(limit: int = 50, repository: str = None):
    """Get commits - routes to database service"""
    try:
        params = {"limit": limit}
        if repository:
            params["repository"] = repository
            
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{DATABASE_SERVICE_URL}/commits", params=params)
            return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.post("/fetch-commits")
async def fetch_commits():
    """Fetch commits - routes to GitHub service"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(f"{GITHUB_SERVICE_URL}/fetch-commits")
            return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.get("/stats")
async def get_stats():
    """Get statistics - routes to database service"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{DATABASE_SERVICE_URL}/stats")
            return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.post("/analyze-commit")
async def analyze_commit(message: str):
    """Analyze commit - routes to AI service"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(f"{AI_SERVICE_URL}/analyze", json={"message": message})
            return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.post("/analyze-hash")
async def analyze_hash(commit_data: dict):
    """Analyze commit hash - routes to GitHub Analysis service"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(f"{GITHUB_ANALYSIS_SERVICE_URL}/analyze-hash", json=commit_data)
            return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.get("/hash-stats")
async def get_hash_stats():
    """Get hash analysis statistics - routes to GitHub Analysis service"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{GITHUB_ANALYSIS_SERVICE_URL}/hash-stats")
            return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
