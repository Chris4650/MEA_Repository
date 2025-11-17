# ![](https://ga-dash.s3.amazonaws.com/production/assets/logo-9f88ae6c9c3871690e33280fcf557f33.png) Ansible

| Title   | Type | Duration | Author    |
| ------- | ---- | -------- | --------- |
| Ansible | Lab  | 0:30     | Ben Piper |

- [Install Ansible](#install-ansible)
- [Install the Visual Studio Code Ansible extension from Red Hat](#install-the-visual-studio-code-ansible-extension-from-red-hat)
- [Review the playbook](#review-the-playbook)
- [Run the playbook](#run-the-playbook)
- [Stretch goal](#stretch-goal)

The goal of this lab is to learn how to use Ansible to install some utilities we'll be using in upcoming labs. Some of these utilities include:

- The AWS CLI
- Terraform

## Pull your fork of the `LBG-MEA-EXPLORE` repo

```bash
git clone git@git.generalassemb.ly:<your-username/LBG-MEA-EXPLORE.git
cd LBG-MEA-EXPLORE
```

We will work in the `week3_lesson2/02-ansible` directory.

## Install Ansible

Open up your terminal and type the following:

```bash
sudo amazon-linux-extras install epel -y
sudo yum -y install ansible
```

Verify the version by typing:

```bash
ansible --version
```

Ensure the version is `2.9.23` or later.

## Install the Visual Studio Code Ansible extension from Red Hat

Open up VS Code.

In VS Code, go to the Extensions view by clicking on the Extensions icon in the Activity Bar on the side of the window and search for `Ansible`. Install the top result (by Red Hat).

**Alternative**: In VS Code, type Ctrl+P (PS) or Command+P (Mac), and enter `ext install redhat.ansible`.

Close VS Code and reopen it.

## Review the playbook

Load [playbook.yml](playbook.yml) in VS Code.

The playbook installs several tools you'll use throughout the labs, including:

- The AWS command line interface (CLI)
- Terraform

Refer to the [syntax documentation](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html#playbook-syntax) and the [plugin documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html#plugins-in-ansible-builtin) to understand what the playbook will do when executed.

## Run the playbook

You must run this playbook from the repo that you cloned earlier so ensure you are inside `week3_lesson2/02-ansible` directory:

```bash
cd <path to the week3_lesson2/02-ansible directory>

ansible-playbook playbook.yml
```

### Idempotency

Re-run the playbook again:

```bash
ansible-playbook playbook.yml
```

- **Question**: Why did two tasks report "changed" in the second run?

## Modify the playbook (Idempotency demo)

Open up `playbook.yml` in VS Code.

Add a task that installs a few more helper tools using the `ansible.builtin.package` module:

```yaml
- name: Install extra tools
  ansible.builtin.package:
    name:
      - git
      - jq
      - htop
    state: present
  become: true
```

Save and run the playbook again:

```bash
ansible-playbook playbook.yml
```

Observe that Ansible only installs the missing packages and does not reinstall the ones that are already present, demonstrating **idempotency**.

- **Question**: Why is this new task "ok" (and not "changed") on the first run?

## Verify installation

Append one last verification task near the end of your `playbook.yml` so Ansible prints the Terraform version that was installed:

```yaml
- name: Display Terraform version
  ansible.builtin.command: terraform --version
  register: terraform_version
- debug:
    var: terraform_version.stdout
```

The `register` keyword captures the command output, and the `debug` task echoes it to the play output. Save the file and rerun `ansible-playbook playbook.yml`.
You should see the Terraform version in the results.

## Stretch goal

Feel free to extend it further (for example: manage config files or add more utilities), then rerun the playbook with `ansible-playbook playbook.yml`.
