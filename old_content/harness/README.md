# Harness CI/CD Lesson

This folder contains a comprehensive 3-hour lesson on Harness CI/CD platform, designed to teach participants modern software engineering practices using Harness's intelligent automation capabilities.

## Lesson Overview

**Duration**: 3 hours  
**Format**: 20% theory, 80% hands-on practical  
**Prerequisites**: Basic knowledge of Docker, Kubernetes, and CI/CD concepts

## Lesson Structure

### 1. Theory (30 minutes)

- Introduction to Harness platform
- Key concepts: Services, Environments, Workflows, Pipelines
- Comparison with traditional CI/CD tools (Jenkins)
- Harness architecture and benefits

### 2. Practical Setup (45 minutes)

- Setting up Harness locally using Docker containers
- Configuring environment variables
- Starting and accessing Harness services
- Verifying installation

### 3. First Pipeline (60 minutes)

- Creating a Harness application
- Configuring services and environments
- Building and deploying a sample application
- Testing the complete pipeline

### 4. Advanced Features (45 minutes)

- Adding approval gates
- Implementing verification steps
- Configuring rollback mechanisms
- Using variables and expressions
- Conditional execution

### 5. Deployment Scenarios (20 minutes)

- Successful deployment testing
- Failed deployment with automatic rollback
- Canary deployment strategies
- Blue-Green deployment patterns

## Files in This Lesson

### Main Content

- `harness-ci-cd.md` - Complete lesson content with theory and practical exercises
- `harness-in-docker.md` - Step-by-step guide for setting up Harness locally

### Infrastructure

- `docker-compose.yml` - Docker Compose configuration for running Harness locally

### Sample Application

- `sample-app/` - Complete Node.js application for hands-on practice
  - `index.js` - Main application file
  - `package.json` - Dependencies and scripts
  - `Dockerfile` - Container configuration
  - `k8s/deployment.yaml` - Kubernetes manifests
  - `tests/app.test.js` - Test suite
  - `README.md` - Application documentation

## Learning Objectives

By the end of this lesson, participants will be able to:

1. **Understand Harness Platform**

   - Explain what Harness is and its key differentiators
   - Describe the core concepts: Services, Environments, Workflows, Pipelines
   - Compare Harness with traditional CI/CD tools

2. **Set Up Local Environment**

   - Configure and run Harness using Docker containers
   - Access and navigate the Harness UI
   - Verify all services are running correctly

3. **Create CI/CD Pipelines**

   - Build a complete CI/CD pipeline from scratch
   - Configure artifact sources and deployment targets
   - Implement different deployment strategies

4. **Implement Advanced Features**

   - Add approval gates and manual interventions
   - Configure automated verification and testing
   - Set up intelligent rollback mechanisms
   - Use variables and conditional execution

5. **Deploy Applications**
   - Deploy applications to different environments
   - Test deployment scenarios and rollback procedures
   - Understand canary and blue-green deployment patterns

## Key Differences from Jenkins

This lesson highlights the evolution from traditional CI/CD tools like Jenkins to modern platforms like Harness:

| Aspect            | Jenkins                    | Harness                    |
| ----------------- | -------------------------- | -------------------------- |
| **Configuration** | Script-based, complex      | Declarative, GUI-driven    |
| **Security**      | Plugin-dependent           | Built-in security features |
| **Rollback**      | Manual process             | Automated, intelligent     |
| **Verification**  | Limited automation         | AI-powered verification    |
| **GitOps**        | Plugin-based               | Native support             |
| **Multi-cloud**   | Complex per-platform setup | Unified interface          |

## Prerequisites

Before starting this lesson, participants should have:

- Basic understanding of Docker and containerization
- Familiarity with Kubernetes concepts
- Experience with Git and version control
- Knowledge of CI/CD fundamentals
- Docker Desktop installed with Kubernetes enabled

## Setup Instructions

1. **Clone the lesson materials**:

   ```bash
   git clone <repository-url>
   cd harness
   ```

2. **Start Harness locally**:

   ```bash
   docker-compose up -d
   ```

3. **Access Harness UI**:

   - Open browser to `http://localhost:3000`
   - Complete initial setup

4. **Follow the practical exercises** in `harness-in-docker.md`

## Troubleshooting

Common issues and solutions are covered in the practical guide. Key troubleshooting commands:

```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Clean up
docker-compose down -v
```

## Next Steps

After completing this lesson, participants can:

- Explore Harness's advanced features like Service Reliability Management (SRM)
- Learn about Harness's integration with various cloud providers
- Practice creating more complex multi-environment pipelines
- Study Harness's security and compliance features
- Implement GitOps workflows with Harness

## Resources

- [Harness Documentation](https://docs.harness.io/)
- [Harness Community](https://community.harness.io/)
- [Harness YouTube Channel](https://www.youtube.com/c/HarnessInc)
- [Harness Sample Applications](https://github.com/harness/harness-sample-apps)

## Contributing

This lesson is designed to be updated and improved based on:

- Participant feedback
- Harness platform updates
- Industry best practices evolution

Feel free to contribute improvements or report issues.

