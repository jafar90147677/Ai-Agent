import aiohttp
import asyncio
from datetime import datetime
from typing import List, Dict, Any
import json

from app.core.config import settings
from app.core.database import get_db
from app.services.ai_processor import AIProcessor
from app.services.data_storage import DataStorage
from app.utils.hash_generator import HashGenerator

class GitHubFetcher:
    def __init__(self):
        self.github_token = settings.GITHUB_TOKEN
        self.repository = settings.GITHUB_REPO
        self.base_url = "https://api.github.com"
        self.ai_processor = AIProcessor()
        self.data_storage = DataStorage()
        self.hash_generator = HashGenerator()
        
    async def fetch_commits(self) -> List[Dict[str, Any]]:
        """Fetch commits from GitHub repository"""
        if not self.github_token:
            print("GitHub token not configured")
            return []
            
        headers = {
            "Authorization": f"token {self.github_token}",
            "Accept": "application/vnd.github.v3+json"
        }
        
        url = f"{self.base_url}/repos/{self.repository}/commits"
        
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(url, headers=headers) as response:
                    if response.status == 200:
                        commits = await response.json()
                        return commits
                    else:
                        print(f"Error fetching commits: {response.status}")
                        return []
        except Exception as e:
            print(f"Error fetching commits: {e}")
            return []
    
    async def process_commit(self, commit_data: Dict[str, Any]) -> Dict[str, Any]:
        """Process a single commit"""
        # Extract commit information
        commit_info = {
            "commit_sha": commit_data["sha"],
            "message": commit_data["commit"]["message"],
            "author": commit_data["commit"]["author"]["name"],
            "author_email": commit_data["commit"]["author"]["email"],
            "repository": self.repository,
            "branch": "main",  # Default branch
            "committed_at": datetime.fromisoformat(
                commit_data["commit"]["author"]["date"].replace("Z", "+00:00")
            ),
            "hash_key": self.hash_generator.generate_hash(commit_data["sha"])
        }
        
        # Process with AI
        ai_analysis = await self.ai_processor.analyze_commit(commit_info["message"])
        commit_info["ai_analysis"] = ai_analysis
        
        return commit_info
    
    async def fetch_and_process_commits(self):
        """Fetch commits from GitHub and process them"""
        print(f"Fetching commits from {self.repository}")
        
        # Fetch commits from GitHub
        commits = await self.fetch_commits()
        
        if not commits:
            print("No commits found or error occurred")
            return
        
        # Process each commit
        for commit_data in commits:
            try:
                commit_info = await self.process_commit(commit_data)
                
                # Store in database
                await self.data_storage.store_commit(commit_info)
                
                # Update JSON file
                self.data_storage.update_json_file(commit_info)
                
                print(f"Processed commit: {commit_info['commit_sha'][:8]}")
                
            except Exception as e:
                print(f"Error processing commit {commit_data.get('sha', 'unknown')}: {e}")
        
        print(f"Processed {len(commits)} commits")
        
        # Update tracking configuration
        await self.update_tracking_config()
    
    async def update_tracking_config(self):
        """Update last checked timestamp"""
        db_pool = await get_db()
        async with db_pool.acquire() as conn:
            await conn.execute("""
                UPDATE tracking_config 
                SET last_checked = $1 
                WHERE repository = $2
            """, datetime.now(), self.repository)
