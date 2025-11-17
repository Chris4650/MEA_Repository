# Harness CI/ CD Platform

In this session, we will create and deploy a CD pipeline in Harness CD Community Edition using a public Docker image and a local Kubernetes cluster.

## Requirements

Harness CD Community Edition:

- Docker
- 3GB RAM and 2 CPUs is the minimum.
- Docker Compose (included in Docker Desktop).
- 20GB of free disk space.

Tutorial:

- GitHub account.
- Docker Compose Kubernetes is installed and running in Docker Desktop (a new installation of Docker Desktop might need to have Kubernetes enabled in its Settings).
- Docker Compose Kubernetes should have at least 2GB memory and 1 CPU. That will bring the total Docker Desktop resources up to a minimum of 5GB and 3 CPUs.
- If you want to use Minikube instead of Docker Desktop Kubernetes, use Minikube minimum version v1.22.0 or later installed locally.
- Minikube needs 4GB and 4 CPUs: minikube start --memory 4g --cpus 4.
- Kubernetes cluster.
- This is the target cluster for the deployment you will set up in this quickstart. When Docker Compose Kubernetes is installed it comes with a cluster and the default namespace. You don't need to make any changes to Docker Compose Kubernetes. Don't have a cluster? Go to Notes below.
- Review Harness CD Community Edition overview and Harness key concepts to establish a general understanding of Harness.

## Overview

Harness CI/CD is a modern software delivery platform that helps development teams automate the process of getting code from development to production. Think of it as a smart conveyor belt system for your code - it takes care of testing, building, and deploying your applications automatically and safely.

The "CI" part (Continuous Integration) automatically checks code changes when developers submit their work. It runs tests to make sure nothing breaks and builds the application into a ready-to-deploy package. This is like having a very thorough quality control inspector checking every piece of work.

The "CD" part (Continuous Delivery/Deployment) handles getting that tested and packaged code into your live systems. It's like having an expert delivery service that knows exactly how to transport and install your application, whether it's going to cloud platforms like AWS or Kubernetes clusters.

What makes Harness special is its intelligent automation. Unlike older CI/CD tools that need lots of manual configuration and scripting, Harness uses AI/ML to make smart decisions. For example, it can automatically detect if a deployment is causing problems and roll it back without human intervention - like having a safety net that catches issues before they affect your users.

Harness also includes modern features like:

- Built-in security scanning to catch vulnerabilities
- GitOps support for managing infrastructure as code
- Visual pipelines that make it easy to see and configure your delivery process
- Multi-cloud support so you can deploy anywhere
- Automated rollbacks if something goes wrong

For teams learning modern software practices, Harness represents the next generation of deployment tools - making it easier and safer to get your code from development to production while following DevOps best practices.

## Getting Started - Minikube / Our Cluster

We need to have a kubernetes cluster for Harness to connect to. Minikube is going to need 4GB of memory and 4 CPUs, so let's start that up now:

In a terminal, run:

```sh
minikube start --memory 4g --cpus 4
```

If minikube fails to start, it could be due to already having a cluster configuration, so you can destroy it and then run the command above again. To destroy an existing cluster configuration, run:

```sh
minikube stop &&
minikube delete --profile=minikube &&
minikube delete --all --purge
```

## Getting Started - Starting Harness CD

Our local version of Harness has 2 main components:

- Harness Manager: the Harness Manager is where your CD configurations are stored and your pipelines are managed.
  After you install Harness, you sign up in the Manager at http://localhost/#/signup.
  Pipelines are triggered manually in the Harness Manager or automatically in response to Git events, schedules, new artifacts, and so on.
- Harness Delegate: the Harness Delegate is a software service you install in your environment that connects to the Harness Manager and performs tasks using your container orchestration platforms, artifact repositories, etc.
  You can install a Delegate inline when setting up connections to your resources or separately as needed. This guide will walk you through setting up a Harness Delegate inline.

1. Navigate into the folder that contains the docker-compose files:

```sh
cd harness-cd-community/docker-compose/harness
```

2. Start the containers:

```sh
docker-compose up -d
```

The first download can take 3–12 mins (downloading images and starting all containers) depending on the speed of your Internet connection. You won't be able to sign up until all the required containers are up and running.The output will look something like this:

```txt
[+] Running 13/13
⠿ Network harness_harness-network     Created         0.1s
⠿ Container harness_log-service_1     Started         2.9s
```

3. Now make sure that all services are running

```sh
docker-compose ps
```

All services should show `running (healthy)`. If any show `running (starting)`, wait a minute, and run `docker-compose ps` again until they are all `running (healthy)`.

4. Run the following command to start the Harness Manager (it will wait until all services are healthy):

```sh
docker-compose run --rm proxy wait-for-it.sh ng-manager:7090 -t 180
```

The output will look something like this:

```txt
[+] Running 6/0
⠿ Container harness_platform-service_1 Running 0.0s
⠿ Container harness_pipeline-service_1 Running 0.0s
⠿ Container harness_manager_1 Running 0.0s
⠿ Container harness_delegate-proxy_1 Running 0.0s
⠿ Container harness_ng-manager_1 Running 0.0s
⠿ Container harness_ng-ui_1 Running 0.0s
wait-for-it.sh: waiting 180 seconds for ng-manager:7090
wait-for-it.sh: ng-manager:7090 is available after 0 seconds
```

Wait until you see the line `wait-for-it.sh: ng-manager:7090 is available after 0 seconds`

5. In your browser, go to the URL `http://localhost/#/signup`.

If you see a 403 error, that just means the Harness Manager service isn't up and running yet. Make sure you ran the wait-for-it.sh script earlier and wait a few minutes: `docker-compose run --rm proxy wait-for-it.sh ng-manager:7090 -t 180`.

6. Enter an email address and password and select **Sign up**.

You'll see the CD page:

![](./static/harness-community-edition-quickstart-133.png)

You're now using Harness!

The next section walks you through setting up and running a simple CD Pipeline using a public manifest and Docker image.

## Create pipeline

We'll create a quick CD pipeline that deploys a public manifest and image (nginx) to our local Kubernetes cluster (minikube).

1. In Harness, select **Create Project**.
2. In **About the Project**, in **Name**, enter **Quickstart**, and then select **Save and Continue**.
3. In **Invite Collaborators**, select **Save and Continue**. Your new project appears. Let's add a CD pipeline.
4. In **Setup Pipeline**, enter the name **quickstart**, and then select **Start**. Your new pipeline is started.

Now let's jumpstart your pipeline setup by pasting in the YAML for a pipeline. Once it's pasted in, we'll update a few placeholders and then deploy.

Copy the following YAML:

```yaml
pipeline:
  name: quickstart
  identifier: quickstart
  projectIdentifier: Quickstart
  orgIdentifier: default
  tags: {}
  stages:
    - stage:
        name: demo
        identifier: demo
        description: ""
        type: Deployment
        spec:
          serviceConfig:
            serviceRef: <+input>
            serviceDefinition:
              type: Kubernetes
              spec:
                variables: []
                manifests:
                  - manifest:
                      identifier: nginx
                      type: K8sManifest
                      spec:
                        store:
                          type: Github
                          spec:
                            connectorRef: <+input>
                            gitFetchType: Branch
                            paths:
                              - content/en/examples/application/nginx-app.yaml
                            repoName: <+input>
                            branch: main
                        skipResourceVersioning: false
          infrastructure:
            environmentRef: <+input>
            infrastructureDefinition:
              type: KubernetesDirect
              spec:
                connectorRef: <+input>
                namespace: <+input>
                releaseName: release-<+INFRA_KEY>
            allowSimultaneousDeployments: false
          execution:
            steps:
              - step:
                  type: K8sRollingDeploy
                  name: Rollout Deployment
                  identifier: Rollout_Deployment
                  spec:
                    skipDryRun: false
                  timeout: 10m
            rollbackSteps: []
        tags: {}
        failureStrategies:
          - onFailure:
              errors:
                - AllErrors
              action:
                type: StageRollback
```

In Pipeline Studio, select YAML.

![Pipeline YAML](images/pipeline-yml.png)

Select Edit YAML.
Replace the YAML contents with the YAML you copied above.
Select Save.
Select Visual. The new pipeline is created.

![Created Pipeline](images/created-pipeline.png)

Let's quickly review some key pipeline concepts:

- Harness Delegate: the Harness Delegate is a software service you install in your environment that connects to the Harness Manager and performs tasks using your container orchestration platforms, artifact repositories, monitoring systems, etc.
- Pipelines: A CD pipeline is a series of stages where each stage deploys a service to an environment.
- Stages: A CD stage is a subset of a pipeline that contains the logic to perform one major segment of the deployment process.
- Services: A service represents your microservices and other workloads logically. A service is a logical entity to be deployed, monitored, or changed independently.
- Service Definition: Service definitions represent the real artifacts, manifests, and variables of a service. They are the actual files and variable values.
- Environments: Environments represent your deployment targets logically (QA, Prod, etc).
- Infrastructure Definition: Infrastructure definitions represent an environment's infrastructure physically. They are the actual target clusters, hosts, etc.
- Execution Steps: Execution steps perform the CD operations like applying a manifest, asking for approval, rollback, and so on. Harness automatically adds the steps you need for the deployment strategy you select. You can then add additional steps to perform many other operations.
- Connectors: Connectors contain the information necessary to integrate and work with 3rd party tools such as Git providers and artifact repos. Harness uses connectors at pipeline runtime to authenticate and perform operations with a 3rd party tool.
- You'll notice a runtime input expression <+input> for most of the settings. These are placeholders we'll replace when we run the pipeline. 6. Select Run. The Run Pipeline settings appear.

![Configure Pipeline](images/configure-pipeline.png)

Now let's update the placeholders.

**Specify Service**

1. Select **New Service**.
2. In **Name**, enter **nginx**.
3. Select **Save**.

**Manifests**
Here you'll add a connector to Github using your personal GitHub credentials.

Credentials are encrypted and stored locally in the MongoDB service installed as part of Harness CE

You'll also install a Harness Kubernetes Delegate in your local Kubernetes cluster.

This Delegate will perform all operations at runtime.

**Connector**
Select the Connector dropdown menu.
Select New Connector.
In **Name**, enter **GitHub**, and then select **Continue**.
In **URL Type**, select **Repository**.
In **Connection Type**, select **HTTP**.
In GitHub Repository URL, enter https://github.com/kubernetes/website.
Select Continue.
In Username, enter your GitHub account username.
In Github, create a personal access token and copy the value to your clipboard. The token should have full access to repos.
![Github PAT Scope](images/PAT-scope.png)
Select **New Secret Text**.

1. In **Secret Name**, enter the name **github-pat**.
2. In **Secret Value**, paste in a GitHub Personal Access Token (PAT). When you're logged into GitHub, these are typically listed at https://github.com/settings/tokens. For steps on setting up a GitHub PAT, see Creating a personal access token from GitHub. Ensure you PAT has the repo scope selected.
3. Select **Save**, and then select **Continue**.

**Connect to the provider**

1. Select **Connect through a Harness Delegate**, and then select **Continue**.

**Delegates Setup**

1. Select **Install a New Delegate**.
2. Select **Kubernetes**, and then select **Continue**.
3. Enter a name **quickstart** for the Delegate, select the **Laptop** size, and then select **Continue**.
4. Select **Download YAML file**. The YAML file for the Kubernetes Delegate will download to your computer.
5. Open a terminal and navigate to where the Delegate file is located.
6. On a terminal, run this command:

```sh
kubectl apply -f harness-delegate.yaml
```

This installs the Delegate into the default cluster that comes with Docker Desktop Kubernetes. It can take a few minutes for the Delegate pod to run.

7. Run `kubectl get pods -n harness-delegate-ng` to verify that it is Ready: 1/1 and Status: Running.
8. Back in Harness, select **Continue**.
9. Once the Delegate registers, select **Done**.
10. In **Delegates Setup**, select **Connect only via Delegates which has all of the following tags**, and then select the tag for your new Delegate (**quickstart**).
11. Select **Save and Continue**.

The Connection Test should prove successful. If not, review your credentials.

12. Select **Finish**.

**Repository name**

1. Enter `https://github.com/kubernetes/website`.

**Infrastructure**
Here you'll create a connection to the target cluster for this CD stage.

1. Select **New Environment**.
2. In **Name**, enter **quickstart**, select **Non-Production**, and select **Save**.

**Connector**

1. Select the **Connector** dropdown menu, and then select **New Connector**.
2. In **Name**, enter **localK8s**, and then select **Continue**.
3. In **Details**, select **Use the credentials of a specific Harness Delegate**, and then select **Continue**.
   - If you are running a local Delegate but using a target cluster that does not have a Delegate installed in it, select **Specify master URL and credentials**, and then go to Notes below.
4. In **Delegates Setup**, select **Connect only via Delegates which has all of the following tags**, and then enter and select **quickstart**. The Delegate you added earlier is selected.
5. Select **Save and Continue**.
6. In **Connection Test**, select **Finish**.

**Namespace**

1. Enter **default**. If you are using a different namespace, such as a namespace given to you by someone in your company, enter that namespace instead.

Now that the placeholders are configured, you can deploy the pipeline.

If you want to save these settings, you can select **Save as Input Set**. Then you can use them whenever you run this pipeline.

## Deploy

![Dashboard](images/run-pipeline.png)

1. In **Run Pipeline**, select **Run Pipeline**.

You can see the pipeline fetch the manifest and deploy the NGINX artifact to your local cluster.

2. Select **Console View** to see more of the logs and watch the deployment in realtime.

In the **Rollout Deployment** step, in **Wait for Steady State**, you'll see that NGINX was deployed successfully:

```txt
Status : my-nginx deployment "my-nginx" successfully rolled out
```

Congratulations! You have a successful local deployment using Harness CD Community Edition!

Now you can use Harness to deploy remotely. Simply follow the same steps but use a remote target cluster.

## Clean Up

To clean up your environment, do the following.

To delete the Delegate, run the following:

```sh
kubectl delete statefulset -n harness-delegate-ng quickstart
```

To remove Harness CD Community Edition, run the following:

```sh
docker-compose down -v
```

To remove the Harness images, use docker rmi to removes images by their ID.

To remove the image, you first need to list all the images to get the Image IDs, Image name and other details. Run docker images -a or docker images.

Note the images you want to remove, and then run:

```sh
docker rmi <image-id> <image-id> ...
```

To remove all images at once, run:

```sh
docker rmi $(docker images -q)
```
