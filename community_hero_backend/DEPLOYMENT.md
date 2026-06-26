# Community Hero Cloud Run Deployment Guide

This guide outlines the steps to deploy the Community Hero API to Google Cloud Run. The codebase has been optimized for production with Gunicorn worker clustering, SQLAlchemy connection pooling, and proper health checks.

## Prerequisites
1. Install the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install).
2. Authenticate your CLI: `gcloud auth login`
3. Set your project: `gcloud config set project YOUR_PROJECT_ID`
4. Enable necessary APIs:
   ```bash
   gcloud services enable run.googleapis.com cloudbuild.googleapis.com secretmanager.googleapis.com
   ```

## 1. Setup Secret Manager (Environment Variables)
Cloud Run does not use a local `.env` file for security reasons. Instead, we use Google Cloud Secret Manager.

Create secrets for each of your environment variables:
```bash
# Database
echo -n "postgresql://neondb_owner:npg_X3pdsm0IQyWJ@ep-raspy-wildflower-at7g1igd.c-9.us-east-1.aws.neon.tech/neondb?sslmode=require" | gcloud secrets create DATABASE_URL --data-file=-
# JWT Secret
echo -n "your_super_secret_key" | gcloud secrets create SECRET_KEY --data-file=-
# OpenRouter API Key
echo -n "your_openrouter_api_key" | gcloud secrets create OPENROUTER_API_KEY --data-file=-
```

> Ensure the Cloud Run service account has the `Secret Manager Secret Accessor` role.

## 2. Deploy the Application
We have generated a `cloudbuild.yaml` file that automates the Docker image build and deployment process.

To deploy, simply run this command from the root of your project:
```bash
gcloud builds submit --config cloudbuild.yaml
```

## 3. Verify the Deployment
Once the deployment finishes, the CLI will output a Service URL (e.g., `https://community-hero-backend-xyz.a.run.app`).

### Check the Health Endpoint
Open your browser or run a curl command to hit the newly added health check endpoint:
```bash
curl https://[YOUR_GENERATED_URL]/health
```
**Expected Output:**
```json
{"status": "ok", "database": "connected"}
```

### Check API Docs
Navigate to `https://[YOUR_GENERATED_URL]/docs` to see the complete Swagger UI of your deployed backend.

## Production Observability
- **Logs**: All `logging.info` and `logging.error` statements are automatically captured. Navigate to **Google Cloud Logging** in the GCP Console to view live API request logs and errors.
- **Connection Pooling**: SQLAlchemy is automatically pooling up to 15 connections per container, and aggressively pinging connections to ensure NeonDB hasn't dropped them.
