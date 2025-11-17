# Harness Sample Application

A simple Node.js Express application designed for learning Harness CI/CD platform.

## Features

- RESTful API endpoints
- Health check endpoint
- Comprehensive test suite
- Docker containerization
- Kubernetes deployment manifests
- Security best practices (helmet, cors)

## Quick Start

### Prerequisites

- Node.js 18 or higher
- Docker
- Kubernetes cluster (optional)

### Local Development

1. Install dependencies:

```bash
npm install
```

2. Start the development server:

```bash
npm run dev
```

3. The application will be available at `http://localhost:3000`

### Testing

Run the test suite:

```bash
npm test
```

Run tests in watch mode:

```bash
npm run test:watch
```

### Docker

Build the Docker image:

```bash
docker build -t harness-sample-app .
```

Run the container:

```bash
docker run -p 3000:3000 harness-sample-app
```

### Kubernetes

Deploy to Kubernetes:

```bash
kubectl apply -f k8s/
```

## API Endpoints

- `GET /` - Welcome message and app info
- `GET /health` - Health check endpoint
- `GET /api/users` - List all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create new user

## Environment Variables

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development/production)
- `APP_VERSION` - Application version

## Project Structure

```
harness-sample-app/
├── index.js              # Main application file
├── package.json          # Dependencies and scripts
├── Dockerfile           # Docker configuration
├── k8s/                 # Kubernetes manifests
│   └── deployment.yaml
├── tests/               # Test files
│   └── app.test.js
└── README.md            # This file
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

MIT License

