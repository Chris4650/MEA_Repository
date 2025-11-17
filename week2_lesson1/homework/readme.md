# Homework - Dockerizing a Node.js application

Let's create a directory on our desktop called `hello-node`

- Navigate to the Desktop in a terminal to create the directory by running `mkdir hello-node` .
- Navigate into the directory by typing `cd hello-node`

Now we will need to set up a `package.json` file. Run `npm init -y` inside our directory and complete the prompted steps to initialise.

We are going to use a javascript framework called express to create an api. Express provides a suite of functions and methods that we can use to make and handle http requests and responses.

Now we need to install `express` and `os`. Go ahead and run `npm install express os`.
At this point, your `package.json` should look a bit like this:

```json
{
  "name": "example",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.17.1",
    "os": "^0.1.2"
  }
}
```

Note that the `package.json` has been updated and the `dependencies` key has been added. These are dependencies of our project.

Now let's set up our server. Create an `index.js` file (with `touch index.js`) and open the directory in VSCode (navigate to the `hello-node` folder and run `code .`).

Let's create a simple function to respond to a request to `'/'` (the root). Copy this code into your `index.js`

```js
const express = require("express");
const app = express();
const port = 3000;
const os = require("os");

const hostname = os.hostname();

app.get("/", (req, res) => {
  res
    .status(200)
    .send(`Hello World! \n this application is running on ${hostname}`);
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
```

Now let's add a script to the `package.json` to start our app.

Add `"start": "node index.js"` to the scripts object. After this, your whole `package.json` file should look like this:

```json
{
  "name": "hello-node",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "node index.js"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.17.1",
    "os": "^0.1.2"
  }
}
```

Now let's try to run the app locally. In a terminal, run `npm start`

The feedback should look like this:

```bash
> hello-node@1.0.0 start /home/vmuser/Desktop/hello-node
> node index.js

listening on localhost port 3000
```

Now open up a browser and navigate to `http://localhost:3000` and you should see our message "Hello World!"

Now all this is fine and working but what about Docker? Currently the application is running on our local machine and reliant on the host having node installed. What if we didn't have node? Or what if we had a version of node that is incompatable with our application?

Let's dockerize the application to make sure that our app can run anywhere.

Create a `Dockerfile` in the directory.

Now we need to tell docker what to do with our application. First we need to say what to base our image on. In this case, let's use `node:16-alpine`

```yml
FROM node:16-alpine
```

Now let's copy our source code into the container

```yml
COPY . .
```

Let's run the script to install the node modules inside the container

```yml
RUN npm install
```

And now let's run the script to start the application

```yml
CMD ["node", "index.js"]
```

Your Dockerfile should look like this:

```yml
FROM node:16-alpine
COPY . .
RUN npm install
CMD ["node", "index.js"]
```

Now that we have written our dockerfile, let's delete the node modules. Without these the application can not run on our local.

```bash
rm -rf node_modules
```

Now let's tell docker to create our image

```bash
docker build -t hello-node .
```

Docker will build the image and we can see if it's complete by running `docker images` to list all of the images on our machine. You should now see one with the tag `hello-node`

Let's start it!

```bash
docker run -dp 3000:3000 hello-node
```

Let's go back to our browser and navigate to `http://localhost:3000` again. Our application is working! The container is running with all of the dependencies inside it!

## Conclusion

By dockerizing our app, we have made it so it can run on any machine! No more "it worked fine in development"!

## Pushing an image to dockerhub

Make sure you have a docker hub account created.

You can do this at `https://app.docker.com/signup`. (Rememeber your username and password for the next step)

> 💡 _If you created a new account, don’t forget to verify your email before continuing._

Login through the CLI

```bash
docker login
```

and enter your username and password

build the image with your docker username as a tag, for example:

```bash
docker build -t <dockerid>/hello-node .
```

e.g. `docker build -t the-presidents-dockerhub/hello-node .`

now push the image to the registry

```bash
docker image push <dockerid>/hello-node
```
