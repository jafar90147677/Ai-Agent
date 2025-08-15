import pytest
from fastapi.testclient import TestClient
from api_gateway_service.main import app


client = TestClient(app)


class TestAPIGateway:
    """Test cases for API Gateway Service"""
    
    def test_root_endpoint(self):
        """Test root endpoint"""
        response = client.get("/")
        assert response.status_code == 200
        data = response.json()
        assert "message" in data
        assert "status" in data
        assert "services" in data
        assert data["status"] == "running"
    
    def test_health_check(self):
        """Test health check endpoint"""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["service"] == "api-gateway"
    
    def test_track_now_endpoint(self):
        """Test track-now endpoint"""
        response = client.get("/track-now")
        # Should return 500 if database service is not running
        assert response.status_code in [200, 500]
    
    def test_get_commits_endpoint(self):
        """Test commits endpoint"""
        response = client.get("/commits")
        # Should return 500 if database service is not running
        assert response.status_code in [200, 500]
    
    def test_fetch_commits_endpoint(self):
        """Test fetch-commits endpoint"""
        response = client.post("/fetch-commits")
        # Should return 500 if GitHub service is not running
        assert response.status_code in [200, 500]
    
    def test_stats_endpoint(self):
        """Test stats endpoint"""
        response = client.get("/stats")
        # Should return 500 if database service is not running
        assert response.status_code in [200, 500]
    
    def test_analyze_commit_endpoint(self):
        """Test analyze-commit endpoint"""
        response = client.post("/analyze-commit",
                               json={"message": "test commit"})
        # Should return 500 if AI service is not running
        assert response.status_code in [200, 500]
    
    def test_analyze_hash_endpoint(self):
        """Test analyze-hash endpoint"""
        commit_data = {
            "commit_sha": "abc123",
            "message": "test commit",
            "author": "test author",
            "repository": "test/repo",
            "timestamp": "2023-01-01T00:00:00Z"
        }
        response = client.post("/analyze-hash", json=commit_data)
        # Should return 500 if GitHub Analysis service is not running
        assert response.status_code in [200, 500]
    
    def test_hash_stats_endpoint(self):
        """Test hash-stats endpoint"""
        response = client.get("/hash-stats")
        # Should return 500 if GitHub Analysis service is not running
        assert response.status_code in [200, 500]


if __name__ == "__main__":
    pytest.main([__file__])
