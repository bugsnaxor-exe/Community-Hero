import requests

base_url = "https://community-hero.onrender.com/api"
r = requests.get(f"{base_url}/dashboard/analytics/dashboard")
print("Dashboard status:", r.status_code)
print("Dashboard text:", r.text[:200])
