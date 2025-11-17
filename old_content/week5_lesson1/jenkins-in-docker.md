# Run Jenkins in Docker

[Clone this repo](https://git.generalassemb.ly/tristanhall/jenkins-docker-compose-setup)

Then cd into the folder and run the command `docker-compose up -d node` in your terminal.

## Logging into Jenkins

Once the containers are running, navigate to `http://localhost:8080` in the browser.

You can login to jenkins with the following credentials:

Username: admin
Password: admin

### Fork and clone the sample repository

Obtain the simple "Welcome to React" Node.js and React application from GitHub, by forking the sample repository of the application’s source code into your own GitHub account and then cloning this fork locally.

1. Make sure you're signed into your GA enterprise account.
2. Fork the [simple-node-js-react-npm-app](https://git.generalassemb.ly/tristanhall/simple-node-js-react-npm-app) on GitHub into your GitHub account. If you need help with this process, refer to the Fork A Repo documentation on the GitHub website for more information.
3. Clone your forked `simple-node-js-react-npm-app` repository (on GitHub) locally to your machines Desktop.

### Create your Pipeline project in Jenkins

1. Go back to Jenkins, log in again if necessary and click create new jobs under Welcome to Jenkins!
   Note: If you don’t see this, click New Item at the top left.
2. In the Enter an item name field, specify the name for your new Pipeline project (e.g. `simple-node-js-react-npm-app`).
3. Scroll down and click Pipeline, then click OK at the end of the page.
4. (Optional) On the next page, specify a brief description for your Pipeline in the Description field (e.g. An entry-level Pipeline demonstrating how to use Jenkins to build a simple Node.js and React application with npm.)
5. Click the Pipeline tab at the top of the page to scroll down to the Pipeline section.
6. From the Definition field, choose the Pipeline script from SCM option. This option instructs Jenkins to obtain your Pipeline from Source Control Management (SCM), which will be your locally cloned Git repository.
7. From the SCM field, choose Git.
8. In the Repository URL field, enter the browser url for the front page of your simple-node-js-react-npm-app.
9. You'll need to add a credential. From the dropdown menu, choose the `Jenkins Credential` option. This will open up a new popup window.
10. The kind of credential we want to use is an `Username and password`.
11. Enter your github enterprise username and password in the fields.
12. You should see the red error disappear, signalling that Jenkins has successfully connected to the repo.

### Create your initial Pipeline as a Jenkinsfile

You’re now ready to create your Pipeline that will automate building your Node.js and React application in Jenkins. Your Pipeline will be created as a Jenkinsfile, which will be committed to your cloned Git repository (simple-node-js-react-npm-app).

This is the foundation of "Pipeline-as-Code", which treats the continuous delivery pipeline as a part of the application to be versioned and reviewed like any other code. Read more about Pipeline and what a Jenkinsfile is in the Pipeline and Using a Jenkinsfile sections of the User Handbook.

First, create an initial Pipeline to download a Node Docker image and run it as a Docker container (which will build your simple Node.js and React application). Also add a "Build" stage to the Pipeline that begins orchestrating this whole process.

1. Using VS Code, create and save new text file with the name `Jenkinsfile` at the root of your local `simple-node-js-react-npm-app` Git repository.
2. Copy the following Declarative Pipeline code and paste it into your empty Jenkinsfile:

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'npm install'
            }
        }
    }
}
```

Save your edited `Jenkinsfile` and commit and push your changes to your `simple-node-js-react-npm-app` Git repository. E.g. Within the `simple-node-js-react-npm-app` directory, run the commands:

```sh
git add .
```

then

```sh
git commit -m "Add initial Jenkinsfile"
```

then

```sh
git push
```

Go back to Jenkins again, log in again if necessary and run the pipeline.

You'll see a job get added to the queue on the left. Click on the job name and you can watch Jenkins make it's way through the tasks defined in the pipeline.

### Add a test stage to your Pipeline

1. Go b ack to your text editor/IDE and ensure your Jenkinsfile is open.
2. Update your Jenkinsfile to look like this:

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'npm install'
            }
        }
        stage('Test') {
            steps {
                sh './jenkins/scripts/test.sh'
            }
        }
    }
}
```

3. Create a commit and push it back to github
4. Run the pipeline in Jenkins and you will notice now that Jenkins has registered the new stage and will carry it out in the pipeline

### Add a final deliver stage to your Pipeline

- Go back to your text editor/IDE and ensure your Jenkinsfile is open.

- update your Jenkinsfile to:

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'npm install'
            }
        }
        stage('Test') {
            steps {
                sh './jenkins/scripts/test.sh'
            }
        }
        stage('Deliver') {
            steps {
                sh './jenkins/scripts/deliver.sh'
                input message: 'Finished using the web site? (Click "Proceed" to continue)'
                sh './jenkins/scripts/kill.sh'
            }
        }
    }
}
```

- Save your edited Jenkinsfile and commit it to your simple-node-js-react-npm-app Git repository. E.g. Within the simple-node-js-react-npm-app directory. Send the commit back to github.

- Go back to Jenkins again, log in again if necessary.

- Run the pipeline

When the pipeline gets to the deliver stage, visit `http://localhost:3000` in the browser to view your Node.js and React application running (in development mode) in a new web browser tab. You should see a page/site with the title Welcome to React on it.
Tip: If you’re feeling a little adventurous, you can try accessing the terminal/command prompt of your Jenkins Docker container, then using vi editor, tweak and save the `App.js` source file and see the results appear on the Welcome to React page. To do this, run the following commands:

```sh
docker exec -it <docker-container-name> bash
cd /var/jenkins_home/workspace/simple-node-js-react-npm-app/src
vi App.js
```

- This command provides access to the terminal/command prompt of your Jenkins Docker container. The <docker-container-name> can be obtained using the command docker ps. Otherwise, it would be jenkins-tutorials (if you specified this in the command you used to run this container above - i.e. --name jenkins-tutorials).
- Once in the container, change directory to the Node.js and React source directory (in the Jenkins workspace directory within Jenkins home).
- Access, edit and save changes to your application’s App.js file using vi editor.

When you are finished viewing the page/site, click the Proceed button to complete the Pipeline’s execution.

### Wrapping up

Well done! You’ve just used Jenkins to build a simple Node.js and React application with npm!

The "Build", "Test" and "Deliver" stages you created above are the basis for building more complex Node.js and React applications in Jenkins, as well as Node.js and React applications that integrate with other technology stacks.

Because Jenkins is extremely extensible, it can be modified and configured to handle practically any aspect of build orchestration and automation.
