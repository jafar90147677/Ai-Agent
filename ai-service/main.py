from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from textblob import TextBlob
import re
from typing import List, Dict, Any
from datetime import datetime
import aiohttp

app = FastAPI(title="AI Service", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# AI Analysis Categories
CATEGORIES = {
    "bug_fix": ["fix", "bug", "issue", "error", "crash", "broken"],
    "feature": ["add", "new", "feature", "implement", "create"],
    "documentation": ["doc", "readme", "comment", "document"],
    "refactor": ["refactor", "clean", "optimize", "improve"],
    "security": ["security", "vulnerability", "auth", "password"],
    "performance": ["performance", "speed", "fast", "slow", "optimize"]
}

class CommitMessage(BaseModel):
    message: str

class CommitsRequest(BaseModel):
    commits: List[Dict[str, Any]]

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "AI Service - Commit Analysis",
        "status": "running",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "ai-service",
        "timestamp": datetime.now().isoformat()
    }

@app.post("/analyze")
async def analyze_commit(commit: CommitMessage):
    """Analyze a single commit message"""
    try:
        analysis = await analyze_commit_message(commit.message)
        return {
            "success": True,
            "analysis": analysis,
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@app.post("/process-commits")
async def process_commits(request: CommitsRequest):
    """Process multiple commits from GitHub service"""
    try:
        processed_commits = []
        
        for commit_data in request.commits:
            # Extract commit information
            commit_info = {
                "commit_sha": commit_data["sha"],
                "message": commit_data["commit"]["message"],
                "author": commit_data["commit"]["author"]["name"],
                "author_email": commit_data["commit"]["author"]["email"],
                "committed_at": commit_data["commit"]["author"]["date"]
            }
            
            # Analyze with AI
            ai_analysis = await analyze_commit_message(commit_info["message"])
            commit_info["ai_analysis"] = ai_analysis
            
            processed_commits.append(commit_info)
        
        # Send processed commits to database service
        await send_to_database_service(processed_commits)
        
        return {
            "success": True,
            "message": f"Processed {len(processed_commits)} commits",
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

async def analyze_commit_message(message: str) -> Dict[str, Any]:
    """Analyze commit message using AI/NLP"""
    try:
        # Sentiment analysis
        blob = TextBlob(message)
        sentiment = blob.sentiment.polarity
        
        # Category detection
        categories = detect_categories(message.lower())
        
        # Priority assessment
        priority = assess_priority(message, sentiment, categories)
        
        # Confidence score
        confidence = calculate_confidence(message, categories)
        
        # Generate insights
        insights = generate_insights(message, sentiment, categories)
        
        return {
            "sentiment_score": round(sentiment, 3),
            "sentiment_label": get_sentiment_label(sentiment),
            "categories": categories,
            "priority": priority,
            "confidence_score": confidence,
            "insights": insights,
            "processed_at": datetime.now().isoformat(),
            "analysis_type": "commit_message"
        }
    except Exception as e:
        print(f"Error in AI analysis: {e}")
        return {
            "sentiment_score": 0.0,
            "sentiment_label": "neutral",
            "categories": [],
            "priority": "normal",
            "confidence_score": 0.0,
            "insights": ["Analysis failed"],
            "processed_at": datetime.now().isoformat(),
            "analysis_type": "commit_message"
        }

def detect_categories(message: str) -> list:
    """Detect commit categories based on keywords"""
    detected_categories = []
    
    for category, keywords in CATEGORIES.items():
        for keyword in keywords:
            if keyword in message:
                detected_categories.append(category)
                break
    
    return detected_categories

def assess_priority(message: str, sentiment: float, categories: list) -> str:
    """Assess commit priority"""
    high_priority_keywords = ["urgent", "critical", "fix", "bug", "security", "hotfix"]
    high_priority_categories = ["bug_fix", "security"]
    
    # Check for high priority keywords
    for keyword in high_priority_keywords:
        if keyword in message.lower():
            return "high"
    
    # Check for high priority categories
    for category in high_priority_categories:
        if category in categories:
            return "high"
    
    # Check sentiment
    if sentiment < -0.3:
        return "medium"
    
    return "normal"

def calculate_confidence(message: str, categories: list) -> float:
    """Calculate confidence score for analysis"""
    base_confidence = 0.5
    
    if len(message) > 50:
        base_confidence += 0.2
    
    if categories:
        base_confidence += 0.2
    
    if re.search(r'#[0-9]+', message):
        base_confidence += 0.1
    
    return min(base_confidence, 1.0)

def generate_insights(message: str, sentiment: float, categories: list) -> list:
    """Generate insights from commit analysis"""
    insights = []
    
    if sentiment < -0.3:
        insights.append("Negative sentiment detected - may indicate issues")
    
    if "bug_fix" in categories:
        insights.append("Bug fix detected - requires careful review")
    
    if "security" in categories:
        insights.append("Security-related change - high priority review needed")
    
    if "feature" in categories:
        insights.append("New feature implementation")
    
    if len(message) < 10:
        insights.append("Short commit message - consider adding more details")
    
    if not categories:
        insights.append("No specific category detected")
    
    return insights

def get_sentiment_label(sentiment: float) -> str:
    """Convert sentiment score to label"""
    if sentiment > 0.3:
        return "positive"
    elif sentiment < -0.3:
        return "negative"
    else:
        return "neutral"

async def send_to_database_service(processed_commits: List[Dict[str, Any]]):
    """Send processed commits to database service"""
    try:
        database_service_url = "http://database-service:8003/store-commits"
        
        async with aiohttp.ClientSession() as session:
            async with session.post(database_service_url, json={"commits": processed_commits}) as response:
                if response.status == 200:
                    print(f"Sent {len(processed_commits)} commits to database service")
                else:
                    print(f"Error sending commits to database service: {response.status}")
                    
    except Exception as e:
        print(f"Error sending to database service: {e}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)
