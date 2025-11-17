# 🧱 Harness Open Source – Hands-On CI/CD Workshop

This lab gives you a _feel_ for how Continuous Integration (CI) actually works.
You’ll start by running Harness locally, create a first “Hello World” pipeline and add a trigger for the CI pipeline.

---

## Step 0 – Install Harness Open Source

We're basically following the [quick-start instructions](https://developer.harness.io/docs/open-source/installation/quick-start)

Run the Harness container locally (no dependencies needed beyond Docker Desktop).

```bash
docker run -d \
  -p 3000:3000 -p 3022:3022 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp/harness:/data \
  --name opensource \
  --restart always \
  harness/harness
```

Then:

1. Visit [http://localhost:3000]()
2. Select **Sign Up**
3. Enter a User ID, Email, and Password
4. Click **Sign Up**

### Create a project

1. Select **New Project**
2. Enter a project **Name** (e.g. `Quickstart`)
3. Click **Create Project**

### Create a repository

1. Inside your project, open **Repositories → New Repository**
2. Name it **tiny-app**
3. Click **Create Repository**

Clone the repo locally (using the **HTTPS** URL shown in the UI - link may vary):

```bash
git clone https://localhost:3000/<your-user>/tiny-app.git
cd tiny-app
code .
```

---

## Step 1 – Hello World Pipeline

Before you run your first pipeline, open a new terminal window and start watching Docker containers in real-time:

```bash
watch -n 1 "docker ps --format 'table {{.Names}}	{{.Status}}	{{.Image}}'"
```

Go to **Pipelines → New Pipeline** and call it `pipeline-hello`.

Start from the given scaffold (will look something like this):

```yaml
version: 1
kind: pipeline
spec:
  stages:
    - name: build
      type: ci
      spec:
        steps:
          - name: hello
            type: run
            spec:
              container:
                image: alpine
              script: echo "hello world"
```

and replace it with this:

```yaml
version: 1
kind: pipeline
spec:
  stages:
    - name: hello
      type: ci
      spec:
        steps:
          - name: hello
            type: run
            spec:
              container:
                image: alpine:3
              script: |
                echo "Hello from Harness CI!"
                sleep 10
                echo "Done."
```

### Run it

1. In Harness UI → **Pipelines → New Pipeline**
2. Set _YAML Path_ = `.harness/pipeline-hello.yaml`
3. **Save and Run**

> You’ll see a short-lived container run `echo`, sleep, then exit.
> Check **Repositories → Commits** to notice Harness auto-commits pipeline changes.

---

## Step 2 – Automatic Trigger + Branch Condition

### A) Create a trigger in the UI

1. Go to **Repository → Pipelines → Settings**
2. In the **Triggers** tab, click **New Trigger**
3. Choose **Branch Updated**
4. Save

This makes Harness listen for pushes on any branch.

### B) Restrict it to `develop` branch

Edit `pipeline-hello`:

```yaml
version: 1
kind: pipeline
spec:
  stages:
    - name: hello
      type: ci
      when: |
        build.event == "branch_updated" &&
        build.branch == "develop"
      spec:
        steps:
          - name: hello
            type: run
            spec:
              container:
                image: alpine:3
              script: |
                echo "Hello from develop branch!"
                sleep 10
                echo "Done."
```

### Test it

Checkout to the `develop` branch, add some words to the `README.md` file (or create it if it doesn't yet exist), commit and push.

You can do it in the VSCode UI

```bash
git checkout -b develop
echo "# trigger test" >> README.md
git add README.md
git commit -m "Trigger test on develop"
git push origin develop
```

You will be prompted for git credentials. In the harness UI there's a button to create those credentials. Store them in the browser.

A run should start automatically. You can observe it in the harness UI.
Pushes to other branches won’t pass the `when:` filter.

## Extra – Mini Exercises (Play Time)

- **Trigger detective:** push to another branch → confirm it doesn’t run.
- **Sleep edit:** change `sleep 10` → `20` and observe the container lifetime.
- **ASCII art:** add this script:

  ```yaml
  - |
    echo "  /\_/\"
    echo " ( o.o )"
    echo "  > ^ <"
  ```

> References  
> • [Triggers](https://developer.harness.io/docs/open-source/pipelines/triggers)  
> • [Expressions](https://developer.harness.io/docs/open-source/pipelines/expressions)  
> • [Conditions](https://developer.harness.io/docs/open-source/pipelines/conditions)
