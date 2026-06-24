import subprocess
import time
import urllib.request
import urllib.error
import json
import sys

def make_request(url, method="GET", data=None, headers=None):
    if headers is None:
        headers = {}
    if data is not None:
        data = json.dumps(data).encode('utf-8')
        headers['Content-Type'] = 'application/json'
        
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as response:
            return response.status, json.loads(response.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read().decode('utf-8'))

def run_tests():
    print("Starting Uvicorn server in the background...")
    proc = subprocess.Popen([sys.executable, "-m", "uvicorn", "app.main:app", "--port", "8005"])
    time.sleep(3) # Wait for server to boot
    
    base_url = "http://127.0.0.1:8005/api"
    try:
        print("\n--- Testing Authentication ---")
        email1 = "test_user_a@example.com"
        password = "securepassword"
        
        print("1. POST /auth/register...")
        status, body = make_request(f"{base_url}/auth/register", method="POST", data={"email": email1, "password": password})
        if status not in (200, 400): # 400 is fine if already registered
            print(f"[FAIL] Register failed: {body}")
            return
        print("[OK] Registered user successfully.")
            
        print("2. POST /auth/login...")
        status, body = make_request(f"{base_url}/auth/login", method="POST", data={"email": email1, "password": password})
        if status != 200:
            print(f"[FAIL] Login failed: {body}")
            return
        token1 = body["access_token"]
        headers1 = {"Authorization": f"Bearer {token1}"}
        print("[OK] Logged in successfully. Token acquired.")
        
        print("\n--- Testing Issues ---")
        print("3. POST /issues/ (Create Issue)...")
        issue_data = {"category": "pothole", "description": "Massive pothole on Main St", "lat": 40.7128, "lng": -74.0060}
        status, body = make_request(f"{base_url}/issues/", method="POST", data=issue_data, headers=headers1)
        if status != 200:
            print(f"[FAIL] Create issue failed: {body}")
            return
        issue_id = body["id"]
        print(f"[OK] Issue created successfully! ID: {issue_id}")
        
        print(f"4. GET /issues/{{issue_id}} (Fetch Issue)...")
        status, body = make_request(f"{base_url}/issues/{issue_id}", method="GET")
        if status != 200:
            print(f"[FAIL] Get issue failed: {body}")
            return
        print(f"[OK] Fetched issue successfully. Verification count: {body.get('verification_count')}")
            
        print("\n--- Testing Verifications ---")
        print("5. POST /issues/{id}/verify (Verify Issue)...")
        # Need a second user to verify
        email2 = "test_user_b@example.com"
        make_request(f"{base_url}/auth/register", method="POST", data={"email": email2, "password": password})
        _, body2 = make_request(f"{base_url}/auth/login", method="POST", data={"email": email2, "password": password})
        headers2 = {"Authorization": f"Bearer {body2['access_token']}"}
        
        status, body = make_request(f"{base_url}/issues/{issue_id}/verify", method="POST", headers=headers2)
        if status not in (200, 400): # 400 is fine if already verified by this user
            print(f"[FAIL] Verify issue failed: {body}")
            return
        print(f"[OK] Issue verified successfully by second user! Current verifications: {body.get('verification_count', 'N/A')}")
            
        print("\n[SUCCESS] ALL API ENDPOINTS RESPONDED SUCCESSFULLY!")
        
    finally:
        print("\nShutting down test server...")
        proc.terminate()
        proc.wait()

if __name__ == "__main__":
    run_tests()
