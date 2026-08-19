# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.19.1'
require 'dotenv'
Dotenv.load
set :application, 'we-connect'
set :repo_url, 'https://github.com/muhammadahmed1310/we-connect.git'
set :git_http_username, ENV['GIT_HTTP_USERNAME']
set :git_http_password, ENV['GIT_HTTP_PASSWORD']

set :branch, 'main'

set :deploy_to, '/var/www/we-connect'

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/assets', 'public/system',
       'storage'

set :local_user, -> { 'ubuntu' }
set :ssh_options, { keys: %w[~/.ssh/we_connect_key] }

set :keep_releases, 5

# Tag build disabled for recovery deploy — re-enable after site is back up.
# namespace :deploy do
#   before :starting, :tag_build do
#     run_locally do
#       with rails_env: :development do
#         rake 'builds:tag_build'
#       end
#     end
#   end
# end

namespace :deploy do
  after :updated, "deploy:compile_assets"
end
