# Combined Lab: Terraform + Ansible

## Overview

In this exercise you’ll connect two automation tools: **Terraform** and **Ansible**.

- **Terraform** builds infrastructure (the “house”).
- **Ansible** configures or interacts with that infrastructure (the “furniture”).

You’ll:

1. Use **Ansible** to check whether two DynamoDB tables exist (and see the initial failure).
2. Use **Terraform** to create the tables.
3. Re-run **Ansible** and notice the `MortgageProducts` table still has an issue.
4. Update Terraform to fix the schema mismatch and rerun Ansible successfully.
5. Optionally, use Ansible to insert a sample record into each table.

---

## Learning Objectives

By the end of this lab, you will be able to:

- Understand the relationship between Terraform and Ansible.
- Run AWS CLI commands from Ansible tasks.
- Use Ansible loops and conditionals.
- See how idempotence and task order work in practice.

---

## Part 1: Verify Tables with Ansible

1. In your workspace, create a new folder called `terraform-ansible-lab`.

   ```bash
   mkdir ~/Desktop/terraform-ansible-lab
   cd ~/Desktop/terraform-ansible-lab
   ```

2. Create a file called `verify_dynamo.yml` and open it in VS Code.

   ```bash
   touch verify_dynamo.yml
   code .
   ```

3. Paste in the following playbook:

   ```yaml
   ---
   - hosts: localhost
     connection: local
     vars:
       region: us-east-1
       tables:
         - Accounts
         - MortgageProducts

     tasks:
       - name: Verify that each DynamoDB table exists
         ansible.builtin.command: >
           aws dynamodb describe-table
           --table-name {{ item }}
           --region {{ region }}
         register: table_check
         loop: "{{ tables }}"
         ignore_errors: true

       - name: Display verification results
         ansible.builtin.debug:
           msg: |
             Table {{ item.item }} -> {{ 'Found' if item.rc == 0 else 'Missing' }}
         loop: "{{ table_check.results }}"

       - name: Insert sample item into each existing table
         ansible.builtin.command: >
           aws dynamodb put-item
           --table-name {{ item.item }}
           --item '{"id": {"S": "123"}, "name": {"S": "Test Entry"}}'
           --region {{ region }}
         when: item.rc == 0
         loop: "{{ table_check.results }}"
   ```

4. Run the playbook:

   ```bash
   ansible-playbook verify_dynamo.yml
   ```

### What you should observe

- The first task (`describe-table`) runs for each table name.
- The playbook prints messages like:

  ```
  Table Accounts -> Missing
  Table MortgageProducts -> Missing
  ```

- The “insert item” step will be skipped (because the tables don’t exist yet).

This is expected.

---

## Part 2: Create Tables with Terraform

1. Navigate back to your Terraform lab folder from the previous exercise (or create a new one).
2. In your `lab.tf` file, add **both** DynamoDB table resources:

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

   resource "aws_dynamodb_table" "mortgage_products" {
     name         = "MortgageProducts"
     billing_mode = "PAY_PER_REQUEST"
     hash_key     = "product-id"

     attribute {
       name = "product-id"
       type = "S"
     }

     tags = {
       Name = "MortgageProducts"
     }
   }
   ```

3. Run the Terraform workflow:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

   Confirm with `yes` when prompted.

---

## Part 3: Re-run Ansible

Go back to your Ansible folder and run again:

```bash
ansible-playbook verify_dynamo.yml
```

This time both tables are discovered, but the final task fails for `MortgageProducts`. Pause and inspect the error message—what does it tell you about the key Ansible is sending compared with what the table expects?

> **Curious minds:** Take a moment to experiment. Can you tweak the playbook to send a different attribute? Or is there something in Terraform that should change instead?

> **Try it yourself:** Before reading ahead, jot down what you think needs to change. How could you adjust either the playbook or the Terraform code to make the keys line up?

> **Checkpoint:** What key name does the error mention? Why is Ansible sending a different key?

---

## Part 4: Fix the key mismatch

Before peeking, outline your own fix. Once you have a plan:

1. Open your Terraform configuration and update the `aws_dynamodb_table.mortgage_products` resource so the hash key (and attribute block) use `id` instead of `product-id`.
2. Run `terraform apply` again to update the table schema.
3. Re-run `ansible-playbook verify_dynamo.yml`. The insert task should now succeed for both tables, and each will receive the sample record.

---

## Part 5: Verify in AWS Console

- Open the DynamoDB service in the AWS console.
- Select each table → **Items** tab → you should see:

  ```json
  {
    "id": "123",
    "name": "Test Entry"
  }
  ```

---

## Part 6: Clean Up

Always destroy temporary infrastructure when done:

```bash
terraform destroy -auto-approve
```

Then delete any sample data if you want a fresh start next time.

---

## Reflection Questions

1. Why did the first Ansible run fail?
2. How did Terraform make it succeed the second time?
3. What role does the `when: item.rc == 0` condition play?
4. How does Ansible’s loop differ from a typical programming loop?
5. What’s one real-world situation where you’d combine Terraform + Ansible?

---

## Takeaway

- **Terraform** creates cloud resources.
- **Ansible** configures or uses them afterward.
- Running Ansible first shows that nothing exists yet — illustrating declarative vs. imperative automation.
- Running it again after Terraform demonstrates **idempotence** and how the two tools work together.

---

### Hint (peek only if you’re stuck)

The mismatch lives in the DynamoDB table schema: Terraform sets the hash key to `product-id`, while Ansible’s insert uses `id`. Update the Terraform resource so both tools refer to the same key name, then reapply and rerun the playbook.
