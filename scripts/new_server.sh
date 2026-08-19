# Ubuntu setup

# Create compute instance on GCP
#   * e2-medium (2 vCPUs, 4 GB memory)
#   * Boot disk: Ubuntu 24.04 LTS, 30 GB
#   * Allow HTTP and HTTPS traffic
#   * Allow traffic from anywhere
#   * Create in west2 region
#   * add our pem.key

# Create a database on Cloud SQL
#   * MySQL 8.0
#   * Enterprise (not Enterprise Plus)
#   * Preset development
#   * Set root password
#   * Create in west2 region
#   * 2 vCPUs, 8 GB memory
#   * 10 GB storage
#   * Public IP
#   * Add network- our instance's IP address (** need to change **)

# SSH into cloud instance

# Add authorized keys for user ubuntu -- not needed if using the pem key
#  get public and private keys from the secrets manager (we_ssh_key.pub and we_ssh_key.pem)
#  put the we_ssh_key.pem in your local .ssh directory

   sudo mkdir /home/ubuntu/.ssh
   sudo touch /home/ubuntu/.ssh/authorized_keys
   sudo chmod 600 /home/ubuntu/.ssh/authorized_keys
   sudo chown ubuntu:ubuntu /home/ubuntu/.ssh
   sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
   # upload the public key to the server
   sudo cat we_ssh_key_pub >> /home/ubuntu/.ssh/authorized_keys

# login as ubuntu user from your local machine
#   ssh -i ~/.ssh/we_ssh_key.pem ubuntu@connect.womenemerging.org

# Install some stuff
   sudo apt-get update
   sudo apt-get install -y ruby build-essential patch ruby-full zlib1g-dev liblzma-dev
   sudo apt-get install -y nginx libvips mysql-client libmysqlclient-dev imagemagick nodejs
   sudo apt-get install -y cron git libyaml-dev policykit-1

# Install bundler
   sudo gem install bundler

# Make a directory for the app
   sudo mkdir -p /var/www/we-connect
   sudo chown ubuntu:ubuntu /var/www/we-connect

# Add acme certbot
  sudo apt update
  sudo apt install -y socat ca-certificates
  curl https://get.acme.sh | sh -s email=admin@womenemerging.org
  sudo mkdir /var/www/certbot
  sudo chown -R ubuntu:ubuntu /var/www/certbot

# Do first deploy (will fail)
#    From your local machine
#    cap staging deploy
#    cap staging puma:install
#    cap staging puma:enable
#    You may need to open up the network to the database

# Setup default nginx site
  sudo rm /etc/nginx/sites-enabled/default
  sudo cp /var/www/we-connect/current/config/nginx80.conf /etc/nginx/sites-available/we
  sudo ln -s /etc/nginx/sites-available/we /etc/nginx/sites-enabled/we
  sudo systemctl restart nginx

# Issue initial certificate
  acme.sh --issue -d connect.womenemerging.org --server letsencrypt --webroot /var/www/certbot

# Copy the secure nginx config file to the sites enabled directory
  sudo cp /var/www/we-connect/current/config/nginx.conf /etc/nginx/sites-available/we
  sudo systemctl restart nginx


# copy the alias.sh file to the server
  cp /var/www/we-connect/current/scripts/bash_aliases.sh /home/ubuntu/.bash_aliases

