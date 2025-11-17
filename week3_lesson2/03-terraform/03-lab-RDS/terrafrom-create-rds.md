# Terraform Hands-on Practice

In the previous lab, you learned the fundamentals of using Terraform and you created an S3 bucket with terraform. Here we will create a few more AWS resources just to give you some more practice.

In this lab we will create an **AWS RDS** service. RDS is the relational database service from AWS. We are yet to dicsuss it but we will disscuss it next week.

### Creating the Terraform Manifest

Here, we are going to create a manifest file to help us create an RDS service on AWS. Follow the steps below to do that:

1. Create a new directory to store your Terraform manifest in.

```bash
cd ~/Desktop
mkdir terraform-lab-02
cd terraform-lab-02
```

2. In that directory, open a new file in VS Code called rds.tf

```bash
touch rds.tf
code .
```

3. The following must always be at the begining of your teraform templates for AWS.

Copy and paste the following information inside `rds.tf` file to create the `terraform` and `provider` blocks:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}
```

4. Save the file.

5. #### Step 1: Initializing Terraform

Go back to your terminal in the directory that has your `rds.tf` file and run the command:

```bash
terraform init
```

The output will be similar to this:

```text
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 4.16"...
- Installing hashicorp/aws v4.17.0...
- Installed hashicorp/aws v4.17.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

If you didn't get a similar output, speak with the instructore for help. It's important you get this step working, otherwise nothing else you do will work.

#### Step 2: Terrafrom Plan

Once you've initialized your Terraform directory, you can start to add resource blocks, plan, and apply them. Try the following:

Step 1: Open your created `rds.tf` and at the end of the file, copy and paste the following resource blocks in your manifest:

```hcl
resource "aws_rds_cluster" "modern-engineering-aurora-postgressql-cluster" {
  cluster_identifier      = "modern-engineering-aurora-postgresql-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "11.9"
  availability_zones      = ["us-east-2a", "us-east-2b", "us-east-2c"]
  master_username         = "myusername"
  master_password         = "The.5ecret?P4ssw0rd"
  database_name           = "mydatabase"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  apply_immediately       = true
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "modern-engineering-aurora-postgressql-instances" {
  count              = 2
  identifier         = "modern-engineering-aurora-postgresql-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.modern-engineering-aurora-postgressql-cluster.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.modern-engineering-aurora-postgressql-cluster.engine
  engine_version     = aws_rds_cluster.modern-engineering-aurora-postgressql-cluster.engine_version
}
```

Step 2. Run `terraform plan`

- If you get an error, run `terraform init` then `terraform plan` again

You should see output of Terraform telling you what it _would_ do

#### Step 3: Terrafrom Apply

1.  Run `terraform apply` to apply those changes. Enter `yes` when prompted.

2.  Wait for about 15 minutes

3.  Visit the RDS service in the AWS management console and verify that RDS was created

#### Step 3: Terrafrom Destroy

It's a good practice to cleap up after your exercises so let's destroy the RDS service we just created.

Run `terraform destroy --auto-approve` to destroy the infrastructure you made

Wait for about 15 minutes

Visit the RDS service in the AWS management console and verify that the RDS service was deleted.

Congratulations, you just used terraform to create an RDS bucket on the AWS cloud. Don't forget the steps, `terraform init, terraform plan, terraform apply, and terraform destroy` (when no longer needed)
