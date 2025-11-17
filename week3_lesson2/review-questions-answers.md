📝 Possible Answers: DevOps Tools Discussion

These notes are for facilitators. Encourage groups to share their own reasoning before revealing any of this material.

⸻

**Q1. What does each tool do in plain words?**
- Terraform: creates the cloud pieces you need (servers, databases, networks) from a text file so you can repeat the setup.
- Ansible: logs into those servers and installs or configures software, making sure each machine ends up in the same state.
- Docker: bundles an app plus its libraries into a container image so it runs the same on any machine.
- Kubernetes: takes those containers, spreads them across many machines, keeps them healthy, and scales them when needed.

⸻

**Q2. Who talks to whom in a Spotify-like music app launch?**
- Order for a Spotify-like music app: Terraform creates the VPC, EC2 nodes, and RDS database → Ansible logs into the nodes to install Docker and any runtime dependencies → Docker supplies the playlist service image → Kubernetes pulls that image onto the nodes and exposes it to users.
- Each handoff passes along something tangible: Terraform hands running hosts/IPs to Ansible; Ansible delivers configured nodes ready for containers; Docker hands the image tag to Kubernetes; Kubernetes presents a service endpoint to listeners.

⸻

**Q3. What happens when the app suddenly goes viral?**
- Kubernetes notices load (via metrics) and spins up more pods, pulling extra container copies as needed.
- Docker’s role is providing the same image for every new pod, so scaling keeps behaviour consistent.
- Terraform already defined the cluster size and node autoscaling groups that give Kubernetes room to grow.
- Ansible may have prepared monitoring or tuned configs, but during the spike it mainly stays out of the way.

⸻

**Q4. How do you get Docker onto a brand-new server?**
- Terraform’s job is to create the server (EC2, firewall rules, IAM roles). It rarely installs software itself.
- After the server exists, Ansible connects over SSH, installs Docker packages, adds the service to systemd, and can tweak configs (like allowing the Kubernetes agent to talk to Docker).
- Together they stay repeatable: rerunning Terraform keeps the server in place; rerunning Ansible keeps Docker configured the same way on every machine.

⸻

**Q5. How do you give every environment the same setup?**
- Terraform provisions comparable stacks (networking, compute) for dev, staging, prod from the same codebase.
- Ansible applies identical configuration (packages, users, app settings) so servers behave the same.
- Docker guarantees the application runtime is identical across environments because each runs the same container image.
- Kubernetes deploys those images with environment-specific config maps/secrets, but the deployment definitions stay mostly shared.

⸻

**Q6. How would you add a new lyrics feature as its own service?**
- Terraform: create any needed infrastructure (service account, database/table, queue) and adjust networking so the Lyrics Service can talk to others.
- Ansible: configure the new service host or update existing nodes with required dependencies/environment files.
- Docker: build the Lyrics Service into its own container image so it can be deployed consistently.
- Kubernetes: define a new Deployment/Service for the Lyrics Service, wire it into the cluster (e.g., via internal service name or API gateway), and scale it as demand grows.
