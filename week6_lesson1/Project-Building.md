# Capstone Project Instructions

For your capstone project, you will be building an API using JavaScript, Docker and Terraform.

By the end of this project you will have built:

- A fully functional working API, built using Express.js.
- The API will have endpoints to Create, Read, Update and Delete data from a database.
- The database will be DynamoDB, running either in a provided AWS sandbox account or running in a local container on the workspace.
- The choice of which database you want to use is yours.
- The "theme" of the API is your choice, but for ease, you can keep it similar to the "Accounts" API we have built in class.

We previously made an "Accounts" api in class, but now is your time to build one on your own. Think of a service that you would like to build - as a starting point, we suggest an API that would make Lloyds a "greener" organisation. Previous ideas have included:

- Ride sharing API
- Office Equipment Swap API
- Carbon offset API

However, you're free to build whatever API you like, so don't feel you have to stick to the "green theme".

Follow the steps carefully and you'll have a working, containerised API.

## Section 1 - Setting up the project folder and installing dependencies

1. Project folder + **git** init

Use your terminal to navigate to the Desktop, create a project folder and then navigate into the project folder.

You can change "my-project" in the commands below to whever nest describes your API.

```sh
cd ~/Desktop
mkdir my-project
cd my-project
```

Initialize git in the project folder:

```sh
git init
```

Create a `README.md` and a `.gitignore` file in the root of the project and open the project in VSCode.

```sh
touch README.md
touch .gitignore
code .
```

- Write the name of your project and a short description in the `README.md` file and save it.
- In the `.gitignore` file, add the line `node_modules/` to make sure we don't commit the node modules folder to git.

Make your first git commit with the message "Initial commit" using the VSCode Source Control tab.

**Note**: Later, don't forget to commit after each section and update the `.gitignore` file if you need to ignore any other files/folders.

2. Initialise the folder so we can use npm (Node Package Manager)

This creates the package.json file.

```sh
npm init -y
```

3. We will need some packages to build our project:

   - express: A framework to help us build APIs
   - @aws-sdk/client-dynamodb: A toolkit for interacting with DynamoBD
   - @aws-sdk/lib-dynamodb: : A toolkit for interacting with DynamoBD
   - dotenv: A package that allows us to use environment variables from a .env file in our code
   - joi: A package that validates schemas (useful to define what keys/values our data should have)
   - cors: Helps us to configure cross-origin-resource-sharing
   - morgan: A logging tool so we can see what is happening to our API in the terminal (incoming requests)

Let's install these by running the following command in the terminal:

**_ make sure the working directory in your terminal is the project directory _**

```sh
npm install express @aws-sdk/client-dynamodb @aws-sdk/lib-dynamodb dotenv joi cors morgan uuid
```

4. We need an "entry point" for our source code. As part of running the `npm init  -y` command, we created the line `"main": "index.js",` which can be found in the package.json (if you want to see it). This tells our app that the entry point is called `index.js`, but the file was not actually created by running that command, so we need to do it manually. Create the `index.js` file in the root of the project and open it in VSCode.

**_ make sure the working directory in your terminal is the root if the project directory _**

```sh
touch index.js
code .
```

5. Navigate to the package.json and add the line `"type": "module"` to the top level object. After doing this, your package.json should look similar to this:

6. Add a new line to the "scripts" object which will be our start. The line should be `"start": "node index.js"`. Make sure you put a comma at the end of the "test" line so the json is valid.

**_ version numbers may be different _**

```json
{
  "name": "npm-test",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "type": "module", // <---- ADD THIS LINE
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1", // <---- COMMA
    "start": "node index.js" // <---- ADD THIS LINE
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "@aws-sdk/client-dynamodb": "^3.686.0",
    "@aws-sdk/lib-dynamodb": "^3.686.0",
    "cors": "^2.8.5",
    "dotenv": "^16.4.5",
    "express": "^4.21.1",
    "joi": "^17.13.3",
    "morgan": "^1.10.0",
    "uuid": "13.0.0"
  }
}
```

**Reminder**: Add a new commit! What would a suitable commit message be at this point?

## Section 2 - build a basic express.js API

1. Let's create a basic app that will listen for incoming requests. Put this code in the `index.js`

```js
import dotenv from "dotenv";
dotenv.config();
import express from "express";

const port = process.env.PORT;
const app = express();

app.use(express.json());

async function startServer() {
  try {
    app.listen(port, () => console.log(`🤖 Listening on Port: ${port}`));
  } catch (err) {
    console.log("🤖 Oh no something went wrong", err);
  }
}

startServer();
```

2. Create a file called .env in the root of the project.

**_ make sure the working directory in your terminal is the root if the project directory _**

```sh
touch .env
```

Add `.env` to the `.gitignore` file so we don't commit it to git.

3. Copy the following code into the `.env` file:

```dotenv
PORT=3000
```

4. Start the app to test if everything works so far. Use your terminal to execute the start script that we added to the package.json in the previous section.

**_ If you have any other processes already running on port `3000`, use docker ps to find their container ids and kill the containers. Also check there are no other running terminals _**

```sh
npm run start
```

5. Check the app is running: you should see the message `🤖 Listening on Port: 3000` show up in the terminal.

6. Stop the app by pressing `ctrl + c` in the terminal.

## Section 3 - Adding views/endpoints to the app

1. Create a folder called `views` in the root of the project and inside that folder, we will create a file called `router.js`, by running the terminal command:

**_ make sure the working directory in your terminal is the root if the project directory _**

```sh
mkdir views
touch views/router.js
```

2. Let's create a router, and add a route to handle the `/accounts` endpoint. We will add functions to handle GET and POST http methods.

**_ This example is using the accounts API, but you can change your endpoints to better suit your API _**

```js
import express from "express";

const Router = express.Router();

Router.route("/accounts")
  .get((req, res) => {
    res.send(
      "🤖 Accounts Route with GET method - this endpoint will get all of the accounts from the database"
    );
  })
  .post((req, res) => {
    res.send(
      "🤖 Accounts Route with POST method - this endpoint will create a new account in the database"
    );
  });

export default Router;
```

3. Now let's import the Router into our `index.js` and tell the app to use these routes. Update the `index.js` file to:

```js
import dotenv from "dotenv";
dotenv.config();
import express from "express";
import Router from "./views/router.js"; // <-- ADD THIS LINE

const port = 3000;
const app = express();

app.use(express.json());
app.use(Router); // <-- ADD THIS LINE

async function startServer() {
  try {
    app.listen(port, () => console.log(`🤖 Listening on Port: ${port}`));
  } catch (err) {
    console.log("🤖 Oh no something went wrong", err);
  }
}

startServer();
```

4. Start the app again by running the start script in the terminal.

**_ If you have any other processes already running on port 3000, use docker ps to find their container ids and kill the containers. Also check there are no other running terminals _**

```sh
npm run start
```

5. Check the app is running: you should see the message `🤖 Listening on Port: 3000` show up in the terminal.

**Reminder**: Add a new commit 😉

## Section 4 - Test the endpoints in Postman.

1. Open postman from your workspace desktop.

2. Use postman to send GET and POST requests to `http://localhost:3000/accounts`. You should see the responses we wrote into the `router.js` file.

**_ You will need to change the endpoints to match the ones you create in the router. The above endpoint is for the accounts API _**

3. Stop the app by pressing `ctrl + c` in the terminal.

## Section 5 - Developer environment & Nodemon

1. So far everything is working, but having to stop the app and restart it every time we make a change is not a good developer experience. Let's use a tool called `nodemon` to watch for changes in the source code and rebuild the app whenever we save a change. Install nodemon as a "dev dependency" (dev dependencies are not added in a production build to keep bundles as small as possible).

**_ make sure the working directory in your terminal is the root if the project directory _**

```sh
npm install nodemon --save-dev
```

2. Go to the `package.json` file and update the `scripts` object with this:

```json
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "dev": "nodemon index.js",
    "prod": "node index.js"
  },
```

Now when we want to start the app for development purposes, we will run the command `npm run dev` in our terminal, which will start the app with nodemon. If we want to run it for production, we will run the command `npm run prod` which will start the app with node.

3. Start the app in dev mode:

**_ make sure the working directory in your terminal is the root if the project directory _**

```sh
npm run dev
```

## Section 6 - Adding controllers to the app

1. The functions that are responding to the incoming requests are called Controller functions. Let's create a new file called `accountsController.js` and put all of the controller functions in there, essentially moving them from the views to the controller file, to separate the concerns. Create a folder in the root of the project called `controllers` and then create a file in our new folder called `accountsController.js`.

**_ In a second terminal, make sure the working directory in your terminal is the root if the project directory _**

```sh
mkdir controllers
touch controllers/accountsController.js
```

2. Put this code into the accountsController.js:

```js
function getAllAccounts(req, res) {
  res.send(
    "🤖 Accounts Route with GET method - this endpoint will get all of the accounts from the database"
  );
}

function createAccount(req, res) {
  res.send(
    "🤖 Accounts Route with POST method - this endpoint will create a new account in the database"
  );
}

export default {
  getAllAccounts,
  createAccount,
};
```

3. Now update the `router.js` to use the controller functions from the `accountsController.js`:

```js
import express from "express";
import accountsController from "../controllers/accountsController.js";

const Router = express.Router();

Router.route("/accounts")
  .get(accountsController.getAllAccounts)
  .post(accountsController.createAccount);

export default Router;
```

3. Use postman to send GET and POST requests to `http://localhost:3000/accounts`. You should see the responses we wrote into the `accountsController.js` file.

**_ You will need to change the endpoints to match the ones you create in the router. The above endpoint is for the accounts API _**

## Section 7 - Adding more routes for CRUD

1. Currently, we have a structure of our API project. From here we can easily add new routes, http methods and controller functions. Let's add a new route which would target a specific account.

The id of the account is going to be passed to the controller function through the url (endpoint). So rather than making a request to `http://localhost:3000/accounts`, we will make a request to "http://localhost:3000/accounts/[insert id here]" to tell the controller function which account to get from the database.

For example, if the account id was `54321-12345-54321-12345` we would make the url that we call in postman `http://localhost:3000/accounts/54321-12345-54321-12345`.

Let's start with creating some controller functions. Let's update the accountsController.js to add functions that will get, update and delete a single account.

```js
function getAllAccounts(req, res) {
  res.send(
    "🤖 Accounts Route with GET method - this endpoint will get all of the accounts from the database"
  );
}

function createAccount(req, res) {
  res.send(
    "🤖 Accounts Route with POST method - this endpoint will create a new account in the database"
  );
}

function getAccountById(req, res) {
  const accountId = req.params.id; // <-- this is where we get the id from the request url
  res.send(
    "🤖 Accounts Route with GET method - this endpoint will get a single account by ID from the database. The account is: " +
      accountId
  );
}

function updateAccountById(req, res) {
  const accountId = req.params.id; // <-- this is where we get the id from the request url
  res.send(
    "🤖 Accounts Route with PUT method - this endpoint will update a single account by ID from the database. The account is: " +
      accountId
  );
}

function deleteAccountById(req, res) {
  const accountId = req.params.id; // <-- this is where we get the id from the request url
  res.send(
    "🤖 Accounts Route with DELETE method - this endpoint will delete a single account by ID from the database. The account is: " +
      accountId
  );
}

export default {
  getAllAccounts,
  createAccount,
  getAccountById,
  updateAccountById,
  deleteAccountById,
};
```

2. Now let's update the router and make it consume these controller functions. We'll add a new endpoint too.

```js
import express from "express";
import accountsController from "../controllers/accountsController.js";

const Router = express.Router();

Router.route("/accounts")
  .get(accountsController.getAllAccounts)
  .post(accountsController.createAccount);

Router.route("/accounts/:id") // <-- this defines an endpoint with a "placeholder" for the id
  .get(accountsController.getAccountById)
  .put(accountsController.updateAccountById)
  .delete(accountsController.deleteAccountById);

export default Router;
```

3. Test all the functions in postman. You can make the following requests:

- GET request to `http://localhost:3000/accounts`
- POST request to `http://localhost:3000/accounts`
- GET request to `http://localhost:3000/accounts/account-id-goes-here`
- PUT request to `http://localhost:3000/accounts/account-id-goes-here`
- DELETE request to `http://localhost:3000/accounts/account-id-goes-here`

## Section 8 - Setting up a database with Terraform

Let's use Terraform to go to our AWS account and provision us a DynamoDB instance.

1. We need to get the Access Key and Secret Key for our AWS accounts. Go to whizlabs, sign in and go to the `Custom Sandboxes` tab. Create your sandbox and follow the instructions until you get your credntials.

2. If you haven't already done so earlier in the course do this step, otherwise go to step 3. Configure the AWS CLI. Run the following command in the terminal and follow the prompts:

**_ Sign in to whizlabs on the workspace so you can copy/paste the keys from whizlabs directly into the workspace' terminal. Typing them out by hand will likely lead to typos _**

```sh
aws configure
```

This creates a `credentials` file stored in ~/.aws/credentials. This file will be used for authentication when we try to access AWS.

3. Create a file in the root of the project called `accounts_database.tf`, or whatever suits the theme of your API.

**_ make sure the working directory in your terminal is the root if the project directory _**

```sh
touch accounts_database.tf
```

4. Copy this code into the file, adapting the name of the table to suit your API:

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "accounts" {
  name         = "Accounts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "AccountsTable"
  }
}
```

5. Initialise terraform by running

**_ make sure the working directory in your terminal is the root if the project directory _**

```sh
terraform init
```

6. Now run the plan to see what you're asking terraform to do

**_ make sure the working directory in your terminal is the root if the project directory _**

```sh
terraform plan
```

7. If you're happy with the plan, apply it

**_ make sure the working directory in your terminal is the root if the project directory _**

```sh
terraform apply
```

You'll need to type "yes" to confirm that you want terraform to carry out these changes and build the infrastructure in your AWS account. Check your AWS account dynamodb tables after terraform completes to confirm that the accounts table has been created.

## Section 9 - Connecting our app to the database

1. Let's create a folder in the root of our project called `services` and inside services, let's create a file called `database.js`

**_ make sure the working directory in your terminal is the root if the project directory _**

```sh
mkdir services
touch services/database.js
```

2. Copy this code into the `database.js` file:

```js
import dotenv from "dotenv";
dotenv.config();
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({
  region: process.env.DYNAMODB_REGION,
  endpoint: process.env.DYNAMODB_ENDPOINT,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

const database = DynamoDBDocumentClient.from(client);

export default database;
```

3. Update the `.env` at the root of the project and copy in these variables, updating the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` with the keys from your whizlabs custom sandbox:

```dotenv
PORT=3000
AWS_ACCESS_KEY_ID=your-aws-access-key-from-whizlabs
AWS_SECRET_ACCESS_KEY=your-aws-secret-access-key-from-whizlabs
DYNAMODB_REGION=us-east-1
DYNAMODB_ENDPOINT=https://dynamodb.us-east-1.amazonaws.com
```

4. As we have changed the `.env` file, we will need to stop and restart the app manually to get nodemon to build with the new environment variables. Just press `ctrl + c` (with the terminal focussed) and then restart it with:

**_ make sure the working directory in your terminal is the root if the project directory _**

```sh
npm run dev
```

5. Creating an account: with dynamodb, there's no enforcement of the schema done by the database. We want to make sure that we have consisent data, so we will use a package called `joi` to make things required, and then construct an object of data at the controller function to make sure we don't save any keys that we don't want. We installed joi in the last session, so let's use it to create a schema.

Create a new directory called `models` at the root of the project, and inside models, create a file called `account.js`

**_ make sure the working directory in your terminal is the root if the project directory. Remember to change "account" to whatever suits the theme of your API _**

```sh
mkdir models
touch models/account.js
```

6. Copy this code into `account.js`

You can change the schema to match the theme of your API. This one is for accounts, but it will probably be slightly different for your API.

```js
import joi from "joi";

const accountSchema = joi.object({
  id: joi.string().required(),
  sort_code: joi.string().required(),
  account_number: joi.number().required(),
  balance: joi.number().required(),
});

export default accountSchema;
```

7. Update the `accountsController.js`. We are doing two things in this update:

- Changing the controller functions to use the database to perform CRUD operations
- Schema validation

```js
import database from "../services/database.js";
import {
  ScanCommand,
  PutCommand,
  GetCommand,
  UpdateCommand,
  DeleteCommand,
} from "@aws-sdk/lib-dynamodb";
import { v4 as uuidv4 } from "uuid";
import accountSchema from "../models/account.js";

async function getAllAccounts(req, res, next) {
  try {
    const params = {
      TableName: "Accounts",
    };
    const command = new ScanCommand(params);
    const result = await database.send(command);
    res.status(200).json(result.Items);
  } catch (err) {
    next(err);
  }
}

async function createAccount(req, res, next) {
  try {
    const uuid = uuidv4();
    req.body.id = uuid;
    const { error, value } = accountSchema.validate(req.body);

    if (error) {
      res.status(400).json({ error: error.details[0].message });
      return;
    }

    const { id, sort_code, account_number, balance } = value;

    const params = {
      TableName: "Accounts",
      Item: {
        id,
        sort_code,
        account_number,
        balance,
      },
    };

    const command = new PutCommand(params);

    await database.send(command);

    res
      .status(201)
      .json({ message: "Successfully created account", data: params.Item });
  } catch (error) {
    next(error);
  }
}

async function getAccountById(req, res, next) {
  const accountId = req.params.id;
  try {
    const params = {
      TableName: "Accounts",
      Key: { id: accountId },
    };
    const command = new GetCommand(params);
    const result = await database.send(command);
    if (!result.Item) {
      return res.status(404).json({ message: "No account found" });
    }
    res.status(200).json(result.Item);
  } catch (err) {
    next(err);
  }
}

async function updateAccountById(req, res, next) {
  try {
    const accountId = req.params.id;
    req.body.id = accountId;
    const { error, value } = accountSchema.validate(req.body);

    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { balance, sort_code, account_number } = value;

    // Get the movie from DynamoDB
    const getParams = {
      TableName: "Accounts",
      Key: { id: accountId },
    };

    const getCommand = new GetCommand(getParams);

    const result = await database.send(getCommand);

    const account = result.Item;

    if (!account) {
      return res.status(404).json({ message: "No account found" });
    }

    // Update the account in DynamoDB
    const updateParams = {
      TableName: "Accounts",
      Key: { id: accountId },
      UpdateExpression:
        "set #balance = :balance, #sort_code = :sort_code, #account_number = :account_number",
      ExpressionAttributeNames: {
        "#balance": "balance",
        "#sort_code": "sort_code",
        "#account_number": "account_number",
      },
      ExpressionAttributeValues: {
        ":balance": balance,
        ":sort_code": sort_code,
        ":account_number": account_number,
      },
      ReturnValues: "ALL_NEW",
    };
    const updateCommand = new UpdateCommand(updateParams);
    const updatedAccount = await database.send(updateCommand);

    res.status(200).json(updatedAccount.Attributes);
  } catch (err) {
    next(err);
  }
}

async function deleteAccountById(req, res, next) {
  const accountId = req.params.id;
  try {
    const params = {
      TableName: "Accounts",
      Key: { id: accountId },
    };
    const command = new DeleteCommand(params);
    await database.send(command);
    res.status(204).end();
  } catch (err) {
    next(err);
  }
}

export default {
  getAllAccounts,
  createAccount,
  getAccountById,
  updateAccountById,
  deleteAccountById,
};
```

## Section 10 - Test the app and database in postman

1. Create an item in the database.

- send a POST request to `http://localhost:3000/accounts`
- the body of the requests should be raw, json and match the schema defined in your model.

2. Get all items

- send a GET request to `http://localhost:3000`

3. Get a single item

- send a GET request to `http://localhost:3000/-insert-item-id-here`

4. Update a single item

- send a PUT request to `http://localhost:3000/-insert-item-id-here`
- the body of the requests should be raw, json and contain the keys/values you want to update.

5. Delete a single item

- send a DELETE request to `http://localhost:3000/-insert-item-id-here`

## Section 11 – Containerise the App Using Your Existing .env File

You already created an `.env` file earlier in this project.  
Let’s reuse it to securely provide your AWS credentials and port configuration.

### 🧩 Step 1 – Stop the app running locally

Press **Ctrl + C** in your terminal to stop any running instance.

### 🧩 Step 2 – Create a Dockerfile

In the root of your project, create a file called `Dockerfile`:

```bash
touch Dockerfile
```

Paste this content:

```Dockerfile
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install --omit=dev

# Copy app source code
COPY ./ ./

# Expose port and start application
EXPOSE 3000
CMD npm run prod --loglevel=verbose
```

### 🧩 Step 3 – Build the Docker image

Run this command in your project root:

```bash
docker build -t your-image-name .
```

### 🧩 Step 4 – Run the Docker container with your .env file

Instead of hardcoding environment variables, pass your existing `.env` file:

```bash
docker run --env-file .env -p 3000:3000 your-image-name
```

Now your app runs in a container, using credentials safely loaded from `.env`.

### ✅ Test in Postman

Open **Postman** and send requests to:

```
GET http://localhost:3000/accounts
POST http://localhost:3000/accounts
```

You should see the same results as before, but now your API is running in Docker.

## Section 12 – Bonus: Add a Simple Frontend

Let’s make this more visual by adding a **tiny frontend** that connects to your backend API.

### 🧩 Step 1 – Enable CORS in your backend

#### A - Install the CORS package

Run this command in your project root:

```bash
npm install cors
```

This will add a `cors` entry to your `package.json` dependencies. Take a look to confirm it’s there.

#### B - Update your `index.js` to use CORS

Because the frontend runs on a different port (8080), browsers will block requests unless you explicitly allow them.

Add the following two lines to your existing `index.js`.  
The comments show exactly what was added:

```js
import dotenv from "dotenv";
dotenv.config();
import express from "express";
import cors from "cors"; // <-- Added line

const port = process.env.PORT;
const app = express();

app.use(cors()); // <-- Added line
app.use(express.json());

async function startServer() {
  try {
    app.listen(port, () => console.log(`🤖 Listening on Port: ${port}`));
  } catch (err) {
    console.log("🤖 Oh no something went wrong", err);
  }
}

startServer();
```

---

### 🧩 Step 2 – Create a simple frontend

Create a folder named `frontend` in your project root:

```bash
mkdir frontend
cd frontend
touch index.html style.css
```

#### `frontend/index.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>My API Frontend</title>
    <link rel="stylesheet" href="style.css" />
  </head>
  <body>
    <h1>☕ My Tiny Frontend</h1>
    <p>This frontend calls your API running on port 3000:</p>
    <button id="fetch-btn">Fetch /accounts</button>
    <div id="output">Waiting for data...</div>

    <script>
      document
        .getElementById("fetch-btn")
        .addEventListener("click", async () => {
          const output = document.getElementById("output");
          output.textContent = "Fetching data...";
          try {
            const res = await fetch("http://localhost:3000/accounts");
            if (!res.ok) throw new Error("HTTP " + res.status);
            const text = await res.text();
            output.textContent = text;
          } catch (err) {
            output.textContent =
              "❌ Could not reach backend (" + err.message + ")";
          }
        });
    </script>
  </body>
</html>
```

#### `frontend/style.css`

```css
body {
  font-family: system-ui, sans-serif;
  background: linear-gradient(135deg, #20232a, #0088cc);
  color: white;
  text-align: center;
  padding: 2rem;
}

h1 {
  font-size: 2rem;
  margin-bottom: 1rem;
}

button {
  background: #00cc99;
  color: black;
  border: none;
  border-radius: 6px;
  padding: 0.7rem 1.2rem;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s;
}

button:hover {
  background: #00e6b8;
}

#output {
  margin-top: 2rem;
  background: rgba(255, 255, 255, 0.1);
  padding: 1rem;
  border-radius: 8px;
  font-size: 0.95rem;
}
```

---

### 🧩 Step 3 – Run both locally

Open **two terminals**:

**Terminal 1 (Backend):**

```bash
npm run dev
```

This runs your Express API at `http://localhost:3000`.

**Terminal 2 (Frontend):**

```bash
cd frontend
python3 -m http.server 8080
```

This serves your `index.html` at `http://localhost:8080`.

Now open [http://localhost:8080](http://localhost:8080) in your browser.  
Click the **“Fetch /accounts”** button — you’ll see your backend’s response appear inside a styled page.

---

### 🧠 Why this is powerful

- You’ve connected a **frontend and backend** using just HTML, JS, and Fetch.
- You’ve learned how to **enable CORS** and avoid browser restrictions.
- You can enhance the CSS or add more routes easily.

For more advanced students, this setup can be expanded to:

- Build a React or Vue frontend later.
- Serve the static frontend directly from Express.
- Add a `frontend.Dockerfile` and use both together with Docker Compose.

🎉 Congratulations — you’ve now gone from backend, to container, to connected full stack!
