# Modern CI/CD with Jenkins, GitLab, and SonarQube

This lesson teaches modern CI/CD practices using industry-standard tools that can run completely locally without any external accounts or licenses.

## Learning Objectives

_After this lesson, students will be able to:_

- Understand modern CI/CD concepts and best practices
- Set up a complete CI/CD environment locally using Docker
- Create and configure Jenkins pipelines
- Use GitLab for source code management
- Implement code quality analysis with SonarQube
- Deploy applications to Kubernetes
- Understand the differences between traditional and modern CI/CD approaches

## Lesson Guide

| TIMING | TYPE       | TOPIC                              |
| :----: | ---------- | ---------------------------------- |
| 10 min | Opening    | Discuss Lesson Objectives          |
| 30 min | Lecture    | Modern CI/CD Concepts              |
| 45 min | Practical  | Setting up Local CI/CD Environment |
| 60 min | Practical  | Creating Your First Pipeline       |
| 45 min | Practical  | Advanced Pipeline Features         |
| 20 min | Practical  | Code Quality and Deployment        |
| 10 min | Conclusion | Review/Recap                       |

## Opening (10 min)

Welcome to modern CI/CD practices! While Harness represents the future of CI/CD, today we'll learn using industry-standard tools that are widely adopted and can run completely locally.

**Important**: This lesson runs completely locally and does not require any external accounts, licenses, or credit card information.

---

## Modern CI/CD Concepts (30 min)

### What is Modern CI/CD?

Modern CI/CD goes beyond simple build automation to include:

- **Intelligent Automation**: AI/ML-powered deployment verification
- **Built-in Security**: Security scanning and compliance features
- **GitOps**: Infrastructure as code with Git-based workflows
- **Multi-Cloud Support**: Unified interface across platforms
- **Observability**: Comprehensive monitoring and alerting

### Traditional vs Modern CI/CD

| Feature          | Traditional (Jenkins) | Modern (Harness-like)     |
| ---------------- | --------------------- | ------------------------- |
| **Setup**        | Complex scripting     | Declarative configuration |
| **Security**     | Plugin-dependent      | Built-in security         |
| **Rollback**     | Manual process        | Automated, intelligent    |
| **Verification** | Limited automation    | AI-powered verification   |
| **GitOps**       | Plugin-based          | Native support            |
| **Multi-cloud**  | Complex per-platform  | Unified interface         |

### Our Learning Environment

We'll use a combination of tools to simulate modern CI/CD capabilities:

- **Jenkins**: For pipeline orchestration
- **GitLab**: For source code management and GitOps
- **SonarQube**: For code quality analysis
- **Docker Registry**: For artifact storage
- **Kubernetes**: For deployment targets

---

## Setting up Local CI/CD Environment (45 min)

### Prerequisites

Before we begin, ensure you have:

- Docker and Docker Compose
- Git
- At least 8GB of available RAM
- Docker Desktop with Kubernetes enabled

### Step 1: Start the CI/CD Environment

```bash
# Navigate to the lesson directory
cd harness

# Start all services
docker-compose up -d
```

This will start:

- **Jenkins**: CI/CD pipeline orchestration (http://localhost:8080)
- **GitLab**: Source code management (http://localhost:8081)
- **SonarQube**: Code quality analysis (http://localhost:9000)
- **Docker Registry**: Local image storage (http://localhost:5000)
- **PostgreSQL**: Database for SonarQube
- **MongoDB**: Document storage
- **Redis**: Caching layer

### Step 2: Access Jenkins

1. Open http://localhost:8080
2. Get the initial admin password:

```bash
docker exec harness-jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

3. Complete Jenkins setup:
   - Install suggested plugins
   - Create admin user
   - Configure Jenkins URL

### Step 3: Access GitLab

1. Open http://localhost:8081
2. Wait for GitLab to fully start (may take 5-10 minutes)
3. Set root password when prompted
4. Create a new project for our sample application

### Step 4: Access SonarQube

1. Open http://localhost:9000
2. Login with admin/admin
3. Create a new project for code quality analysis

---

## Creating Your First Pipeline (60 min)

### Step 1: Set up GitLab Repository

1. In GitLab, create a new project called "sample-app"
2. Clone the sample application:

```bash
git clone https://github.com/YOUR_USERNAME/sample-app
cd sample-app
git remote add gitlab http://localhost:8081/root/sample-app.git
git push -u gitlab main
```

### Step 2: Configure Jenkins Pipeline

1. In Jenkins, create a new Pipeline job
2. Configure it to use GitLab repository
3. Create a Jenkinsfile with the following content:

```groovy
pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'localhost:5000'
        APP_NAME = 'sample-app'
        SONAR_TOKEN = 'your-sonar-token'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test') {
            steps {
                sh 'npm install'
                sh 'npm test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'npm run sonar'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER}")
                }
            }
        }

        stage('Push to Registry') {
            steps {
                script {
                    docker.withRegistry("http://${DOCKER_REGISTRY}") {
                        docker.image("${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER}").push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh "kubectl set image deployment/sample-app sample-app=${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER}"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

### Step 3: Configure SonarQube Integration

1. Install SonarQube Scanner plugin in Jenkins
2. Configure SonarQube server in Jenkins
3. Add sonar-project.properties to your project:

```properties
sonar.projectKey=sample-app
sonar.projectName=Sample App
sonar.projectVersion=1.0
sonar.sources=.
sonar.exclusions=node_modules/**,tests/**,coverage/**
sonar.javascript.lcov.reportPaths=coverage/lcov.info
```

### Step 4: Test the Pipeline

1. Make a change to your code
2. Commit and push to GitLab
3. Trigger the Jenkins pipeline
4. Monitor the execution

---

## Advanced Pipeline Features (45 min)

### Step 1: Add Approval Gates

Modify your Jenkinsfile to include approval stages:

```groovy
stage('Manual Approval') {
    steps {
        input message: 'Deploy to production?', ok: 'Deploy'
    }
}
```

### Step 2: Add Parallel Stages

```groovy
stage('Parallel Tests') {
    parallel {
        stage('Unit Tests') {
            steps {
                sh 'npm run test:unit'
            }
        }
        stage('Integration Tests') {
            steps {
                sh 'npm run test:integration'
            }
        }
    }
}
```

### Step 3: Add Conditional Execution

```groovy
stage('Deploy to Production') {
    when {
        branch 'main'
    }
    steps {
        // Production deployment steps
    }
}
```

### Step 4: Add Notifications

```groovy
post {
    success {
        emailext (
            subject: "Pipeline Successful: ${env.JOB_NAME}",
            body: "Pipeline ${env.BUILD_NUMBER} completed successfully",
            to: 'team@company.com'
        )
    }
    failure {
        emailext (
            subject: "Pipeline Failed: ${env.JOB_NAME}",
            body: "Pipeline ${env.BUILD_NUMBER} failed",
            to: 'team@company.com'
        )
    }
}
```

---

## Code Quality and Deployment (20 min)

### Step 1: Analyze Code Quality

1. Run SonarQube analysis
2. Review code quality metrics
3. Address code smells and security hotspots
4. Set up quality gates

### Step 2: Implement Blue-Green Deployment

```groovy
stage('Blue-Green Deployment') {
    steps {
        script {
            // Deploy to blue environment
            sh 'kubectl apply -f k8s/blue-deployment.yaml'

            // Wait for blue to be ready
            sh 'kubectl rollout status deployment/sample-app-blue'

            // Switch traffic to blue
            sh 'kubectl apply -f k8s/blue-service.yaml'

            // Verify deployment
            sh 'kubectl get pods -l app=sample-app'
        }
    }
}
```

### Step 3: Implement Rollback Strategy

```groovy
stage('Rollback on Failure') {
    when {
        expression { currentBuild.result == 'FAILURE' }
    }
    steps {
        script {
            sh 'kubectl rollout undo deployment/sample-app'
        }
    }
}
```

---

## Conclusion (10 min)

### Key Takeaways

1. **Modern CI/CD requires multiple tools** working together
2. **Local development environments** enable learning without external dependencies
3. **Pipeline as Code** makes CI/CD configurations versionable and reviewable
4. **Code quality integration** is essential for modern development
5. **Automated testing and deployment** reduce human error

### Discussion Questions

- How does this setup compare to cloud-based CI/CD platforms?
- What are the benefits and challenges of running CI/CD locally?
- How would you scale this setup for a production environment?

### Next Steps

- Explore cloud-based CI/CD platforms (GitHub Actions, GitLab CI, etc.)
- Learn about infrastructure as code (Terraform, CloudFormation)
- Study monitoring and observability tools
- Practice with different deployment strategies

## Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [GitLab Documentation](https://docs.gitlab.com/)
- [SonarQube Documentation](https://docs.sonarqube.org/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

