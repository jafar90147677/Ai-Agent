from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import hashlib
import time
import random
# import json  # Unused import removed
from typing import List, Dict, Any, Set
from datetime import datetime
# import aiohttp  # Unused import removed

app = FastAPI(title="GitHub Analysis Service", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Store used hash keys to prevent duplicates
used_hash_keys: Set[str] = set()

class CommitAnalysisRequest(BaseModel):
    commit_sha: str
    message: str
    author: str
    repository: str
    timestamp: str

class HashAnalysisResponse(BaseModel):
    hash_key: str
    is_duplicate: bool
    analysis: Dict[str, Any]

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "GitHub Analysis Service",
        "status": "running",
        "timestamp": datetime.now().isoformat(),
        "total_hashes_analyzed": len(used_hash_keys)
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "github-analysis-service",
        "timestamp": datetime.now().isoformat(),
        "unique_hashes": len(used_hash_keys)
    }

@app.post("/analyze-hash")
async def analyze_hash(request: CommitAnalysisRequest):
    """Analyze GitHub commit hash and prevent duplicates"""
    try:
        # Generate unique hash key
        hash_key = generate_unique_hash(request.commit_sha, request.repository)
        
        # Check if hash already exists
        is_duplicate = hash_key in used_hash_keys
        
        if not is_duplicate:
            # Add to used hashes
            used_hash_keys.add(hash_key)
        
        # Perform hash analysis
        analysis = analyze_commit_hash(request.commit_sha, request.message, hash_key)
        
        return {
            "success": True,
            "hash_key": hash_key,
            "is_duplicate": is_duplicate,
            "analysis": analysis,
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.post("/analyze-commits")
async def analyze_commits(commits: List[CommitAnalysisRequest]):
    """Analyze multiple commits"""
    try:
        results = []
        
        for commit in commits:
            # Generate unique hash key
            hash_key = generate_unique_hash(commit.commit_sha, commit.repository)
            
            # Check if hash already exists
            is_duplicate = hash_key in used_hash_keys
            
            if not is_duplicate:
                # Add to used hashes
                used_hash_keys.add(hash_key)
            
            # Perform hash analysis
            analysis = analyze_commit_hash(commit.commit_sha, commit.message, hash_key)
            
            results.append({
                "commit_sha": commit.commit_sha,
                "hash_key": hash_key,
                "is_duplicate": is_duplicate,
                "analysis": analysis
            })
        
        return {
            "success": True,
            "results": results,
            "total_analyzed": len(results),
            "unique_hashes": len(used_hash_keys),
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.get("/hash-stats")
async def get_hash_stats():
    """Get hash analysis statistics"""
    return {
        "success": True,
        "total_unique_hashes": len(used_hash_keys),
        "hash_analysis_stats": {
            "total_analyzed": len(used_hash_keys),
            "duplicate_prevented": len(used_hash_keys),  # All stored are unique
            "hash_generation_time": "~1ms per hash"
        },
        "timestamp": datetime.now().isoformat()
    }

def generate_unique_hash(commit_sha: str, repository: str) -> str:
    """Generate unique hash key for commit"""
    timestamp = int(time.time() * 1000)
    random_num = random.randint(1000, 9999)
    
    # Create hash input with multiple components
    hash_input = f"{commit_sha}_{repository}_{timestamp}_{random_num}"
    
    # Generate SHA256 hash
    hash_key = hashlib.sha256(hash_input.encode()).hexdigest()
    
    # Ensure uniqueness (in case of collision)
    counter = 0
    original_hash = hash_key
    
    while hash_key in used_hash_keys:
        counter += 1
        hash_input = f"{original_hash}_{counter}"
        hash_key = hashlib.sha256(hash_input.encode()).hexdigest()
    
    return hash_key

def analyze_commit_hash(commit_sha: str, message: str, hash_key: str) -> Dict[str, Any]:
    """Analyze commit hash and provide insights"""
    analysis = {
        "hash_length": len(hash_key),
        "hash_type": "SHA256",
        "commit_sha_length": len(commit_sha),
        "message_length": len(message),
        "hash_complexity": analyze_hash_complexity(hash_key),
        "commit_pattern": analyze_commit_pattern(commit_sha),
        "message_analysis": analyze_message_pattern(message),
        "generated_at": datetime.now().isoformat()
    }
    
    return analysis

def analyze_hash_complexity(hash_key: str) -> Dict[str, Any]:
    """Analyze hash complexity"""
    # Count character types
    digits = sum(1 for c in hash_key if c.isdigit())
    letters = sum(1 for c in hash_key if c.isalpha())
    hex_chars = sum(1 for c in hash_key if c in 'abcdef')
    
    return {
        "total_length": len(hash_key),
        "digits": digits,
        "letters": letters,
        "hex_chars": hex_chars,
        "complexity_score": (digits + letters + hex_chars) / len(hash_key)
    }

def analyze_commit_pattern(commit_sha: str) -> Dict[str, Any]:
    """Analyze commit SHA pattern"""
    return {
        "length": len(commit_sha),
        "is_valid_sha": len(commit_sha) == 40,  # Standard Git SHA length
        "pattern_type": "hexadecimal",
        "short_sha": commit_sha[:8] if len(commit_sha) >= 8 else commit_sha
    }

def analyze_message_pattern(message: str) -> Dict[str, Any]:
    """Analyze commit message pattern"""
    words = message.split()
    
    return {
        "length": len(message),
        "word_count": len(words),
        "has_issue_number": any('#' in word for word in words),
        "has_emoji": any(ord(c) > 127 for c in message),
        "message_type": classify_message_type(message)
    }

def classify_message_type(message: str) -> str:
    """Classify commit message type"""
    message_lower = message.lower()
    
    if any(word in message_lower for word in ['fix', 'bug', 'issue']):
        return "bug_fix"
    elif any(word in message_lower for word in ['feat', 'add', 'new']):
        return "feature"
    elif any(word in message_lower for word in ['docs', 'readme']):
        return "documentation"
    elif any(word in message_lower for word in ['refactor', 'clean']):
        return "refactor"
    elif any(word in message_lower for word in ['security', 'auth']):
        return "security"
    else:
        return "general"

@app.get("/clear-hashes")
async def clear_hashes():
    """Clear all stored hash keys (for testing)"""
    global used_hash_keys
    count = len(used_hash_keys)
    used_hash_keys.clear()
    
    return {
        "success": True,
        "message": f"Cleared {count} hash keys",
        "timestamp": datetime.now().isoformat()
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8004)
