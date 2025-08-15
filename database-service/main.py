from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import asyncpg
import json
import os
from typing import List, Dict, Any, Optional
from datetime import datetime, timezone, timedelta
import hashlib
import asyncio

from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Database Service", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:root@host.docker.internal:5433/tracker_project_db")
JSON_FILE_PATH = "/app/data/commit.json"

# Database connection pool
db_pool: Optional[asyncpg.Pool] = None

class CommitsRequest(BaseModel):
    commits: List[Dict[str, Any]]

@app.on_event("startup")
async def startup_event():
    """Initialize database connection pool"""
    global db_pool
    try:
        db_pool = await asyncpg.create_pool(
            DATABASE_URL,
            min_size=5,
            max_size=20
        )
        print("Database connection pool created successfully")
    except Exception as e:
        print(f"Error creating database pool: {e}")

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Database Service",
        "status": "running",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "database-service",
        "timestamp": datetime.now().isoformat(),
        "database": "connected" if db_pool else "disconnected"
    }

@app.get("/track-now")
async def track_now():
    """Track Now endpoint - returns latest commits with AI analysis"""
    try:
        # Get latest commits from database
        commits = await get_latest_commits(limit=50)
        
        if not commits:
            # No data in database - trigger GitHub fetch
            print("No commits found in database, triggering GitHub fetch")
            return {
                "success": True,
                "message": "No data found. Please add GitHub token and click 'Track Now' to fetch from GitHub",
                "commits": [],
                "json_data": {"commits": [], "last_updated": datetime.now().isoformat(), "total_commits": 0},
                "total_commits": 0,
                "last_updated": datetime.now().isoformat(),
                "source": "github_api"
            }
        else:
            # Return data from database
            return {
                "success": True,
                "message": "Data retrieved successfully from database",
                "commits": commits,
                "json_data": {"commits": commits, "last_updated": datetime.now().isoformat(), "total_commits": len(commits)},
                "total_commits": len(commits),
                "last_updated": datetime.now().isoformat(),
                "source": "database"
            }
    except Exception as e:
        print(f"Database error: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@app.get("/commits")
async def get_commits(limit: int = 50, repository: str = None):
    """Get commits from database"""
    try:
        commits = await get_commits_from_db(limit=limit, repository=repository)
        return {
            "success": True,
            "commits": commits,
            "total": len(commits)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.post("/store-commits")
async def store_commits(request: CommitsRequest):
    """Store commits from AI service"""
    try:
        stored_count = 0
        
        for commit_data in request.commits:
            # Generate unique hash key
            hash_key = generate_hash(commit_data["commit_sha"])
            
            # Store in database
            success = await store_commit_in_db(commit_data, hash_key)
            if success:
                stored_count += 1
                
                # Update JSON file
                update_json_file(commit_data, hash_key)
        
        return {
            "success": True,
            "message": f"Stored {stored_count} commits",
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.get("/stats")
async def get_stats():
    """Get system statistics"""
    try:
        stats = await get_statistics()
        return {
            "success": True,
            "statistics": stats,
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

async def get_latest_commits(limit: int = 50) -> List[Dict[str, Any]]:
    """Get latest commits from database"""
    try:
        async with db_pool.acquire() as conn:
            rows = await conn.fetch("""
                SELECT id, hash_key, commit_sha, message, author, author_email,
                       repository, branch, created_at, committed_at, 
                       ai_processed, event_status
                FROM track_project.commits 
                ORDER BY created_at DESC 
                LIMIT $1
            """, limit)
            
            commits = []
            for row in rows:
                commit = dict(row)
                
                # Get AI analysis from dedicated table
                ai_analysis = await get_ai_analysis(conn, commit["id"])
                commit["ai_analysis"] = ai_analysis
                
                # Get commit files for this commit
                commit_files = await get_commit_files(conn, commit["id"])
                commit["files"] = commit_files
                
                commits.append(commit)
            
            return commits
    except Exception as e:
        print(f"Error getting commits: {e}")
        return []

async def get_commit_files(conn, commit_id: int) -> List[Dict[str, Any]]:
    """Get files for a specific commit"""
    try:
        rows = await conn.fetch("""
            SELECT file_path, file_name, file_extension, change_type,
                   additions, deletions, changes, patch
            FROM track_project.commit_files 
            WHERE commit_id = $1
            ORDER BY file_path
        """, commit_id)
        
        files = []
        for row in rows:
            files.append(dict(row))
        
        return files
    except Exception as e:
        print(f"Error getting commit files: {e}")
        return []

async def get_commits_from_db(limit: int = 50, repository: str = None) -> List[Dict[str, Any]]:
    """Get commits with optional repository filter"""
    try:
        async with db_pool.acquire() as conn:
            if repository:
                rows = await conn.fetch("""
                    SELECT id, hash_key, commit_sha, message, author, author_email,
                           repository, branch, created_at, committed_at, 
                           ai_processed, ai_analysis, event_status
                    FROM track_project.commits 
                    WHERE repository = $1
                    ORDER BY created_at DESC 
                    LIMIT $2
                """, repository, limit)
            else:
                rows = await conn.fetch("""
                    SELECT id, hash_key, commit_sha, message, author, author_email,
                           repository, branch, created_at, committed_at, 
                           ai_processed, ai_analysis, event_status
                    FROM track_project.commits 
                    ORDER BY created_at DESC 
                    LIMIT $1
                """, limit)
            
            commits = []
            for row in rows:
                commit = dict(row)
                if commit["ai_analysis"]:
                    commit["ai_analysis"] = json.loads(commit["ai_analysis"])
                commits.append(commit)
            
            return commits
    except Exception as e:
        print(f"Error getting commits: {e}")
        return []

async def store_commit_in_db(commit_data: Dict[str, Any], hash_key: str) -> bool:
    """Store commit in PostgreSQL database"""
    try:
        async with db_pool.acquire() as conn:
            # Check if commit already exists
            existing = await conn.fetchrow(
                "SELECT id FROM track_project.commits WHERE hash_key = $1",
                hash_key
            )
            
            if existing:
                commit_id = existing["id"]
                # Update existing commit
                print(f"Updating existing commit {hash_key}")
                await conn.execute("""
                    UPDATE track_project.commits 
                    SET ai_processed = true
                    WHERE hash_key = $1
                """, hash_key)
            else:
                # Parse the actual commit timestamp from GitHub
                committed_at_str = commit_data.get("committed_at", "")
                committed_at = None
                if committed_at_str:
                    try:
                        # GitHub API returns ISO format like "2025-08-15T11:29:38Z"
                        if 'T' in committed_at_str and 'Z' in committed_at_str:
                            # Parse as UTC timestamp
                            committed_at_str = committed_at_str.replace('Z', '+00:00')
                        committed_at = datetime.fromisoformat(committed_at_str)
                        # Convert to local timezone (India Standard Time)
                        if committed_at.tzinfo is not None:
                            # Convert UTC to IST (UTC+05:30)
                            ist_offset = timezone(timedelta(hours=5, minutes=30))
                            committed_at = committed_at.astimezone(ist_offset).replace(tzinfo=None)
                    except Exception as e:
                        print(f"Error parsing commit timestamp '{committed_at_str}': {e}")
                        committed_at = datetime.now()
                else:
                    committed_at = datetime.now()
                
                # Insert new commit
                commit_id = await conn.fetchval("""
                    INSERT INTO track_project.commits (
                        hash_key, commit_sha, message, author, author_email,
                        repository, branch, committed_at, ai_processed
                    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
                    RETURNING id
                """, 
                    hash_key,
                    commit_data.get("commit_sha", ""),
                    commit_data.get("message", ""),
                    commit_data.get("author", ""),
                    commit_data.get("author_email", ""),
                    "jafar90147677/Ai-Agent",  # Updated repository
                    "main",  # Default branch
                    committed_at,
                    True  # AI processed
                )
                
                # Store commit files if available
                if "files" in commit_data:
                    await store_commit_files(conn, commit_id, commit_data["files"])
                
                print(f"Stored commit: {commit_data['commit_sha'][:8]}")
            
            # Store AI analysis in dedicated table
            if commit_data.get("ai_analysis"):
                await store_ai_analysis(conn, commit_id, commit_data["ai_analysis"])
            
            return True
    except Exception as e:
        print(f"Error storing commit: {e}")
        return False

async def store_commit_files(conn, commit_id: int, files: List[Dict[str, Any]]):
    """Store commit files in database"""
    try:
        for file_data in files:
            await conn.execute("""
                INSERT INTO track_project.commit_files (
                    commit_id, file_path, file_name, file_extension,
                    change_type, additions, deletions, changes, patch
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            """,
                commit_id,
                file_data.get("filename", ""),
                file_data.get("filename", "").split("/")[-1] if file_data.get("filename") else "",
                file_data.get("filename", "").split(".")[-1] if file_data.get("filename") and "." in file_data.get("filename") else "",
                file_data.get("status", "modified"),
                file_data.get("additions", 0),
                file_data.get("deletions", 0),
                file_data.get("changes", 0),
                file_data.get("patch", "")
            )
    except Exception as e:
        print(f"Error storing commit files: {e}")


async def store_ai_analysis(conn, commit_id: int, ai_analysis: Dict[str, Any]):
    """Store AI analysis in dedicated table"""
    try:
        # Check if AI analysis already exists for this commit
        existing = await conn.fetchrow(
            "SELECT id FROM track_project.ai_analysis WHERE commit_id = $1",
            commit_id
        )
        
        if existing:
            # Update existing AI analysis
            await conn.execute("""
                UPDATE track_project.ai_analysis 
                SET analysis_type = $1, results = $2, confidence_score = $3
                WHERE commit_id = $4
            """, 
                "commit_analysis",
                json.dumps(ai_analysis),
                ai_analysis.get("confidence_score", 0.0),
                commit_id
            )
            print(f"Updated AI analysis for commit {commit_id}")
        else:
            # Insert new AI analysis
            await conn.execute("""
                INSERT INTO track_project.ai_analysis (
                    commit_id, analysis_type, results, confidence_score
                ) VALUES ($1, $2, $3, $4)
            """,
                commit_id,
                "commit_analysis",
                json.dumps(ai_analysis),
                ai_analysis.get("confidence_score", 0.0)
            )
            print(f"Stored AI analysis for commit {commit_id}")
    except Exception as e:
        print(f"Error storing AI analysis: {e}")


async def get_ai_analysis(conn, commit_id: int) -> Dict[str, Any]:
    """Get AI analysis for a specific commit"""
    try:
        row = await conn.fetchrow("""
            SELECT results, confidence_score, analysis_type
            FROM track_project.ai_analysis 
            WHERE commit_id = $1
        """, commit_id)
        
        if row:
            ai_data = json.loads(row["results"]) if row["results"] else {}
            return ai_data
        else:
            return {}
    except Exception as e:
        print(f"Error getting AI analysis: {e}")
        return {}

async def get_statistics() -> Dict[str, Any]:
    """Get system statistics"""
    try:
        async with db_pool.acquire() as conn:
            # Total commits
            total_commits = await conn.fetchval("SELECT COUNT(*) FROM track_project.commits")
            
            # AI processed commits
            ai_processed = await conn.fetchval(
                "SELECT COUNT(*) FROM track_project.commits WHERE ai_processed = true"
            )
            
            # Unique repositories
            repositories = await conn.fetch(
                "SELECT DISTINCT repository FROM track_project.commits"
            )
            repo_list = [row["repository"] for row in repositories]
            
            # Last fetch time
            last_fetch = await conn.fetchval(
                "SELECT last_checked FROM track_project.tracking_config LIMIT 1"
            )
            
            return {
                "total_commits": total_commits,
                "ai_processed": ai_processed,
                "repositories": repo_list,
                "last_fetch": last_fetch.isoformat() if last_fetch else None
            }
    except Exception as e:
        print(f"Error getting statistics: {e}")
        return {
            "total_commits": 0,
            "ai_processed": 0,
            "repositories": [],
            "last_fetch": None
        }

def generate_hash(commit_sha: str) -> str:
    """Generate unique hash key for commit"""
    # Use only commit_sha to ensure same commit always gets same hash
    hash_input = f"{commit_sha}"
    return hashlib.sha256(hash_input.encode()).hexdigest()

def update_json_file(commit_data: Dict[str, Any], hash_key: str) -> bool:
    """Update JSON file with new commit data (disabled - using GitHub API only)"""
    # JSON fallback disabled - only using GitHub API
    return True

def get_json_data() -> Dict[str, Any]:
    """Get data from commit.json file (disabled - using GitHub API only)"""
    # JSON fallback disabled - only using GitHub API
    return {
        "commits": [],
        "last_updated": datetime.now().isoformat(),
        "total_commits": 0
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8003)
