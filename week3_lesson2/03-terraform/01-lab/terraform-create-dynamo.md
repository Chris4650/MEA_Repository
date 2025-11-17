# Getting Started with Terraform

- [Terraform Lab](#terraform-lab)
  - [Logging into AWS](#logging-into-aws-sso)
  - [Creating the Terraform Manifest](#creating-the-terraform-manifest)
    - [Initializing Terraform](#initializing-terraform)
    - [Practicing Plan and Apply](#practicing-plan-and-apply)
    - [Adding the Resource Blocks](#adding-the-resource-blocks)

This lab introduces you to Terraform, a common tool for automation and infrastructure-as-code.

## Installing Terraform

Terraform can run on Linux, Windows, or macOS. Instructions for installing Terraform are available at https://developer.hashicorp.com/terraform/downloads.

For your Amazon Workspace VM, the ansible script we ran in the previous session installed terraform for
you. To confirm that you have terraform installed, you can run:

```bash
terraform -v
```

The output should be similar to:

```bash
Terraform v1.8.5
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v4.67.0
+ provider registry.terraform.io/hashicorp/random v3.6.2
```

There are basic steps you take each time you are working with a terraform template. In this lab, you will practice getting started with terraform with the basic steps. You will create an DynamoDB instance using terraform.

### Logging into AWS (with Whizlabs Custom Sandbox Credentials)

```bash
aws configure
```

**Note**: Just hit Enter (leave "NONE") for the default region name and default output format prompts.

First things first. Since you will be connecting to AWS from the CLI, you need to get your credentials setup before you can do that.

In this lab, you setup your AWS credentials but the credentials do expire. To start the lab, authenticate to your AWS CLI by typing the command `aws configure` and following the prompts. You'll find the access keys you need in your Whizlabs Custom Sandbox.

**_Log in to whizlabs from your AWS workspace - the access keys are very long, so you'll want to copy/paste them from the browser to the workspace terminal. Trying to type them out will almost certainly end in typos and you'll have to repeat this step._**

### Logging into AWS Console

In Whizlabs click on "Open Console" and fill it with your credentials.

Navigate to the DynamoDB service and click on "Tables" in the left-hand menu. You should see no tables created yet.

### Creating the Terraform Manifest

Here, we are going to create a manifest file to help us create a DynamoDB. Follow the steps below to do that:

1. Create a new directory to store your Terraform manifest in.

   ```bash
   cd ~/Desktop
   mkdir terraform-lab-01
   cd terraform-lab-01
   ```

2. In that directory, create a new file called `lab.tf` and open its folder in VS Code

   ```bash
   touch lab.tf
   code .
   ```

3. Download the Terraform VSCode extension (from Anton Kulikov)

4. You'll want to create the following blocks in the Terraform manifest:
   - A `terraform` with an AWS required provider
   - A `provider` block specifying the AWS region you want to deploy in (e.g., `us-east-1` which is in Northern Virginia)

Copy and paste the following information inside `lab.tf` file to create the `terraform` and `provider` blocks:

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

5. Save the file

6. #### Step 1: Initializing Terraform

Open a terminal (separate or in VSCode) in the directory that has your `lab.tf` file and run the command:

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

If you didn't get a similar output, speak with the instructor for help. It's important you get this step working, otherwise nothing else you do will work.

#### Step 2: Terrafrom Plan

Once you've initialized your Terraform directory, you can start to add resource blocks, plan, and apply them. Try the following:

Step 1: Open your `lab.tf` and at the end of the file, copy and paste the following resource blocks in your manifest:

```hcl
resource "aws_dynamodb_table" "accounts" {
  name         = "Accounts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "AccountsTable"
  }
}
```

Step 2. Run `terraform plan`

- If you get an error, run `terraform init` then `terraform plan` again

```bash
terraform plan
```

You should see output of Terraform telling you what it _would_ do

#### Step 3: Terraform Apply

1.  Run `terraform apply` to apply those changes. Enter `yes` when prompted.

```bash
terraform apply
```

2. Run `terraform plan` again. You should see it tell you there is nothing it needs to do

```bash
terraform plan
```

3. In the AWS console, you should now see a new DynamoDB table created named `Accounts` (if you refreshed the page).

#### Try yourself

Create an additional DynamoDB table named `mortgage-products` with a hash key of `product-id` (string type) and tags with Name = `MortgageProducts`. Follow the same steps as above to add the resource block, plan, and apply it.

#### Step 4: Terraform Destroy

It's a good practice to clean up after your exercises so let's destroy the DynamoDB we just created.

Run `terraform destroy` to destroy the infrastructure you made (enter `yes` when prompted) or run:

```bash
terraform destroy -auto-approve
```

Visit the DynamoDB service in the AWS management console and verify that the database was deleted.

Congratulations, you just used terraform to create a DynamoDB instance on the AWS cloud. Don't forget the steps, `terraform init, terraform plan, terraform apply, and terraform destroy` (when no longer needed)
