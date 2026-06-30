import requests

# 1. Login to get token
base_url = "https://community-hero.onrender.com/api"
r = requests.post(f"{base_url}/auth/login", data={"username": "testuser@example.com", "password": "password123"})
if r.status_code != 200:
    # Try creating user
    r = requests.post(f"{base_url}/auth/register", json={"email": "testuser@example.com", "password": "password123", "full_name": "Test User"})
    r = requests.post(f"{base_url}/auth/login", data={"username": "testuser@example.com", "password": "password123"})

token = r.json().get("access_token")
headers = {"Authorization": f"Bearer {token}"}

# 2. Get dashboard to find an issue
r = requests.get(f"{base_url}/dashboard/analytics/dashboard", headers=headers)
data = r.json()
issues = data.get("recent_activity", [])
if not issues:
    print("No issues found in dashboard")
else:
    issue_id = issues[0]['id']
    print(f"Found issue {issue_id}, status: {issues[0]['status']}")
    
    # 3. Try to resolve it
    r = requests.patch(f"{base_url}/issues/{issue_id}/status", json={"status": "RESOLVED"}, headers=headers)
    print(f"Patch status: {r.status_code}")
    print(f"Patch response: {r.text}")
