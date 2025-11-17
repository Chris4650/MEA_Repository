# ![](https://ga-dash.s3.amazonaws.com/production/assets/logo-9f88ae6c9c3871690e33280fcf557f33.png) Ansible VS Terraform

| Title               | Type    | Duration | Author       |
| ------------------- | ------- | -------- | ------------ |
| Ansible & Terraform | Lecture | 0:15     | Tristan Hall |

# Understanding Ansible and Terraform in Modern Software Engineering

## What is Ansible?

Ansible is a powerful tool used in modern software engineering to automate tasks that would otherwise be done manually, such as setting up servers, deploying applications, and managing configurations. It acts as a way to give clear, step-by-step instructions to your computers and cloud services so they know exactly how to set up and manage things without requiring you to do everything by hand.

## What is Terraform?

Terraform is another essential tool in modern software engineering, but it serves a different purpose than Ansible. Terraform is used to create and manage the underlying cloud infrastructure—things like servers, databases, and networks. It allows you to define this infrastructure as code, meaning you can write a script that describes the resources you need, and Terraform will automatically create and configure them in your cloud environment. While Terraform focuses on provisioning and managing infrastructure, Ansible is used for configuring and automating tasks on that infrastructure once it’s up and running.

## How is Ansible Used?

For example, if you create a SQL database on AWS using Terraform, you might need to set up tables and columns in that database. Instead of manually logging into the database to create these tables and columns, you can use Ansible to automate the process. With Ansible, you can write a script that tells the database exactly how to create the tables and columns you need, ensuring that everything is done correctly and consistently. This automation saves time and reduces the potential for errors, which is particularly valuable when working in cloud environments where speed and reliability are key.

## Terraform vs. Ansible

- **Terraform**: Terraform is used to create and manage the underlying cloud infrastructure, such as servers, networks, and databases. It's generally used as the tool to actually get the hardware you need.
- **Ansible**: Ansible is used to configure and automate tasks on the infrastructure created by Terraform, such as setting up software, configuring settings, and in this example, creating tables and columns in a database. It's the tool we use to configure the hardware that Terraform got.

Together, Terraform and Ansible provide a comprehensive solution for building and managing cloud environments efficiently.
