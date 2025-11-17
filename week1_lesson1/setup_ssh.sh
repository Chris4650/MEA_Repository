#!/bin/bash

# Prompt the user for their email address
read -p "Enter your email address for the SSH key: " email

# Generate a new SSH key using the provided email as a label
ssh-keygen -t ed25519 -C "$email"

# Navigate to the .ssh directory
cd ~/.ssh || { echo "Failed to navigate to ~/.ssh directory"; exit 1; }

# Create a config file if it doesn't exist
touch config

# And add the necessary configuration to the config file
echo "Updating the SSH config file..."
cat <<EOL > config
Host *
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
EOL

# Add the SSH key to the SSH agent
ssh-add ~/.ssh/id_ed25519

# Copy the public key to the clipboard based on the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  cat ~/.ssh/id_ed25519.pub | pbcopy
  echo "Public key copied to clipboard (macOS)."
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  if ! command -v xclip &> /dev/null; then
    echo "xclip is not installed. Installing xclip..."
    if command -v yum &> /dev/null; then
      sudo yum install -y xclip
    elif command -v apt-get &> /dev/null; then
      sudo apt-get update
      sudo apt-get install -y xclip
    else
      echo "Unsupported package manager. Please install xclip manually."
      exit 1
    fi
  fi
  cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard
  echo "Public key copied to clipboard (Linux)."
else
  echo "Unsupported OS. Please copy the public key manually."
  exit 1
fi

echo "SSH key setup is complete."