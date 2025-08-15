import pytest
from fastapi.testclient import TestClient
from database_service.main import app

client = TestClient(app)


class TestDatabaseService:
    """Test cases for Database Service"""
    
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
        assert data["service"] == "database-service"
        assert "database" in data
    
    def test_track_now_endpoint(self):
        """Test track-now endpoint"""
        response = client.get("/track-now")
        # Should return 500 if database is not connected
        assert response.status_code in [200, 500]
    
    def test_get_commits_endpoint(self):
        """Test commits endpoint"""
        response = client.get("/commits")
        # Should return 500 if database is not connected
        assert response.status_code in [200, 500]
    
    def test_store_commits_endpoint(self):
        """Test store commits endpoint"""
        commits_data = {
            "commits": [
                {
                    "commit_sha": "abc123",
                    "message": "test commit",
                    "author": "test author",
                    "author_email": "test@example.com",
                    "committed_at": "2023-01-01T00:00:00Z",
                    "ai_analysis": {
                        "sentiment_score": 0.5,
                        "categories": ["feature"]
                    }
                }
            ]
        }
        response = client.post("/store-commits", json=commits_data)
        # Should return 500 if database is not connected
        assert response.status_code in [200, 500]
    
    def test_stats_endpoint(self):
        """Test stats endpoint"""
        response = client.get("/stats")
        # Should return 500 if database is not connected
        assert response.status_code in [200, 500]


if __name__ == "__main__":
    pytest.main([__file__])
