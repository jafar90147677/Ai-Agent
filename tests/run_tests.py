#!/usr/bin/env python3
"""
Test Runner for GitHub Commit Tracker Microservices
"""

import subprocess
import sys
import os


def run_tests():
    """Run all tests for the microservices"""
    
    print("🚀 Running Tests for GitHub Commit Tracker")
    print("=" * 50)
    
    # Test files to run
    test_files = [
        "tests/test_api_gateway.py",
        "tests/test_github_service.py", 
        "tests/test_ai_service.py",
        "tests/test_database_service.py",
        "tests/test_github_analysis_service.py",
        "tests/test_react_frontend.py"
    ]
    
    results = {}
    
    for test_file in test_files:
        if os.path.exists(test_file):
            print(f"\n📋 Running tests for {test_file}")
            print("-" * 40)
            
            try:
                result = subprocess.run([
                    sys.executable, "-m", "pytest", test_file, "-v"
                ], capture_output=True, text=True)
                
                if result.returncode == 0:
                    print("✅ Tests passed")
                    results[test_file] = "PASSED"
                else:
                    print("❌ Tests failed")
                    print(result.stdout)
                    print(result.stderr)
                    results[test_file] = "FAILED"
                    
            except Exception as e:
                print(f"❌ Error running tests: {e}")
                results[test_file] = "ERROR"
        else:
            print(f"⚠️  Test file not found: {test_file}")
            results[test_file] = "NOT_FOUND"
    
    # Summary
    print("\n" + "=" * 50)
    print("📊 Test Summary")
    print("=" * 50)
    
    passed = 0
    failed = 0
    
    for test_file, status in results.items():
        print(f"{test_file}: {status}")
        if status == "PASSED":
            passed += 1
        else:
            failed += 1
    
    print(f"\n✅ Passed: {passed}")
    print(f"❌ Failed: {failed}")
    print(f"📈 Success Rate: {passed/(passed+failed)*100:.1f}%")
    
    return failed == 0


if __name__ == "__main__":
    success = run_tests()
    sys.exit(0 if success else 1)
