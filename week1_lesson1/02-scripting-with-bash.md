## SCRIPTING: What is it?

Let's run the explainer_script.sh to find out.

How to Use the Script:

1. Make the Script Executable: Open a terminal and navigate to the directory where you saved the script. Run the following command to make the script executable:

```sh
chmod +x explainer_script.sh
```

2. Run the script: Execute the script by running

```sh
./explainer_script.sh
```

Look at the contents of the explainer_script.sh and you'll see that it's exactly what you saw in your terminal after executing the script.

Scripts come in many different forms. Natively, on our computers, we can use shell scripts to execute linux commands on the machine. However, scripting doesn't stop there. Scripts can be written as a set of instructions for a piece of software to follow to provide functionality that doesn't exist natively on the host machine.

## Create an SSH Key Pair with scripting

As we know from the primer course, whenever we want to pull or push code between our AWS workspace and our GitHub accounts, we have to enter our username and password to authenticate with Github. This is repititive. And as scripting can fix repition, let's use a script to create an SSH Key Pair on the workspace.

SSH key pairs have a secret key (we keep this on our machine and don't give it out to anyone) and a public key (we can give this to github). It's a bit like a lock and a key. One won't work without the other. We can use these keys to authenticate with github.

1. Execute the `setup_ssh.sh` script.

```sh
./setup_ssh.sh
```

This script does a few things for us. It will start the process of creating our key pair.

2. It will ask you for your email - it's just to "sign" the key, so it's not a problem if it's not your actual email address.

3. Next, it will ask for a passphrase: leave this blank (just press return).

4. It will ask you to confirm the passphrase (again, leave it blank and just hit return).

5. It'll ask for a file to save the keys in. Again, hit return and it'll create them in the default location (~/.ssh)

6. The script will then install some software on the machine called xclip. This is basically just a tool we can use to copy files to the clipboard.

7. The script uses the newly installed software to copy the public key to the clipboard.

8. Go to your general assembly github account. Click the user menu in the top right and go to settings. Select the `SSH and GPG keys` from the left hand menu and then click the green button that says `New SSH key`. Give it a title such as "AWS Workspace" and then simply paste into the box for the key. Save it.

9. You're now ready to start using SSH keys to authenticate with Github! No more having to enter your username and password!
