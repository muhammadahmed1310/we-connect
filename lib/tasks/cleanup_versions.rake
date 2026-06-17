namespace :versions do
  desc "Delete PaperTrail logs older than 30 days"
  task cleanup: :environment do
    count = PaperTrail::Version.where('created_at < ?', 30.days.ago).delete_all
    puts "Deleted #{count} logs older than 30 days"
  end
end
