namespace :db do

  desc 'Clean up old backups on AWS for the current environment. Usage: rake backup:clean [DAYS_TO_KEEP=7]'
  task backups_clean: :environment do
    days = ENV['DAYS_TO_KEEP'] || '7'
    Backup.clean_up(Rails.env, days.to_i)
    LogRecord.create(datetime: Time.now,
                     event_type: 'backups',
                     message: 'Cleaned up old backups',
                     rails_env: Rails.env)
  end

  desc 'Restore a backup from GPC. Usage: rake backup:restore [RESTORE_FROM=production] [RESTORE_FILE=<s3 filename>]'
  task restore: :environment do
    # Drop and create the db because mysql doesn't get rid of old tables when restoring a backup
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Backup.restore(ENV['RESTORE_FROM'] || 'production', ENV['RESTORE_FILE'])
    Rake::Task['db:migrate'].invoke
    Rake::Task['fields:industry'].invoke
    LogRecord.create(datetime: Time.now,
                     event_type: 'backups',
                     message: 'Restore complete',
                     rails_env: Rails.env)
  end

  desc 'Backup the current environment and upload to GPC bucket'
  task backup: :environment do
    Backup.backup
    LogRecord.create(datetime: Time.now,
                     event_type: 'backups',
                     message: 'Backup complete',
                     rails_env: Rails.env)
  end

  desc 'List all the backups on GPC for an environment. Usage: rake backup:list [LIST_ENV=<Rails.env>]'
  task backups_list: :environment do
    puts Backup.list_backups(ENV['LIST_ENV'] || Rails.env)
  end

  desc 'Rebuild everything from scratch. Usage: rake db:rebuild'
  task rebuild: :environment do
    if Rails.env != 'production'
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['db:seed'].invoke
      Rake::Task['fields:industry'].invoke
    else
      puts 'Not allowed in production.'
    end
  end

end
