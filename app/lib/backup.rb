# Currently this does a mysql only backup using mysqldump.
# The advantage is that this is cloud independent.
# rubocop:disable Layout/LineLength
class Backup

  # For the moment all backups are stored in a single bucket
  BUCKET = 'org.womenemerging.backup'

  # Backup the current active database and upload to S3
  #
  # Backups are named with the following format:
  # - Rails environment
  # - Date and time of backup
  # - .sql.gz (for gzip compressed files)
  def self.backup(use_sql: true)
    file_name = "#{Rails.env}-#{Time.zone.now.strftime('%Y%m%d-%H%M')}".to_s
    file_name << '.sql' if use_sql
    puts "#{Time.zone.now.strftime('%Y-%m-%d %H:%M')} Backing up #{Rails.env} to #{file_name}"
    local_path = Rails.root.join("#{_backup_path}/#{file_name}").to_s
    dc = _data_config[Rails.env]
    if dc['adapter'] == 'sqlite3'
      if use_sql
        _sqlite_dump(local_path)
      else
        _sqlite_backup(local_path)
      end
    else
      _mysql_backup(local_path)
    end
    AwsAccess.write_to_storage("#{file_name}.gz", "#{local_path}.gz", BUCKET)
  end

  # Restore the database from a backup in AWS.
  # We allow the user to specify the environment so we can restore the production database to staging or development.
  def self.restore(s3_name = nil, env = Rails.env)
    s3_name ||= list_backups(env).last
    puts "#{Time.zone.now.strftime('%Y-%m-%d %H:%M')} Restoring #{Rails.env} from #{s3_name}"
    if s3_name.blank?
      puts 'No backups found'
      return
    end
    puts "Restoring #{s3_name}"
    local_path = Rails.root.join("#{_backup_path}/#{s3_name}").to_s
    AwsAccess.read_from_storage(local_path, s3_name, BUCKET)
    dc = _data_config[Rails.env]
    if dc['adapter'] == 'sqlite3'
      if s3_name.end_with? '.sql.gz'
        _sqlite_restore_dump(local_path)
      else
        _sqlite_restore(local_path)
      end
    else
      _mysql_restore(local_path)
    end
  end

  def self.clean_up(env = Rails.env, days_to_keep = 7)
    _backups_to_remove(env, days_to_keep).each do |s3_name|
      puts "#{Time.zone.now.strftime('%Y-%m-%d %H:%M')} Removing #{s3_name}"
      AwsAccess.delete_from_storage(s3_name, BUCKET)
    end
  end

  # List all backups in the S3 bucket for a given rails environment
  def self.list_backups(env = Rails.env)
    puts "#{Time.zone.now.strftime('%Y-%m-%d %H:%M')} Listing backups for #{env}"
    AwsAccess._aws_config
    AwsAccess.list_from_storage(BUCKET, env)
  end

  # List all backups in the S3 bucket for a given rails environment that should be removed
  def self.list_backups_to_remove(env = Rails.env, days_to_keep = 7)
    _backups_to_remove(env, days_to_keep)
  end

  # Get the names of any backups that should be removed from S3
  #
  # - env: Rails environment to check
  # - days_to_keep: Number of days to keep backups for (default: 7) The first backup in each month is also always kept.
  def self._backups_to_remove(env = Rails.env, days_to_keep = 7)
    backups = _backups_not_last_days(list_backups(env), days_to_keep)
    _backups_except_first(backups)
  end

  def self._data_config
    YAML.load_file(Rails.root.join('config/database.yml'))
  end

  def self._backups_not_last_days(list, days_to_keep = 7)
    ld = (days_to_keep - 1).downto(0).collect { |day| Time.now.days_ago(day).strftime('%Y%m%d') }
    list.reject { |f| ld.include?(f[-20..-13]) }
  end

  def self._backups_except_first(list)
    dates = {}
    list.each do |f|
      d = f[-20..-13]
      dates[d[0..5]] ||= []
      dates[d[0..5]] << d[6..8]
    end
    dates.each_key do |k|
      dates[k].sort! { |x, y| x <=> y }
      dates[k] = dates[k].drop(1)
    end
    all_dates = dates.keys.collect { |k| dates[k].collect { |d| "#{k}#{d}" } }.flatten
    list.select { |f| all_dates.include? f[-20..-13] }
  end

  def self._backup_path
    Rails.root.join('log')
  end

  def self._mysql_backup(local_path)
    dc = _data_config[Rails.env]
    `mysqldump --opt --skip-lock-tables -h#{dc['host']} -u#{dc['username']} -p#{dc['password']} #{dc['database']} > #{local_path}`
    `gzip -f #{local_path}`
  end

  def self._mysql_restore(local_path)
    `gzip -df #{local_path}`
    local_path.gsub!('.gz', '')
    dc = _data_config[Rails.env]
    `mysql -h#{dc['host']} -u#{dc['username']} -p#{dc['password']} #{dc['database']} < #{local_path}`
  end

  # Backup makes a simple copy of the db
  def self._sqlite_backup(local_path)
    dc = _data_config[Rails.env]
    `sqlite3 #{dc['database']} ".backup #{local_path}"`
    `gzip -f #{local_path}`
  end

  def self._sqlite_restore(local_path)
    `gzip -df #{local_path}`
    local_path.gsub!('.gz', '')
    dc = _data_config[Rails.env]
    `cp  #{local_path} #{dc['database']}`
  end

  # Dump creates insert statements
  def self._sqlite_dump(local_path)
    dc = _data_config[Rails.env]
    puts `sqlite3 #{dc['database']} .dump > #{local_path}`
    puts `gzip -f #{local_path}`
  end

  def self._sqlite_restore_dump(local_path)
    `gzip -df #{local_path}`
    local_path.gsub!('.gz', '')
    dc = _data_config[Rails.env]
    puts "sqlite3 #{dc['database']} < #{local_path}"
    puts `sqlite3 #{dc['database']} < #{local_path}`
  end

end
# rubocop:enable Layout/LineLength
