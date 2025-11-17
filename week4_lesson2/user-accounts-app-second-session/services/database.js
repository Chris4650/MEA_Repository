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
