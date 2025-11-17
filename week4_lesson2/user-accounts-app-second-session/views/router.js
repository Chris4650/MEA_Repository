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
