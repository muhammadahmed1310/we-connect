set :output, File.join(Whenever.path, "log", "cron.log")
env :PATH, '/usr/local/bin:/usr/sbin:/usr/bin'
env :GEM_HOME, '/var/www/we-connect/shared/bundle/ruby/3.2.0'

# every 1.hour do
#   rake "cron:hourly"
# end
#
# every 1.day, at: '4:30 am'  do
#   rake "cron:daily"
# end
every 1.day, at: '2:00 am' do
  rake "versions:cleanup"
end
