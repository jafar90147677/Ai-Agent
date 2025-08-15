import pytest
from fastapi.testclient import TestClient
from github_analysis_service.main import app

client = TestClient(app)


class TestGitHubAnalysisService:
    """Test cases for GitHub Analysis Service"""
    
    def test_root_endpoint(self):
        """Test root endpoint"""
        response = client.get("/")
        assert response.status_code == 200
        data = response.json()
        assert "message" in data
        assert "status" in data
        assert "total_hashes_analyzed" in data
        assert data["status"] == "running"
    
    def test_health_check(self):
        """Test health check endpoint"""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["service"] == "github-analysis-service"
        assert "unique_hashes" in data
    
    def test_analyze_hash_endpoint(self):
        """Test analyze hash endpoint"""
        commit_data = {
            "commit_sha": "abc123def456",
            "message": "fix: bug in login system",
            "author": "test author",
            "repository": "test/repo",
            "timestamp": "2023-01-01T00:00:00Z"
        }
        response = client.post("/analyze-hash", json=commit_data)
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "hash_key" in data
        assert "is_duplicate" in data
        assert "analysis" in data
        # First time should not be duplicate
        assert data["is_duplicate"] is False
    
    def test_analyze_commits_endpoint(self):
        """Test analyze commits endpoint"""
        commits_data = [
            {
                "commit_sha": "abc123def456",
                "message": "feat: add new feature",
                "author": "test author",
                "repository": "test/repo",
                "timestamp": "2023-01-01T00:00:00Z"
            },
            {
                "commit_sha": "def456ghi789",
                "message": "docs: update README",
                "author": "test author",
                "repository": "test/repo",
                "timestamp": "2023-01-01T00:00:00Z"
            }
        ]
        response = client.post("/analyze-commits", json=commits_data)
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "results" in data
        assert len(data["results"]) == 2
        assert data["total_analyzed"] == 2
    
    def test_hash_stats_endpoint(self):
        """Test hash stats endpoint"""
        response = client.get("/hash-stats")
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "total_unique_hashes" in data
        assert "hash_analysis_stats" in data
    
    def test_clear_hashes_endpoint(self):
        """Test clear hashes endpoint"""
        response = client.get("/clear-hashes")
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "message" in data
    
    def test_duplicate_prevention(self):
        """Test that duplicate hashes are prevented"""
        commit_data = {
            "commit_sha": "test123",
            "message": "test commit",
            "author": "test author",
            "repository": "test/repo",
            "timestamp": "2023-01-01T00:00:00Z"
        }
        
        # First request
        response1 = client.post("/analyze-hash", json=commit_data)
        assert response1.status_code == 200
        data1 = response1.json()
        assert data1["is_duplicate"] is False
        
        # Second request with same data
        response2 = client.post("/analyze-hash", json=commit_data)
        assert response2.status_code == 200
        data2 = response2.json()
        assert data2["is_duplicate"] is True


if __name__ == "__main__":
    pytest.main([__file__])
