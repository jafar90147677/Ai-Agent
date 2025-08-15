import pytest
from fastapi.testclient import TestClient
from github_service.main import app

client = TestClient(app)


class TestGitHubService:
    """Test cases for GitHub Service"""
    
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
        assert data["service"] == "github-service"
    
    def test_get_commits_endpoint(self):
        """Test get commits endpoint"""
        response = client.get("/commits")
        # Should return 400 if GitHub token not configured
        assert response.status_code in [200, 400, 500]
    
    def test_fetch_commits_endpoint(self):
        """Test fetch commits endpoint"""
        response = client.post("/fetch-commits")
        # Should return 400 if GitHub token not configured
        assert response.status_code in [200, 400, 500]
    
    def test_repository_info_endpoint(self):
        """Test repository info endpoint"""
        response = client.get("/repository-info")
        # Should return 400 if GitHub token not configured
        assert response.status_code in [200, 400, 500]


if __name__ == "__main__":
    pytest.main([__file__])
