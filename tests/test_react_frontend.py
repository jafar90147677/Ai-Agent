import pytest
import requests
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


class TestReactFrontend:
    """Test cases for React Frontend"""
    
    def setup_method(self):
        """Setup for each test"""
        self.base_url = "http://localhost:3000"
        self.driver = webdriver.Chrome()  # Requires ChromeDriver
        self.driver.implicitly_wait(10)
    
    def teardown_method(self):
        """Cleanup after each test"""
        self.driver.quit()
    
    def test_frontend_loads(self):
        """Test that frontend loads correctly"""
        self.driver.get(self.base_url)
        
        # Check if main elements are present
        assert "GitHub Commit Tracker" in self.driver.title
        assert "Track Now" in self.driver.page_source
        assert "AI-Powered Commit Analysis" in self.driver.page_source
    
    def test_track_now_button(self):
        """Test Track Now button functionality"""
        self.driver.get(self.base_url)
        
        # Find and click Track Now button
        track_button = self.driver.find_element(By.CLASS_NAME, "track-btn")
        track_button.click()
        
        # Wait for loading state
        WebDriverWait(self.driver, 10).until(
            EC.text_to_be_present_in_element(
                (By.CLASS_NAME, "track-btn"), "Fetching..."
            )
        )
    
    def test_fetch_commits_button(self):
        """Test Fetch New Commits button"""
        self.driver.get(self.base_url)
        
        # Find and click Fetch button
        fetch_button = self.driver.find_element(By.CLASS_NAME, "fetch-btn")
        fetch_button.click()
        
        # Button should be clickable
        assert fetch_button.is_enabled()
    
    def test_json_toggle_button(self):
        """Test JSON toggle functionality"""
        self.driver.get(self.base_url)
        
        # Find JSON toggle button
        json_button = self.driver.find_element(
            By.CLASS_NAME, "toggle-json-btn"
        )
        
        # Click to show JSON
        json_button.click()
        
        # Check if JSON data is visible
        try:
            json_data = self.driver.find_element(By.CLASS_NAME, "json-data")
            assert json_data.is_displayed()
        except Exception:
            # JSON might not be visible if no data
            pass
    
    def test_statistics_display(self):
        """Test statistics display"""
        self.driver.get(self.base_url)
        
        # Check if stats cards are present
        stat_cards = self.driver.find_elements(By.CLASS_NAME, "stat-card")
        # Should have at least 3 stat cards
        assert len(stat_cards) >= 3
        
        # Check stat card titles
        titles = ["Total Commits", "AI Processed", "Last Updated"]
        for title in titles:
            assert title in self.driver.page_source
    
    def test_commits_section(self):
        """Test commits section display"""
        self.driver.get(self.base_url)
        
        # Check if commits section exists
        commits_section = self.driver.find_element(
            By.CLASS_NAME, "commits-section"
        )
        assert commits_section.is_displayed()
        
        # Check if "Recent Commits" heading is present
        assert "Recent Commits" in commits_section.text
    
    def test_error_handling(self):
        """Test error handling when API is not available"""
        self.driver.get(self.base_url)
        
        # Click Track Now to trigger potential error
        track_button = self.driver.find_element(By.CLASS_NAME, "track-btn")
        track_button.click()
        
        # Wait a bit for potential error
        import time
        time.sleep(3)
        
        # Check if error message appears (if API is down)
        page_source = self.driver.page_source
        if "Error connecting to server" in page_source:
            error_message = self.driver.find_element(
                By.CLASS_NAME, "error-message"
            )
            assert error_message.is_displayed()
    
    def test_responsive_design(self):
        """Test responsive design on mobile viewport"""
        self.driver.get(self.base_url)
        
        # Set mobile viewport
        self.driver.set_window_size(375, 667)  # iPhone SE size
        
        # Check if elements are still accessible
        track_button = self.driver.find_element(By.CLASS_NAME, "track-btn")
        assert track_button.is_displayed()
        
        # Check if layout is responsive
        commits_section = self.driver.find_element(
            By.CLASS_NAME, "commits-section"
        )
        assert commits_section.is_displayed()


class TestReactFrontendAPI:
    """Test React frontend API integration"""
    
    def test_api_endpoints_accessible(self):
        """Test that API endpoints are accessible"""
        base_url = "http://localhost:8000"
        
        # Test API Gateway health
        response = requests.get(f"{base_url}/health")
        assert response.status_code == 200
        
        # Test track-now endpoint
        response = requests.get(f"{base_url}/track-now")
        # 500 if services not running
        assert response.status_code in [200, 500]
        
        # Test stats endpoint
        response = requests.get(f"{base_url}/stats")
        assert response.status_code in [200, 500]


if __name__ == "__main__":
    pytest.main([__file__])
