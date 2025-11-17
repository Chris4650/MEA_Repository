Before we begin, make sure you have node modules installed.

1. So far, we have an API that receives and responds to GET, POST, PUT and DELETE methods on the endpoints "http://localhost:3000/accounts" and "http://localhost:3000/accounts/[insert account id here]". This is great, but we are missing a few key things relating to building software for the cloud:

   - conatiners
   - environment variables
   - a data store

Let's address the first point - containers.

Let's write a Dockerfile that will turn our app into an image, which we can use to run a container with our app inside.

Make a new file in the root of the project called `Dockerfile` - note the capital D in Dockerfile.

```sh
touch Dockerfile
```

2. Copy this code into the Dockerfile:

```Dockerfile
FROM node:18-alpine

# take environment variables
ARG NODE_ENV=prod
ARG PORT=8080
ENV NODE_ENV=$NODE_ENV
ENV PORT=$PORT

# Create app directory
WORKDIR /usr/src/app

COPY package*.json ./

RUN if [ "$NODE_ENV" = "dev" ]; then \
    npm install; \
    else \
    npm install --omit=dev; \
    fi

# Copy app source code
COPY ./ ./

# Expose port and start application
EXPOSE $PORT
CMD npm run $NODE_ENV --loglevel=verbose
```

3. Build the Docker image:

Open a terminal in the directory containing the Dockerfile.
Run the following command to build the Docker image, replacing `your-image-name` with a name for your image:

```sh
docker build -t your-image-name .
```

4. Run the Docker container:

After the image is built, run the container using the following command, replacing your-image-name with the name you used in the build step:

```sh
docker run -p 8080:8080 your-image-name
```

If you need to specify a different port or environment, you can pass environment variables using the -e flag:

```sh
docker run -p 8080:8080 -e NODE_ENV=dev -e PORT=8080 your-image-name
```

4. Now our application is containerised, let's address the environment variables issue. By fixing this, we'll then be able to pass things such as the PORT to our application, enabling us to run the app on any port without having to change the source code in the container. We installed the package `dotenv` in the last session, so let's now use it to read environment variables in the code.

Update the `index.js` file:

```js
import dotenv from "dotenv";
dotenv.config();

import express from "express";
import Router from "./views/router.js";

const port = process.env.PORT;
const app = express();

app.use(express.json());
app.use(Router);

async function startServer() {
  try {
    app.listen(port, () => console.log(`🤖 Listening on Port: ${port}`));
  } catch (err) {
    console.log("🤖 Oh no something went wrong", err);
  }
}

startServer();
```

5. Now let's create a .env file in the root of our project where we can define our environment variables.

```sh
touch .env
```

Put this code into the .env file:

```dotenv
PORT=3000
NODE_ENV=dev
```

6. Test it out in postman. Build and run the container by using:

```sh
docker build -t your-image-name .
```

and

```sh
docker run -p 3000:3000 your-image-name
```

You'll see that you can use postman to call the API on "http://localhost:3000/accounts". Changing the port number in the docker run command will make the app run on a different port.

6. There's a caveat here though - we now have to rebuild our container every time we make a change, just like we were having to do with starting/stopping the app before we used nodemon. Let's fix this by using `docker-compose`

# install docker compose:

```sh
sudo curl -SL https://github.com/docker/compose/releases/download/v2.11.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose &&
sudo usermod -aG docker $USER &&
sudo chgrp docker /usr/local/bin/docker-compose &&
sudo chmod 755 /usr/local/bin/docker-compose
```

7. Create a `docker-compose.yml` file in the root of the project and paste the following code into it:

```yml
version: "3.8"

services:
  app:
    container_name: app
    restart: always
    build:
      context: .
      dockerfile: Dockerfile
      args:
        - NODE_ENV=${NODE_ENV}
        - PORT=${PORT}
    ports:
      - "${PORT}:${PORT}"
    volumes:
      - ./:/usr/src/app
      - /usr/src/app/node_modules
    environment:
      - PORT=${PORT}
```

8. Run the docker-compose file:

```sh
docker-compose up --build
```

With this setup, Docker Compose will mount your local directory into the container. Any changes you make to the code will be reflected in the container, and you can restart the container to see the changes without rebuilding the image manually. This is a much better developer experience!

9. We've now got `hot reloading` containers and environment variables, the last piece of the puzzle is the data store, otherwise known as a database. Let's create a database now. At first, we will just pull an image of an AWS DynamoDB database to create a database container locally. This is great for local development purposes, but the data will never actually leave our computer, so we'll need something different for production - we'll need an actual AWS databse instance in the cloud. We'll do that later.

First, let's update our `docker-compose.yml` so at the same time as building our app, it also pulls and runs an image for DynamoDB.

```yml
version: "3.8"

services:
  accounts-api-app:
    container_name: accounts-api-app
    restart: always
    build:
      context: .
      dockerfile: Dockerfile
      args:
        - NODE_ENV=${NODE_ENV}
        - PORT=${PORT}
    ports:
      - "${PORT}:${PORT}"
    volumes:
      - ./:/usr/src/app
      - /usr/src/app/node_modules
    environment:
      - PORT=${PORT}
  dynamodb:
    container_name: dynamodb
    image: amazon/dynamodb-local
    ports:
      - "8000:8000"
    volumes:
      - dynamodb-data:/home/dynamodblocal
volumes:
  dynamodb-data:
```

10. Run the app by using the command

```sh
docker-compose up --build
```

Then look in your running containers with

```sh
docker ps
```

You should see you have 2 containers running (at least) - `dynamodb` and `accounts-api-app`

SO: we have our app running in a container, we have a container running a DynamoDB database, now let's update our app so it uses the database!

11. Let's create a folder in the root of our project called `services` and inside services, let's create a file called `database.js`

```sh
mkdir services;
touch services/database.js;
```

12. Paste this code into `database.js`:

```js
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({
  region: "us-east-1",
  endpoint: "http://dynamodb:8000",
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || "dummy",
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || "dummy",
  },
});

const database = DynamoDBDocumentClient.from(client);

export default database;
```

Note that the endpoint is "http://dynamodb:8000". This is because our database container is called dynamodb.

13. Let's update one of our controller functions to see if we can connect to the database. Go to `accountsController.js` and update the file to this: (differences are the imports and the getAllAccounts function at this point)

```js
import database from "../services/database.js";
import { ScanCommand } from "@aws-sdk/lib-dynamodb";

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

function createAccount(req, res) {
  res.send(
    "🤖 Accounts Route with POST method - this endpoint will create a new account in the database"
  );
}

function getAccountById(req, res) {
  const accountId = req.params.id;
  res.send(
    "🤖 Accounts Route with GET method - this endpoint will get a single account by ID from the database. The account is: " +
      accountId
  );
}

function updateAccountById(req, res) {
  const accountId = req.params.id;
  res.send(
    "🤖 Accounts Route with PUT method - this endpoint will update a single account by ID from the database. The account is: " +
      accountId
  );
}

function deleteAccountById(req, res) {
  const accountId = req.params.id;
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

Test the api by running the getAllAccounts function by sending a GET request to "http://localhost:3000/acounts" and you'll see this error:

`ResourceNotFoundException: Cannot do operations on a non-existent table`

13. Let's use Ansible to fix this. Create a file called create_accounts_table.yml and paste this code into it:

```yml
---
- name: Create DynamoDB Table in Docker Container
  hosts: localhost
  gather_facts: no
  vars:
    dynamodb_endpoint: "http://localhost:8000"
    aws_access_key_id: "dummy"
    aws_secret_access_key: "dummy"
    table_name: "Accounts"
    region: "us-east-1"

  tasks:
    - name: Create the Accounts DynamoDB table using AWS CLI
      command: >
        aws dynamodb create-table
        --table-name {{ table_name }}
        --attribute-definitions AttributeName=id,AttributeType=S
        --key-schema AttributeName=id,KeyType=HASH
        --billing-mode PROVISIONED
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
        --endpoint-url {{ dynamodb_endpoint }}
      environment:
        AWS_ACCESS_KEY_ID: "{{ aws_access_key_id }}"
        AWS_SECRET_ACCESS_KEY: "{{ aws_secret_access_key }}"
      register: dynamodb_result

    - name: Show detailed result of table creation
      debug:
        var: dynamodb_result

    - name: List tables in DynamoDB
      command: >
        aws dynamodb list-tables
        --endpoint-url {{ dynamodb_endpoint }}
      environment:
        AWS_ACCESS_KEY_ID: "{{ aws_access_key_id }}"
        AWS_SECRET_ACCESS_KEY: "{{ aws_secret_access_key }}"
      register: list_tables_result

    - name: Show list of tables
      debug:
        var: list_tables_result
```

14. Run the ansible playbook by running the following terminal command: _Make sure you have the containers running when you do this_

```sh
ansible-playbook create_accounts_table.yml
```

This will create the Accounts table in the dynamodb instance. And you'll be able to call the API and get an empty array back (theres no accounts yet).

15. Creating an account: with dynamodb, there's no enforcement of the schema done by the database. We want to make sure that we have consisent data, so we will use a package called `joi` to make things required, and then construct an object of data at the controller function to make sure we don't save any keys that we don't want. We installed joi in the last session, so let's use it to create a schema.

Create a new directory called `models` at the root of the project, and inside models, create a file called `account.js`

```sh
mkdir models;
touch models/account.js;
```

16. Copy this code into `account.js`

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

17. Let's now use the accountSchema to validate the request body and create an Account in the database. We will use uuid to create a unique ID for each account before we send the data to DynamoDB.

Complete the controller functions like so:

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

async function updateAccountById(req, res) {
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

async function deleteAccountById(req, res) {
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

Test all the functions in postman, everything should be working!

# Introducing Terraform

Now that we have a working API that runs in a container, it could be deployed. But, the database we currently use is on our computer in another container, so it's not live data and only we can access it.

Let's use Terraform to go to our AWS account and provision us a DynamoDB instance.

1. We need to get the Access Key and Secret Key for our AWS accounts. Go to whizlabs, sign in and go to the `Custom Sandboxes` tab. Create your sandbox and follow the instructions until you get your credntials.

2. Configure the AWS CLI. Run the following command in the terminal and follow the prompts:

```sh
aws configure
```

This creates a `credentials` file stored in ~/.aws/credentials. This file will be used for authentication when we try to access AWS.

3. Create a file in the root of the project called `accounts_database.tf`

```sh
touch accounts_database.tf
```

4. Copy this code into the file:

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

```sh
terraform init
```

6. Now run the plan to see what you're asking terraform to do

```sh
terraform plan
```

7. If you're happy with the plan, apply it

```sh
terraform apply
```

You'll need to type "yes" to confirm that you want terraform to carry out these changes and build the infrastructure in your AWS account. Check your AWS account dynamodb tables after terraform completes to confirm that the accounts table has been created.

# Connect Our Containerised Accounts Api To Our AWS DynamoDB in the cloud

1. Update the `database.js` file to this:

```js
import { DynamoDBClient, ListTablesCommand } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({
  region: "us-east-1",
  endpoint: process.env.DYNAMODB_ENDPOINT || "http://dynamodb:8000",
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || "dummy",
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || "dummy",
  },
});

const database = DynamoDBDocumentClient.from(client);

export async function listDatabaseTables() {
  try {
    const command = new ListTablesCommand({});
    const response = await database.send(command);
    console.log("Tables:", response.TableNames);
  } catch (error) {
    console.error("Error listing tables:", error);
  }
}

export default database;
```

2. update the `.env` to this:

```dotenv
PORT=3000
NODE_ENV=dev
AWS_ACCESS_KEY_ID="your aws access key from whizlabs"
AWS_SECRET_ACCESS_KEY="your aws secret access key from whizlabs"
DYNAMODB_ENDPOINT=https://dynamodb.us-east-1.amazonaws.com
```

Run the container using:

```sh
docker run -p 3000:3000 -e NODE_ENV=dev -e PORT=3000 -e AWS_ACCESS_KEY_ID=[your access key id] -e AWS_SECRET_ACCESS_KEY=[ your secret access key] your-container-name
```

3. Test your API and see the data being added to your production database in AWS!

4. Finally, when you're done with your AWS Database instance, destroy it using

```sh
terraform destroy
```

type yes and hit return and terraform will destroy the infrastructure for you!
