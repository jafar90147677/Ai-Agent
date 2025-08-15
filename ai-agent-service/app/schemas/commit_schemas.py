from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime

class CommitBase(BaseModel):
    commit_sha: str
    message: str
    author: str
    author_email: str
    repository: str
    branch: str
    committed_at: Optional[datetime] = None

class CommitCreate(CommitBase):
    hash_key: str

class CommitResponse(CommitBase):
    id: int
    hash_key: str
    created_at: datetime
    ai_processed: bool
    ai_analysis: Optional[Dict[str, Any]] = None
    event_status: str

class AIAnalysis(BaseModel):
    analysis_type: str
    results: Dict[str, Any]
    confidence_score: float
    created_at: datetime

class TrackNowResponse(BaseModel):
    success: bool
    message: str
    commits: List[CommitResponse]
    json_data: Dict[str, Any]
    total_commits: int
    last_updated: str

class Statistics(BaseModel):
    total_commits: int
    ai_processed: int
    repositories: List[str]
    last_fetch: Optional[datetime] = None
