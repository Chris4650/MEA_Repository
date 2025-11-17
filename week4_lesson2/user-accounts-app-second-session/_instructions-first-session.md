1. Initialise the project.

```sh
npm init -y
```

This creates the package.json.

2. We will need some packages to build our project. These include:

   - express: A framework to help us build APIs
   - @aws-sdk/client-dynamodb: A toolkit for interacting with DynamoBD
   - @aws-sdk/lib-dynamodb: : A toolkit for interacting with DynamoBD
   - dotenv: A package that allows us to use environment variables from a .env file in our code
   - joi: A package that validates schemas (useful to define what keys/values our data should have)
   - cors: Helps us to configure cross-origin-resource-sharing
   - morgan: A logging tool so we can see what is happening to our API in the terminal (incoming requests)

Let's install these:

```sh
npm install express @aws-sdk/client-dynamodb @aws-sdk/lib-dynamodb dotenv joi cors morgan
```

This creates the package-lock.json and node_modules folder.

3. We need an "entry point" for our source code. As part of running the `npm init  -y` command, we created the line `"main": "index.js",`. This tells our app that the entry point is called `index.js` but the file was not created. Create the `index.js` file in the root of the project.

```sh
touch index.js
```

4. Let's create the app. Put this code in the `index.js`

```js
import express from "express";

const port = 3000;
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

5. Start the app locally using `node index.js` in your terminal. This will use the local installation of node to run the app. You should get some feedback that says "Listening on Port: 3000". Terminate the process with `ctrl c`.

6. Now let's add some endpoints to our app. Create a folder called `views` in the root of the project and inside that folder, we will create a file called `router.js`, by running the terminal command:

```sh
mkdir views; touch views/router.js
```

7. Let's create a router, and add a route to handle the `/accounts` endpoint. We will add functions to handle GET and POST http methods.

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

8. Now let's import the Router into our `index.js` and tell the app to use these routes. Update the `index.js` file to:

```js
import express from "express";
import Router from "./views/router.js";

const port = 3000;
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

9. Let's test what we have so far. Use postman to send GET and POST requests to `http://localhost:3000/accounts`. You should see the responses we wrote into the router.js file.

10. So far everything is working, but having to stop the app and restart it every time we make a change is not a good developer experience. Let's use a tool called `nodemon` to watch for changes in the source code and rebuild the app whenever we save a change. Install nodemon as a "dev dependency" (dev dependencies are not added in a production build to keep bundles as small as possible).

```sh
npm install nodemon --save-dev
```

11. Go to the `package.json` file and replace the `scripts` object with this:

```json
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "dev": "nodemon index.js",
    "prod": "node index.js"
  },
```

Now when we want to start the app for development purposes, we will run the command `npm run dev` in our terminal, which will start the app with nodemon. If we want to run it for production, we will run the command `npm run prod` which will start the app with node.

12. Back to the source code: These functions that are responding to the incoming requests are called Controller functions. Let's create a new file called `accountsController.js` and put all of the controller functions in there. Create a folder in the root of the project called `controllers` and then create a file in our new folder called `accountsController.js`.

```sh
mkdir controllers; touch controllers/accountsController.js
```

13. Put this code into the accountsController.js:

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

14. Now update the `router.js` to use the controller functions from the `accountsController.js`:

```js
import express from "express";
import accountsController from "../controllers/accountsController.js";

const Router = express.Router();

Router.route("/accounts")
  .get(accountsController.getAllAccounts)
  .post(accountsController.createAccount);

export default Router;
```

15. This is the basic structure of our API project. From here we can easily add new routes, http methods and controller functions. Let's add a new route which would target a specific account.
    The id of the account is going to be passed to the controller function through the url (endpoint). So rather than making a request to "http://localhost:3000/accounts", we will make a request to "http://localhost:3000/accounts/[insert id here]" to tell the controller function which account to get from the database.

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

16. Now let's update the router and make it consume these controller functions. We'll add a new endpoint too.

```js
import express from "express";
import accountsController from "../controllers/accountsController.js";

const Router = express.Router();

Router.route("/accounts")
  .get(accountsController.getAllAccounts)
  .post(accountsController.createAccount);

Router.route("/accounts/:id")
  .get(accountsController.getAccountById)
  .put(accountsController.updateAccountById)
  .delete(accountsController.deleteAccountById);

export default Router;
```

17. That's our app with all the routes and controllers we will need. Let's create a `.gitignore` file to ignore the node_modules folder and then push the code into a repo.
