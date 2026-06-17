
# Access GPC buckets
class GpcAccess

  def self._gpc_client
    @gc = Google::Cloud.new('WEHub',
                            './config/credentials/xxx.json')
  end

  def self.list_from_storage(bucket_name)
    bucket = bucket_from_name(bucket_name)
    bucket.files.collect { |f| f.name }
  end

  def self.write_to_storage(name, local_path, bucket_name)
    bucket = bucket_from_name(bucket_name)
    bucket.create_file local_path, name
  end

  def self.read_from_storage(local_path, name, bucket_name)
    bucket = bucket_from_name(bucket_name)
    file = bucket.file(name)
    local_file = File.join(local_path, name)
    file.download local_file
    local_file
  end

  def self.delete_from_storage(name, bucket_name)
    bucket = bucket_from_name(bucket_name)
    file = bucket.file(name)
    file.delete
  end

  protected

  def bucket_from_name(name)
    storage = @gc.storage
    storage.bucket name
  end

end
