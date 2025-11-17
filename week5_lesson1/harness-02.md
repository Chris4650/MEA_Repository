# Harness Open Source CI/CD Workshop – "Tiny App" Demo

## 1. Introduction

Welcome to this hands-on session with **Harness Open Source**!  
In this exercise, you'll experience what CI/CD feels like in practice.  
We’ll run pipelines, watch ephemeral containers spin up, and understand how continuous integration and deployment work under the hood.

Harness Open Source runs every pipeline step in **temporary containers** – each one starts, executes a few tasks, then disappears.  
In the enterprise version, these steps would connect to external systems like Kubernetes, Docker Hub, and GitHub using **connectors**.

---

## 2. Setup

Make sure you are on the `main` branch via:

```bash
git switch main
```

You may need to get rid of your local changes first:

```bash
git reset --hard
```

Attention: This will delete any uncommitted changes!

---

## 3. Prepare the Files

Create a `frontend` and `backend` folder in your repo root via VSCode.

Then add the following files:

### Backend Files

**backend/package.json**

```json
{
  "name": "tiny-backend",
  "version": "1.0.0",
  "type": "module",
  "dependencies": {
    "express": "^4.19.2"
  },
  "scripts": {
    "start": "node server.js",
    "test": "node test.js"
  }
}
```

**backend/server.js**

```js
import express from "express";
const app = express();
const port = 3456;

app.get("/", (req, res) => {
  res.send("<h2 style='color:#0088cc'>Hello from Tiny Backend!</h2>");
});

app.listen(port, () => console.log(`Server running on port ${port}`));
```

**backend/test.js**

```js
console.log("Running tests...");

// ✅ Passing test
const sum = (a, b) => a + b;
if (sum(2, 3) === 5) {
  console.log("✅ Math test passed!");
} else {
  console.error("❌ Math test failed!");
  process.exit(1);
}

// ❌ Failing test (simulated database error)
try {
  throw new Error("Simulated test failure: database connection not found");
} catch (err) {
  console.error("❌", err.message);
  process.exit(1);
}
```

---

### Frontend Files

**frontend/index.html**

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Tiny Frontend</title>
  </head>
  <body style="background-color:#222;color:#00ccff;font-family:sans-serif;">
    <h1>Hello from Tiny Frontend!</h1>
    <p>Open your console to see the magic.</p>
    <script src="script.js"></script>
  </body>
</html>
```

**frontend/script.js**

```js
console.log("Tiny Frontend running!");
```

---

## 4. Watch the Containers

Open a second terminal (if you closed it) and run:

```bash
watch -n 1 "docker ps --format 'table {{.Names}}	{{.Status}}	{{.Image}}'"
```

This will show ephemeral containers appearing and disappearing as Harness runs each stage.

---

## 5. Create the Pipeline in the Harness UI

Inside of the Repository, go to **Pipelines → New Pipeline** and call it `pipeline-tiny-app`

Start from the given scaffold and replace it with this:

```yaml
version: 1
kind: pipeline
spec:
  stages:
    - name: backend-ci
      type: ci
      spec:
        steps:
          - name: backend-test
            type: run
            spec:
              container:
                image: node:20
              script: |
                echo "=== Backend CI started ==="
                ls -lah
                cd ./backend || exit 1
                npm install
                npm test || echo "(tests optional for demo)"
                sleep 4
                echo "✅ Backend CI finished"

    - name: frontend-ci
      type: ci
      spec:
        steps:
          - name: frontend-build
            type: run
            spec:
              container:
                image: node:20
              script: |
                echo "=== Frontend CI started ==="
                ls -lah
                cd ./frontend || exit 1
                mkdir -p ../dist
                cp index.html script.js ../dist/
                echo "<!-- built on $(date) -->" >> ../dist/index.html
                sleep 3
                echo "✅ Frontend CI finished"
                ls -lah ../dist

    - name: deploy
      type: ci
      spec:
        steps:
          - name: bump-version
            type: run
            spec:
              container:
                image: node:20
              script: |
                echo "=== Bumping backend version (minor) ==="
                cd ./backend
                node -e "let f=require('./package.json');let [M,m,p]=f.version.split('.').map(Number);f.version=[M,m+1,0].join('.');require('fs').writeFileSync('package.json',JSON.stringify(f,null,2));console.log('✅ New version:',f.version)"
                cat package.json
                echo ""
                echo "💡 Note: This happens inside Harness containers only."
                echo "   To persist this change, a connector with Git push rights would be required."
                sleep 2

          - name: docker-build-simulated
            type: run
            spec:
              container:
                image: node:20
              script: |
                echo "=== Simulated Docker Build Stage ==="
                export IMG=tiny-app:$(date +%s)
                echo "Simulating: docker build -t $IMG ."
                echo "✅ Simulated build complete"
                echo ""
                echo "To build and run locally:"
                echo "1️⃣ docker build -t tiny-app:latest ."
                echo "2️⃣ docker run -d --rm -p 6789:3456 tiny-app:latest"
                echo "3️⃣ Open: http://localhost:6789"
                sleep 2
```

---

## 6. Run the Pipeline

Select **Run** and watch:

- Containers appear in your `watch` window.
- Logs stream in Harness UI.
- The **Backend test** fails (intentionally).
- The other stages still run for simulation.

In a real setup, a failure could trigger a **Slack notification** via a webhook connector, alerting the engineering team.

---

## 7. In a Real CI/CD Setup

If this were a full Harness SaaS environment:

- **GitHub Connector:** pulls the source code automatically.
- **Docker Connector:** pushes built images to Docker Hub.
- **Kubernetes Connector:** deploys images to a cluster.
- **Slack Connector:** notifies teams on failures or deploys.

All secrets and tokens are stored securely within Harness.  
Each stage still runs in an **ephemeral container**, but those containers have access to these external services.

---

## 8. Build and Run Locally

After the simulated build completes, run the commands locally to see your app:

```bash
docker build -t tiny-app:latest .
docker run -d --rm --name tiny-app -p 6789:3456 tiny-app:latest
open http://localhost:6789
```

You should see:

> "Hello from Tiny Backend!"

**Note**: This only serves the backend. The frontend is not connected in this demo.

---

## 9. Discussion & Reflection

## 9. Discussion & Reflection

<details>
<summary><strong>Q1: What’s the advantage of ephemeral containers?</strong></summary>

They ensure isolation, reproducibility, and cleanliness.  
Each build starts fresh, so no hidden dependencies remain.

</details>

<details>
<summary><strong>Q2: How would this differ with a real Kubernetes target?</strong></summary>

In production, the deploy stage would use a Kubernetes connector  
to apply manifests and roll out pods to a live cluster.

</details>

<details>
<summary><strong>Q3: Why simulate Docker here instead of building it inside Harness?</strong></summary>

The Open Source version lacks Docker daemon access;  
simulation avoids permission issues while preserving the learning experience.

</details>

<details>
<summary><strong>Q4: What happens when tests fail in a real CI pipeline?</strong></summary>

The pipeline stops or marks a stage as failed.  
Usually, a Slack connector notifies a team channel about the failure automatically.

</details>

---

🎉 **You’ve built, tested, and “deployed” a tiny app through Harness Open Source!**  
Even without live connectors, you’ve experienced the essence of modern CI/CD.
