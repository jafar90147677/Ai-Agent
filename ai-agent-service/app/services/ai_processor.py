from textblob import TextBlob
import re
from typing import Dict, Any
from datetime import datetime

class AIProcessor:
    def __init__(self):
        self.categories = {
            "bug_fix": ["fix", "bug", "issue", "error", "crash", "broken"],
            "feature": ["add", "new", "feature", "implement", "create"],
            "documentation": ["doc", "readme", "comment", "document"],
            "refactor": ["refactor", "clean", "optimize", "improve"],
            "security": ["security", "vulnerability", "auth", "password"],
            "performance": ["performance", "speed", "fast", "slow", "optimize"]
        }
        
    async def analyze_commit(self, message: str) -> Dict[str, Any]:
        """Analyze commit message using AI/NLP"""
        try:
            # Sentiment analysis
            blob = TextBlob(message)
            sentiment = blob.sentiment.polarity
            
            # Category detection
            categories = self._detect_categories(message.lower())
            
            # Priority assessment
            priority = self._assess_priority(message, sentiment, categories)
            
            # Confidence score
            confidence = self._calculate_confidence(message, categories)
            
            # Generate insights
            insights = self._generate_insights(message, sentiment, categories)
            
            return {
                "sentiment_score": round(sentiment, 3),
                "sentiment_label": self._get_sentiment_label(sentiment),
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
    
    def _detect_categories(self, message: str) -> list:
        """Detect commit categories based on keywords"""
        detected_categories = []
        
        for category, keywords in self.categories.items():
            for keyword in keywords:
                if keyword in message:
                    detected_categories.append(category)
                    break
        
        return detected_categories
    
    def _assess_priority(self, message: str, sentiment: float, categories: list) -> str:
        """Assess commit priority"""
        # High priority indicators
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
        
        # Check sentiment (negative sentiment might indicate issues)
        if sentiment < -0.3:
            return "medium"
        
        return "normal"
    
    def _calculate_confidence(self, message: str, categories: list) -> float:
        """Calculate confidence score for analysis"""
        base_confidence = 0.5
        
        # Increase confidence based on message length
        if len(message) > 50:
            base_confidence += 0.2
        
        # Increase confidence if categories detected
        if categories:
            base_confidence += 0.2
        
        # Increase confidence for specific patterns
        if re.search(r'#[0-9]+', message):  # Issue references
            base_confidence += 0.1
        
        return min(base_confidence, 1.0)
    
    def _generate_insights(self, message: str, sentiment: float, categories: list) -> list:
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
    
    def _get_sentiment_label(self, sentiment: float) -> str:
        """Convert sentiment score to label"""
        if sentiment > 0.3:
            return "positive"
        elif sentiment < -0.3:
            return "negative"
        else:
            return "neutral"
