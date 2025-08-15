import json
import os
from typing import List, Dict, Any, Optional
from datetime import datetime
import asyncpg

from app.core.config import settings
from app.core.database import get_db

class DataStorage:
    def __init__(self):
        self.json_file_path = settings.JSON_FILE_PATH
        
    async def store_commit(self, commit_data: Dict[str, Any]) -> bool:
        """Store commit in PostgreSQL database"""
        try:
            db_pool = await get_db()
            async with db_pool.acquire() as conn:
                # Check if commit already exists
                existing = await conn.fetchrow(
                    "SELECT id FROM track_project.commits WHERE hash_key = $1",
                    commit_data["hash_key"]
                )
                
                if existing:
                    print(f"Commit {commit_data['hash_key']} already exists")
                    return False
                
                # Insert new commit
                await conn.execute("""
                    INSERT INTO track_project.commits (
                        hash_key, commit_sha, message, author, author_email,
                        repository, branch, committed_at, ai_processed, ai_analysis
                    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
                """, 
                    commit_data["hash_key"],
                    commit_data["commit_sha"],
                    commit_data["message"],
                    commit_data["author"],
                    commit_data["author_email"],
                    commit_data["repository"],
                    commit_data["branch"],
                    commit_data["committed_at"],
                    True,  # AI processed
                    json.dumps(commit_data.get("ai_analysis", {}))
                )
                
                print(f"Stored commit: {commit_data['commit_sha'][:8]}")
                return True
                
        except Exception as e:
            print(f"Error storing commit: {e}")
            return False
    
    async def get_latest_commits(self, limit: int = 50) -> List[Dict[str, Any]]:
        """Get latest commits from database"""
        try:
            db_pool = await get_db()
            async with db_pool.acquire() as conn:
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
    
    async def get_commits(self, limit: int = 50, repository: str = None) -> List[Dict[str, Any]]:
        """Get commits with optional repository filter"""
        try:
            db_pool = await get_db()
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
    
    async def get_statistics(self) -> Dict[str, Any]:
        """Get system statistics"""
        try:
            db_pool = await get_db()
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
    
    def update_json_file(self, commit_data: Dict[str, Any]) -> bool:
        """Update commit.json file with new commit data"""
        try:
            # Ensure directory exists
            os.makedirs(os.path.dirname(self.json_file_path), exist_ok=True)
            
            # Load existing data or create new
            if os.path.exists(self.json_file_path):
                with open(self.json_file_path, 'r') as f:
                    data = json.load(f)
            else:
                data = {
                    "commits": [],
                    "last_updated": datetime.now().isoformat(),
                    "total_commits": 0
                }
            
            # Add new commit
            commit_entry = {
                "hash_key": commit_data["hash_key"],
                "commit_sha": commit_data["commit_sha"],
                "message": commit_data["message"],
                "author": commit_data["author"],
                "repository": commit_data["repository"],
                "committed_at": commit_data["committed_at"].isoformat(),
                "ai_analysis": commit_data.get("ai_analysis", {})
            }
            
            data["commits"].insert(0, commit_entry)  # Add to beginning
            data["last_updated"] = datetime.now().isoformat()
            data["total_commits"] = len(data["commits"])
            
            # Keep only last 100 commits in JSON file
            if len(data["commits"]) > 100:
                data["commits"] = data["commits"][:100]
            
            # Write back to file
            with open(self.json_file_path, 'w') as f:
                json.dump(data, f, indent=2)
            
            return True
            
        except Exception as e:
            print(f"Error updating JSON file: {e}")
            return False
    
    def get_json_data(self) -> Dict[str, Any]:
        """Get data from commit.json file"""
        try:
            if os.path.exists(self.json_file_path):
                with open(self.json_file_path, 'r') as f:
                    return json.load(f)
            else:
                return {
                    "commits": [],
                    "last_updated": datetime.now().isoformat(),
                    "total_commits": 0
                }
        except Exception as e:
            print(f"Error reading JSON file: {e}")
            return {
                "commits": [],
                "last_updated": datetime.now().isoformat(),
                "total_commits": 0
            }
