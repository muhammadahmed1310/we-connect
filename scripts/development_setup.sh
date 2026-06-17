## Development MacOS setup

# Install [Homebrew](https://brew.sh/)
# Install [rvm](https://rvm.io/)
# Install Ruby 3.2.4

      rvm install 3.2.4

# Install Rubymine

      brew install --cask rubymine

# Install mysql (keep to version 8.0 to match the server)

      brew install mysql@8.0

# Clone the repository

      git clone ...

# Change to the project directory and configure the bundler

       cd we
       bundle config --local build.mysql2 "--with-opt-dir="$(brew --prefix zstd)""

# Install the gems

       bundle install

# Get the private key from google cloud secrets manager
    # Save it in ~/.ssh/we_ssh_key.pem
    # Change the permissions on the file

           chmod 600 ~/.ssh/we_ssh_key.pem

## Mysql permissions

      CREATE USER 'admin'@'%' IDENTIFIED BY 'redbluepink';
      GRANT ALL PRIVILEGES ON #.# TO 'admin'@'%' WITH GRANT OPTION;
      FLUSH PRIVILEGES;

