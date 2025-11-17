# Harness GitHub Integration with Local Minikube Setup

This guide will help you deploy the sample app to your local minikube cluster via GitHub using Harness CI/CD.

## Prerequisites

- ✅ Harness running locally (via `docker-compose up -d`)
- ✅ Local minikube cluster running
- ✅ GitHub account
- ✅ Git installed locally

## Step 1: Prepare GitHub Repository

### 1.1 Create GitHub Repository

1. Go to GitHub and create a new repository named `harness-sample-app`
2. Make it public or private (your choice)

### 1.2 Push Sample App to GitHub

```bash
cd harness/sample-app

# Initialize git repository
git init
git add .
git commit -m "Initial commit: Harness sample app"

# Add GitHub remote
git remote add origin https://github.com/YOUR_USERNAME/harness-sample-app.git
git branch -M main
git push -u origin main
```

## Step 2: Configure Harness GitHub Connector

### 2.1 Access Harness UI

1. Open your browser and go to `http://localhost:8080`
2. Login with default credentials (usually `admin/admin`)

### 2.2 Create GitHub Connector

1. Navigate to **Settings** → **Connectors**
2. Click **Create Connector**
3. Select **GitHub**
4. Configure the connector:

```
Connector Name: github-connector
URL: https://github.com
Authentication: Personal Access Token
Token: [Your GitHub Personal Access Token]
```

### 2.3 Create GitHub Personal Access Token

1. Go to GitHub → Settings → Developer settings → Personal access tokens
2. Click **Generate new token (classic)**
3. Select scopes:
   - `repo` (Full control of private repositories)
   - `workflow` (Update GitHub Action workflows)
4. Copy the token and use it in the Harness connector

## Step 3: Create Harness Application

### 3.1 Create Application

1. In Harness UI, go to **Setup** → **Applications**
2. Click **Create Application**
3. Configure:

```
Application Name: harness-sample-app
Description: Sample Node.js application for Harness CI/CD learning
```

### 3.2 Create Service

1. In your application, go to **Services**
2. Click **Create Service**
3. Configure:

```
Service Name: harness-sample-app-service
Service Type: Kubernetes
```

#### Artifact Source Configuration:

```
Artifact Type: Docker Registry
Registry: localhost:5000
Image: harness-sample-app
Tag: latest
```

#### Manifests Configuration:

```
Manifest Type: Kubernetes
Source: Git
Repository: [Your GitHub repo URL]
Branch: main
Path: k8s/
```

## Step 4: Create Environment and Infrastructure

### 4.1 Create Environment

1. Go to **Environments**
2. Click **Create Environment**
3. Configure:

```
Environment Name: local-minikube
Environment Type: Production
```

### 4.2 Create Infrastructure

1. In your environment, go to **Infrastructure**
2. Click **Create Infrastructure**
3. Configure:

```
Infrastructure Name: minikube-cluster
Cloud Provider: Kubernetes
Cluster: minikube
Namespace: default
```

## Step 5: Create Workflow

### 5.1 Create Rolling Workflow

1. Go to **Workflows**
2. Click **Create Workflow**
3. Select **Rolling** workflow type
4. Configure:

```
Workflow Name: deploy-to-minikube
Environment: local-minikube
Service: harness-sample-app-service
```

### 5.2 Configure Workflow Steps

#### Pre-deployment Steps:

1. **Build Docker Image**:
   ```
   Step Name: Build Image
   Type: Shell Script
   Script:
   ```
   ```bash
   cd /tmp
   git clone https://github.com/YOUR_USERNAME/harness-sample-app.git
   cd harness-sample-app
   docker build -t localhost:5000/harness-sample-app:latest .
   docker push localhost:5000/harness-sample-app:latest
   ```

#### Deployment Steps:

1. **Deploy to Kubernetes**:
   ```
   Step Name: Deploy
   Type: Kubernetes Deploy
   ```

#### Post-deployment Steps:

1. **Health Check**:
   ```
   Step Name: Health Check
   Type: HTTP
   URL: http://harness-sample-app-service:3000/health
   ```

## Step 6: Create Pipeline

### 6.1 Create Pipeline

1. Go to **Pipelines**
2. Click **Create Pipeline**
3. Configure:

```
Pipeline Name: sample-app-pipeline
```

### 6.2 Add Stages

1. **Build Stage**:

   - Type: Build
   - Workflow: [Your workflow]

2. **Deploy Stage**:
   - Type: Deploy
   - Environment: local-minikube
   - Workflow: deploy-to-minikube

## Step 7: Test the Pipeline

### 7.1 Trigger Pipeline

1. Go to your pipeline
2. Click **Run Pipeline**
3. Monitor the execution

### 7.2 Verify Deployment

```bash
# Check if pods are running
kubectl get pods -l app=harness-sample-app

# Check service
kubectl get svc harness-sample-app-service

# Port forward to access the app
kubectl port-forward svc/harness-sample-app-service 8080:80
```

Then visit `http://localhost:8080` in your browser.

## Troubleshooting

### Common Issues:

1. **Image Pull Errors**:

   - Ensure minikube can access your local registry:

   ```bash
   eval $(minikube docker-env)
   ```

2. **GitHub Connector Issues**:

   - Verify your Personal Access Token has correct permissions
   - Check network connectivity to GitHub

3. **Kubernetes Deployment Issues**:
   - Check pod logs: `kubectl logs -l app=harness-sample-app`
   - Verify namespace exists: `kubectl get namespaces`

### Useful Commands:

```bash
# Check Harness services
docker-compose ps

# Check minikube status
minikube status

# Access minikube dashboard
minikube dashboard

# Check local registry
curl http://localhost:5000/v2/_catalog
```

## Next Steps

Once this basic setup is working, you can enhance it with:

1. **Approval Gates**: Add manual approval steps
2. **Rollback**: Configure automatic rollback on failure
3. **Canary Deployments**: Implement gradual rollout strategies
4. **Monitoring**: Add verification and monitoring steps
5. **Variables**: Use Harness variables for environment-specific configs

## Security Considerations

- Use GitHub Personal Access Tokens with minimal required permissions
- Consider using GitHub Apps for better security
- Regularly rotate access tokens
- Use secrets management for sensitive data
