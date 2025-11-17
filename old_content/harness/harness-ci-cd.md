# ![](https://ga-dash.s3.amazonaws.com/production/assets/logo-9f88ae6c9c3871690e33280fcf557f33.png) Harness CI/CD Platform

## Learning Objectives

_After this lesson, students will be able to:_

- Understand what Harness is and how it differs from traditional CI/CD tools
- Explain the key concepts of Harness: Services, Environments, Workflows, and Pipelines
- Set up a local Harness environment using Docker containers
- Create and configure a complete CI/CD pipeline using Harness
- Deploy applications through Harness with proper approval gates and rollback capabilities
- Understand Harness's intelligent automation features and GitOps integration

## Lesson Guide

| TIMING | TYPE       | TOPIC                                |
| :----: | ---------- | ------------------------------------ |
| 10 min | Opening    | Discuss Lesson Objectives            |
| 30 min | Lecture    | Introduction to Harness Platform     |
| 45 min | Practical  | Setting up Harness Local Environment |
| 60 min | Practical  | Creating Your First Harness Pipeline |
| 45 min | Practical  | Advanced Pipeline Features           |
| 20 min | Practical  | Deployment and Rollback Scenarios    |
| 10 min | Conclusion | Review/Recap                         |

## Opening (10 min)

Welcome to the world of modern CI/CD with Harness! While Jenkins has been a staple in the DevOps world, Harness represents the next generation of CI/CD platforms with intelligent automation, built-in security, and enterprise-grade features.

Today we'll explore how Harness can help you build more reliable, secure, and efficient CI/CD pipelines that can handle complex deployment scenarios with ease.

---

## Introduction to Harness Platform (30 min)

### What is Harness?

Harness is a modern, intelligent CI/CD platform that provides end-to-end automation for software delivery. Unlike traditional CI/CD tools that require extensive scripting and manual configuration, Harness offers a declarative approach with built-in intelligence.

**Key Differentiators:**

- **Intelligent Automation**: AI/ML-powered deployment verification and rollback
- **Built-in Security**: Security scanning, secrets management, and compliance features
- **GitOps Native**: First-class GitOps support with drift detection
- **Multi-Cloud**: Support for Kubernetes, Docker, AWS, Azure, GCP, and more
- **Enterprise Features**: Role-based access control, audit trails, and governance

### Core Concepts

#### 1. Services

A Service in Harness represents your application or microservice. It contains:

- **Artifact Sources**: Where your application code/artifacts come from
- **Manifests**: Kubernetes manifests, Helm charts, or other deployment configurations
- **Variables**: Environment-specific configuration

#### 2. Environments

Environments represent where your application runs:

- **Development**: For development and testing
- **Staging**: For pre-production validation
- **Production**: For live user traffic

#### 3. Workflows

Workflows define the deployment process:

- **Canary**: Gradual rollout with traffic shifting
- **Blue-Green**: Zero-downtime deployments
- **Rolling**: Rolling updates for Kubernetes
- **Basic**: Simple deployment workflows

#### 4. Pipelines

Pipelines orchestrate the entire delivery process:

- **Build**: Compile, test, and package your application
- **Deploy**: Deploy to different environments
- **Verify**: Automated verification and testing
- **Approval**: Manual approval gates
- **Rollback**: Automatic rollback on failure

### Harness vs Traditional CI/CD

| Feature          | Traditional CI/CD (Jenkins)                | Harness                    |
| ---------------- | ------------------------------------------ | -------------------------- |
| **Setup**        | Complex configuration, extensive scripting | Declarative, GUI-driven    |
| **Security**     | Manual configuration, plugins required     | Built-in security scanning |
| **Rollback**     | Manual process, error-prone                | Automated, intelligent     |
| **Verification** | Manual testing, limited automation         | AI-powered verification    |
| **GitOps**       | Plugin-based, limited support              | Native GitOps support      |
| **Multi-cloud**  | Complex setup per platform                 | Unified interface          |

### Harness Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Harness UI    │    │  Harness API    │    │  Harness Agent  │
│   (Web Portal)  │◄──►│   (Backend)     │◄──►│  (Deployments)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Git Repos     │    │   Artifact      │    │   Kubernetes    │
│   (Source Code) │    │   Repositories  │    │   Clusters      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## Setting up Harness Local Environment (45 min)

### Prerequisites

Before we begin, ensure you have the following installed:

- Docker and Docker Compose
- Git
- A GitHub account (optional - for using your own repositories)

**Note**: This lesson runs completely locally and does not require any Harness account, license, or credit card information.

### Step 1: Clone the Harness Setup Repository

```bash
git clone https://github.com/harness/harness-docker-compose
cd harness-docker-compose
```

### Step 2: Configure Environment Variables

Create a `.env` file in the harness-docker-compose directory:

```bash
# Harness Configuration
HARNESS_VERSION=latest
HARNESS_ACCOUNT_ID=your-account-id
HARNESS_LICENSE_KEY=your-license-key

# Database Configuration
POSTGRES_DB=harness
POSTGRES_USER=harness
POSTGRES_PASSWORD=harness123

# Redis Configuration
REDIS_PASSWORD=harness123

# MongoDB Configuration
MONGO_INITDB_ROOT_USERNAME=harness
MONGO_INITDB_ROOT_PASSWORD=harness123
```

### Step 3: Start Harness Services

```bash
docker-compose up -d
```

This will start the following services:

- **Harness Manager**: The main Harness application
- **Harness UI**: Web interface
- **PostgreSQL**: Database for Harness
- **MongoDB**: Document store
- **Redis**: Caching layer
- **Harness Verification Service**: For deployment verification

### Step 4: Access Harness

1. Open your browser and navigate to `http://localhost:8080`
2. You'll see the Harness setup wizard
3. Complete the initial setup:
   - Create your admin account
   - Configure your account settings
   - Set up your first application

### Step 5: Verify Installation

Check that all services are running:

```bash
docker-compose ps
```

You should see all services in the "Up" state.

---

## Creating Your First Harness Pipeline (60 min)

### Step 1: Fork the Sample Application

1. Go to [https://github.com/harness/harness-sample-app](https://github.com/harness/harness-sample-app)
2. Fork the repository to your GitHub account
3. Clone your forked repository locally:

```bash
git clone https://github.com/YOUR_USERNAME/harness-sample-app
cd harness-sample-app
```

### Step 2: Create a Harness Application

1. In the Harness UI, click "Setup" → "Applications"
2. Click "Add Application"
3. Name: `SampleApp`
4. Description: `Sample application for Harness CI/CD learning`
5. Click "Submit"

### Step 3: Configure Artifact Source

1. In your application, go to "Services"
2. Click "Add Service"
3. Name: `webapp`
4. Click "Submit"
5. In the service configuration:
   - **Artifact Type**: Docker Registry
   - **Docker Registry**: Docker Hub
   - **Image**: `your-username/harness-sample-app`
   - **Tag**: `<+BUILD_NUMBER>`

### Step 4: Create Environment

1. Go to "Environments"
2. Click "Add Environment"
3. Name: `Development`
4. Environment Type: `Non-Production`
5. Click "Submit"

### Step 5: Create Infrastructure Definition

1. In the Development environment, click "Add Infrastructure Definition"
2. Name: `k8s-dev`
3. Cloud Provider Type: `Kubernetes`
4. **Note**: For local development, we'll use Docker Desktop's Kubernetes

### Step 6: Create Workflow

1. Go to "Workflows"
2. Click "Add Workflow"
3. Name: `Deploy to Dev`
4. Workflow Type: `Rolling`
5. Environment: `Development`
6. Service: `webapp`
7. Infrastructure Definition: `k8s-dev`

### Step 7: Create Pipeline

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
        connectorRef: docker-hub
        repo: your-username/harness-sample-app
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

### Step 8: Test Your Pipeline

1. Go to your pipeline and click "Run"
2. Watch the pipeline execute
3. Verify the deployment in your Kubernetes cluster:

```bash
kubectl get pods
kubectl get services
```

---

## Advanced Pipeline Features (45 min)

### Step 1: Add Approval Gates

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

### Step 2: Add Verification Steps

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

### Step 3: Add Rollback Configuration

1. In your workflow, configure rollback:

```yaml
rollback:
  - name: Rollback
    type: Rollback
    properties:
      rollbackType: LastSuccessful
```

### Step 4: Add Variables and Expressions

1. Add pipeline variables:

```yaml
variables:
  - name: DEPLOYMENT_TIMEOUT
    type: Number
    value: 300
  - name: APPROVAL_REQUIRED
    type: Boolean
    value: true
```

2. Use expressions in your pipeline:

```yaml
- name: Deploy to Dev
  type: Deploy
  properties:
    timeout: <+pipeline.variables.DEPLOYMENT_TIMEOUT>
    approvalRequired: <+pipeline.variables.APPROVAL_REQUIRED>
```

### Step 5: Add Conditional Execution

```yaml
- name: Deploy to Dev
  type: Deploy
  properties:
    environmentRef: Development
    serviceRef: webapp
    workflowRef: Deploy to Dev
  when:
    condition: <+codebase.branch> == "main"
```

---

## Deployment and Rollback Scenarios (20 min)

### Scenario 1: Successful Deployment

1. Run your pipeline with a successful build
2. Observe the deployment process
3. Verify the application is running correctly

### Scenario 2: Failed Deployment with Rollback

1. Introduce a bug in your application
2. Run the pipeline
3. Watch Harness detect the failure
4. Observe automatic rollback to the previous version

### Scenario 3: Canary Deployment

1. Create a new workflow with Canary deployment type
2. Configure traffic shifting:
   - 10% to new version
   - 90% to old version
3. Run the deployment
4. Gradually shift traffic based on metrics

### Scenario 4: Blue-Green Deployment

1. Create a Blue-Green workflow
2. Deploy to blue environment
3. Switch traffic to blue
4. Keep green as backup

---

## Conclusion (10 min)

Congratulations! You've successfully set up and configured Harness CI/CD platform. Let's recap what we've learned:

### Key Takeaways

1. **Harness provides intelligent automation** that goes beyond traditional CI/CD tools
2. **Built-in security and compliance** features reduce manual configuration
3. **GitOps integration** enables declarative infrastructure management
4. **Advanced deployment strategies** (Canary, Blue-Green, Rolling) are built-in
5. **Automated rollback** capabilities reduce deployment risk

### Discussion Questions

- How does Harness compare to Jenkins in terms of ease of use?
- What are the benefits of Harness's intelligent automation features?
- How would you implement Harness in a production environment?

### Next Steps

- Explore Harness's advanced features like Service Reliability Management (SRM)
- Learn about Harness's integration with various cloud providers
- Practice creating more complex multi-environment pipelines
- Study Harness's security and compliance features

## Resources

- [Harness Documentation](https://docs.harness.io/)
- [Harness Community](https://community.harness.io/)
- [Harness YouTube Channel](https://www.youtube.com/c/HarnessInc)
- [Harness Sample Applications](https://github.com/harness/harness-sample-apps)
- [Harness Best Practices](https://docs.harness.io/article/1234567890/harness-best-practices)
