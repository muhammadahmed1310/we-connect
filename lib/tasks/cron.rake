namespace :cron do

  desc 'Hourly cron job to backup the production database'
  task hourly: :environment do
    puts "#{Time.now.strftime('%Y-%m-%d %H:%M')} Running hourly cron job on #{Rails.env}"

    if Rails.env == 'production'
      Rake::Task['db:backup'].invoke
    end

  end

  desc 'Daily cron job to restore the production database to staging and clean up old backups'
  task daily: :environment do

    # Only run restore on staging
    if Rails.env == 'staging'
      puts "#{Time.now.strftime('%Y-%m-%d %H:%M')} Running daily cron job on #{Rails.env}"
      Rake::Task['db:restore'].invoke
    elsif Rails.env == 'production'
      puts "#{Time.now.strftime('%Y-%m-%d %H:%M')} Running daily cron job on #{Rails.env}"
      Rake::Task['db:backups_clean'].invoke
    end

  end

end
