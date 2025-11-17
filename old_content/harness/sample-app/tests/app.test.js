const request = require("supertest");
const app = require("../index");

describe("Harness Sample App", () => {
  describe("GET /", () => {
    it("should return welcome message", async () => {
      const response = await request(app).get("/");
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty("message");
      expect(response.body.message).toContain("Welcome to Harness Sample App");
    });
  });

  describe("GET /health", () => {
    it("should return health status", async () => {
      const response = await request(app).get("/health");
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty("status", "healthy");
      expect(response.body).toHaveProperty("timestamp");
      expect(response.body).toHaveProperty("uptime");
    });
  });

  describe("GET /api/users", () => {
    it("should return list of users", async () => {
      const response = await request(app).get("/api/users");
      expect(response.status).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
      expect(response.body[0]).toHaveProperty("id");
      expect(response.body[0]).toHaveProperty("name");
      expect(response.body[0]).toHaveProperty("email");
    });
  });

  describe("GET /api/users/:id", () => {
    it("should return user by id", async () => {
      const response = await request(app).get("/api/users/1");
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty("id", 1);
      expect(response.body).toHaveProperty("name");
      expect(response.body).toHaveProperty("email");
    });

    it("should return 404 for non-existent user", async () => {
      const response = await request(app).get("/api/users/999");
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty("error", "User not found");
    });
  });

  describe("POST /api/users", () => {
    it("should create new user", async () => {
      const newUser = {
        name: "Test User",
        email: "test@example.com",
      };

      const response = await request(app).post("/api/users").send(newUser);

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty("id");
      expect(response.body).toHaveProperty("name", newUser.name);
      expect(response.body).toHaveProperty("email", newUser.email);
    });

    it("should return 400 for missing name", async () => {
      const newUser = {
        email: "test@example.com",
      };

      const response = await request(app).post("/api/users").send(newUser);

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty("error");
    });

    it("should return 400 for missing email", async () => {
      const newUser = {
        name: "Test User",
      };

      const response = await request(app).post("/api/users").send(newUser);

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty("error");
    });
  });

  describe("404 handling", () => {
    it("should return 404 for non-existent routes", async () => {
      const response = await request(app).get("/non-existent");
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty("error", "Route not found");
    });
  });
});

