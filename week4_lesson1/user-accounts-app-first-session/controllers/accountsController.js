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
