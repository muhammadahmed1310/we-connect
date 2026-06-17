require 'net/http'
require 'uri'
require 'json'

class AzureOauthSmtp
  TOKEN_URL = "https://login.microsoftonline.com/#{ENV['AZURE_TENANT_ID']}/v2.0/token"

  def self.fetch_token
    uri = URI(TOKEN_URL)
    res = Net::HTTP.post_form(uri,
                              client_id: ENV['AZURE_CLIENT_ID'],
                              client_secret: ENV['AZURE_CLIENT_SECRET'],
                              scope: 'https://outlook.office365.com/.default',
                              grant_type: 'client_credentials')
    body = res.body
    puts "Token endpoint response: #{body}" # debug
    json = JSON.parse(body) rescue {}
    Rails.logger.error "Token endpoint response: #{json.inspect}" unless json["access_token"]
    raise "Failed to get token: #{json['error_description'] || json}" unless json["access_token"]
    json['access_token'] || raise("Failed to get token: #{json}")
  end
end
