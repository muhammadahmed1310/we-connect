#!/bin/bash

# Define variables
SECRET_NAME="ubuntu_ssh_key"
KEY_FILE="$HOME/.ssh/we_ssh_key"
INSTANCE_NAME="instance-1"
ZONE="us-central1-f"
PUBLIC_IP="34.170.89.124"  # Replace with the actual public IP of your instance
PROJECT_ID="wehub-430308"  # Replace with your Google Cloud project ID

# Ensure the .ssh directory exists
mkdir -p "$HOME/.ssh"

# Fetch the SSH private key from Google Cloud Secret Manager and save it to the custom key file
if gcloud secrets versions access latest --project="$PROJECT_ID" --secret="$SECRET_NAME" > "$KEY_FILE"; then
  echo "Key file successfully created at $KEY_FILE"
else
  echo "Failed to fetch the key from Secret Manager or write to $KEY_FILE" >&2
  exit 1
fi


# Clean up the key file to remove any extraneous characters or newlines
perl -i -pe 's/[^-]*-----END OPENSSH PRIVATE KEY-----/-----END OPENSSH PRIVATE KEY-----/s' "$KEY_FILE"
perl -i -pe '$_ .= "\n" unless /\n\z/' "$KEY_FILE"

chmod 600 "$KEY_FILE"

# Check if the private key is valid
if ! ssh-keygen -y -f "$KEY_FILE" > /dev/null 2>&1; then
  echo "The private key file is invalid. Please check the key file or regenerate the key."
  exit 1
fi

# Generate the public key if it doesn't exist
if [ ! -f "$KEY_FILE.pub" ]; then
  ssh-keygen -y -f "$KEY_FILE" > "$KEY_FILE.pub"
  echo "Public key generated at $KEY_FILE.pub"
else
  echo "Public key already exists at $KEY_FILE.pub"
fi

# Set appropriate permissions for the custom key file
chmod 600 "$KEY_FILE"
chmod 644 "$KEY_FILE.pub"

# Update SSH configuration
CONFIG_FILE="$HOME/.ssh/config"
if ! grep -q "Host instance-1" "$CONFIG_FILE"; then
  echo "Adding SSH configuration for instance-1"
  cat >> "$CONFIG_FILE" <<EOL
Host instance-1
  HostName $PUBLIC_IP
  User ubuntu
  IdentityFile $KEY_FILE
EOL
else
  echo "SSH configuration for instance-1 already exists"
fi

# Instructions for the user
echo "SSH key setup complete. You can now SSH into the instance using the following command:"

# SSH into the instance using gcloud and specify the user
echo "gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID --ssh-key-file=$KEY_FILE"

# Optionally, run the SSH command immediately after setup
echo "Attempting to connect to the instance..."

gcloud compute ssh ubuntu@$INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID --ssh-key-file=$KEY_FILE

