# Run Harness in Docker

This guide will help you set up Harness CI/CD platform locally using Docker containers, similar to how we set up Jenkins in the previous lesson.

**Important**: This lesson runs completely locally and does not require any Harness account, license, or credit card information. All services run in Docker containers on your local machine.

## Prerequisites

Before starting, ensure you have:

- Docker and Docker Compose installed
- Git installed
- At least 4GB of available RAM
- A GitHub account

## Step 1: Clone the Setup Repository

First, let's get the Harness Docker setup:

```bash
git clone https://github.com/harness/harness-docker-compose
cd harness-docker-compose
```

## Step 2: Configure Environment Variables

Create a `.env` file in the harness-docker-compose directory. For this learning environment, we'll use default values that don't require any Harness account or license:

```bash
# Harness Configuration
HARNESS_VERSION=latest
HARNESS_ACCOUNT_ID=local-learning
HARNESS_LICENSE_KEY=community

# Database Configuration
POSTGRES_DB=harness
POSTGRES_USER=harness
POSTGRES_PASSWORD=harness123

# Redis Configuration
REDIS_PASSWORD=harness123

# MongoDB Configuration
MONGO_INITDB_ROOT_USERNAME=harness
MONGO_INITDB_ROOT_PASSWORD=harness123

# Delegate Configuration
DELEGATE_TOKEN=local-delegate-token
```

## Step 3: Start Harness Services

Run the following command to start all Harness services:

```bash
docker-compose up -d
```

This will start the following services:

- **Harness Manager**: The main Harness application (port 8080)
- **Harness UI**: Web interface (port 3000)
- **PostgreSQL**: Database for Harness (port 5432)
- **MongoDB**: Document store (port 27017)
- **Redis**: Caching layer (port 6379)
- **Harness Verification Service**: For deployment verification (port 8081)
- **Harness Delegate**: For local deployments

## Step 4: Access Harness

1. Open your browser and navigate to `http://localhost:3000`
2. You'll see the Harness setup wizard
3. Complete the initial setup:
   - Create your admin account (username: admin, password: admin)
   - Use default local settings (no external account required)
   - Set up your first application

## Step 5: Verify Installation

Check that all services are running:

```bash
docker-compose ps
```

You should see all services in the "Up" state.

## Step 6: Use the Sample Application

For this lesson, we'll use the sample application included in this lesson folder. You can also create your own or use a public repository:

```bash
# Use the sample app included in this lesson
cd sample-app

# Or if you want to use your own repository:
# git clone https://github.com/YOUR_USERNAME/your-app
# cd your-app
```

## Step 7: Create Your First Harness Application

1. In the Harness UI, click "Setup" → "Applications"
2. Click "Add Application"
3. Name: `SampleApp`
4. Description: `Sample application for Harness CI/CD learning`
5. Click "Submit"

## Step 8: Configure Cloud Provider

1. Go to "Setup" → "Cloud Providers"
2. Click "Add Cloud Provider"
3. Name: `Local Kubernetes`
4. Type: `Kubernetes`
5. For local development, we'll use Docker Desktop's Kubernetes
6. Click "Submit"

## Step 9: Create Service

1. In your application, go to "Services"
2. Click "Add Service"
3. Name: `webapp`
4. Click "Submit"
5. In the service configuration:
   - **Artifact Type**: Docker Registry
   - **Docker Registry**: Docker Hub (or use local registry for learning)
   - **Image**: `harness-sample-app` (for local learning)
   - **Tag**: `<+BUILD_NUMBER>`

## Step 10: Create Environment

1. Go to "Environments"
2. Click "Add Environment"
3. Name: `Development`
4. Environment Type: `Non-Production`
5. Click "Submit"

## Step 11: Create Infrastructure Definition

1. In the Development environment, click "Add Infrastructure Definition"
2. Name: `k8s-dev`
3. Cloud Provider Type: `Kubernetes`
4. **Note**: For local development, we'll use Docker Desktop's Kubernetes

## Step 12: Create Workflow

1. Go to "Workflows"
2. Click "Add Workflow"
3. Name: `Deploy to Dev`
4. Workflow Type: `Rolling`
5. Environment: `Development`
6. Service: `webapp`
7. Infrastructure Definition: `k8s-dev`

## Step 13: Create Pipeline

1. Go to "Pipelines"
2. Click "Add Pipeline"
3. Name: `CI/CD Pipeline`
4. Add the following stages:

**Build Stage:**

```yaml
- name: Build
  type: CI
  steps:
    - name: Build Docker Image
      type: BuildAndPushDockerRegistry
      properties:
        connectorRef: local-docker
        repo: harness-sample-app
        tags:
          - <+BUILD_NUMBER>
```

**Deploy Stage:**

```yaml
- name: Deploy to Dev
  type: Deploy
  properties:
    environmentRef: Development
    serviceRef: webapp
    workflowRef: Deploy to Dev
```

## Step 14: Test Your Pipeline

1. Go to your pipeline and click "Run"
2. Watch the pipeline execute
3. Verify the deployment in your Kubernetes cluster:

```bash
kubectl get pods
kubectl get services
```

## Step 15: Add Approval Gates

1. Edit your pipeline
2. Add a new stage between Build and Deploy:

```yaml
- name: Approval
  type: Approval
  properties:
    approvalType: Manual
    approvers:
      - user: admin
    message: "Approve deployment to development environment"
```

## Step 16: Add Verification Steps

1. In your Deploy stage, add verification:

```yaml
- name: Deploy to Dev
  type: Deploy
  properties:
    environmentRef: Development
    serviceRef: webapp
    workflowRef: Deploy to Dev
    verification:
      - name: Health Check
        type: HTTP
        properties:
          url: http://your-app-url/health
          method: GET
          expectedStatus: 200
```

## Step 17: Test Rollback

1. Introduce a bug in your application
2. Run the pipeline
3. Watch Harness detect the failure
4. Observe automatic rollback to the previous version

## Troubleshooting

### Common Issues

1. **Services not starting**: Check Docker logs:

```bash
docker-compose logs harness-manager
```

2. **Database connection issues**: Ensure PostgreSQL is running:

```bash
docker-compose ps postgres
```

3. **Kubernetes connection issues**: Verify your local Kubernetes cluster:

```bash
kubectl cluster-info
```

### Useful Commands

- View all container logs:

```bash
docker-compose logs -f
```

- Restart a specific service:

```bash
docker-compose restart harness-manager
```

- Stop all services:

```bash
docker-compose down
```

- Clean up volumes:

```bash
docker-compose down -v
```

## Next Steps

Once you have Harness running locally, you can:

1. Explore the Harness UI and understand the different components
2. Create more complex pipelines with multiple environments
3. Experiment with different deployment strategies (Canary, Blue-Green)
4. Set up GitOps workflows
5. Configure security scanning and compliance features

## Wrapping Up

Congratulations! You've successfully set up Harness CI/CD platform locally using Docker containers. You now have a working Harness environment where you can practice building and deploying applications with modern CI/CD practices.

The key differences from Jenkins that you've experienced:

- **Declarative configuration** instead of extensive scripting
- **Built-in security features** without additional plugins
- **Intelligent automation** with AI-powered verification
- **GitOps native support** for infrastructure as code
- **Advanced deployment strategies** built into the platform

This setup provides a solid foundation for learning and experimenting with Harness's powerful CI/CD capabilities.
