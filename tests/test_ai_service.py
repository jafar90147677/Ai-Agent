import pytest
from fastapi.testclient import TestClient
from ai_service.main import app

client = TestClient(app)


class TestAIService:
    """Test cases for AI Service"""
    
    def test_root_endpoint(self):
        """Test root endpoint"""
        response = client.get("/")
        assert response.status_code == 200
        data = response.json()
        assert "message" in data
        assert "status" in data
        assert data["status"] == "running"
    
    def test_health_check(self):
        """Test health check endpoint"""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["service"] == "ai-service"
    
    def test_analyze_commit_endpoint(self):
        """Test analyze commit endpoint"""
        commit_data = {"message": "fix: bug in login system"}
        response = client.post("/analyze", json=commit_data)
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "analysis" in data
        assert "sentiment_score" in data["analysis"]
        assert "categories" in data["analysis"]
    
    def test_process_commits_endpoint(self):
        """Test process commits endpoint"""
        commits_data = {
            "commits": [
                {
                    "sha": "abc123",
                    "commit": {
                        "message": "feat: add new feature",
                        "author": {
                            "name": "Test User",
                            "email": "test@example.com"
                        }
                    }
                }
            ]
        }
        response = client.post("/process-commits", json=commits_data)
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "message" in data
    
    def test_analyze_bug_fix_commit(self):
        """Test analyzing a bug fix commit"""
        commit_data = {"message": "fix: critical security vulnerability"}
        response = client.post("/analyze", json=commit_data)
        assert response.status_code == 200
        data = response.json()
        analysis = data["analysis"]
        assert "bug_fix" in analysis["categories"]
        assert analysis["priority"] == "high"
    
    def test_analyze_feature_commit(self):
        """Test analyzing a feature commit"""
        commit_data = {"message": "feat: add user authentication"}
        response = client.post("/analyze", json=commit_data)
        assert response.status_code == 200
        data = response.json()
        analysis = data["analysis"]
        assert "feature" in analysis["categories"]
    
    def test_analyze_documentation_commit(self):
        """Test analyzing a documentation commit"""
        commit_data = {"message": "docs: update README"}
        response = client.post("/analyze", json=commit_data)
        assert response.status_code == 200
        data = response.json()
        analysis = data["analysis"]
        assert "documentation" in analysis["categories"]


if __name__ == "__main__":
    pytest.main([__file__])
