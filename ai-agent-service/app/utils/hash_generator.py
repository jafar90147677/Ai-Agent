import hashlib
import time
import random
from typing import Optional

class HashGenerator:
    def __init__(self):
        self.used_hashes = set()
    
    def generate_hash(self, commit_sha: str, repository: str = "") -> str:
        """Generate unique hash key for commit"""
        max_attempts = 10
        
        for attempt in range(max_attempts):
            # Create hash input with timestamp and random component
            timestamp = int(time.time() * 1000)  # milliseconds
            random_num = random.randint(1000, 9999)
            
            hash_input = f"{commit_sha}_{repository}_{timestamp}_{random_num}"
            hash_key = hashlib.sha256(hash_input.encode()).hexdigest()
            
            # Check if hash is unique
            if hash_key not in self.used_hashes:
                self.used_hashes.add(hash_key)
                return hash_key
        
        # If we can't generate a unique hash after max attempts, 
        # use a fallback with current timestamp
        fallback_input = f"{commit_sha}_{time.time()}_{random.random()}"
        return hashlib.sha256(fallback_input.encode()).hexdigest()
    
    def is_hash_unique(self, hash_key: str) -> bool:
        """Check if hash key is unique"""
        return hash_key not in self.used_hashes
    
    def add_used_hash(self, hash_key: str):
        """Add hash to used hashes set"""
        self.used_hashes.add(hash_key)
    
    def clear_used_hashes(self):
        """Clear used hashes set (for testing)"""
        self.used_hashes.clear()
