class IndustryService
  include HTTParty
  base_uri 'https://api.smartrecruiters.com/v1'

  def self.fetch_industries
    response = get('/industries')
    return [] unless response.success?
    response.parsed_response
  end
end