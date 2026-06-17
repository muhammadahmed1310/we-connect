class Geocode
  GOOGLE_KEY = "AIzaSyBuMmlMao6-AmDGfcEVwltWzWfVvgKV8Qg" # this one is for project course
  GOOGLE_URL = "https://maps.googleapis.com/maps/api/geocode/json?latlng=__latlng__&key=#{GOOGLE_KEY}".freeze
  GOOGLE_ADDRESS_URL = "https://maps.googleapis.com/maps/api/geocode/json?address=__address__&key=#{GOOGLE_KEY}".freeze

  # Initialize with either a lat/lng or an address
  def initialize(lat, lng, address = nil)
    @lat = lat
    @lng = lng
    @address = address
  end

  # if we have a lat/lng then we reverse geocode, otherwise we geocode
  def results
    reverse_geocode if @results.nil? && !(@lat.nil? || @lng.nil?)
    geocode if @results.nil? && !@address.nil?
    @results
  end

  # Get the lat/lng if we have been initialized with an address
  def geocode
    address = @address.to_s.encode(Encoding.find("ASCII"), invalid: :replace, undef: :replace, replace: "")
    url = GOOGLE_ADDRESS_URL.gsub("__address__", address)
    results = RestClient.get url
    j_results = JSON.parse(results.to_s)
    return unless j_results["status"] == "OK"

    @results = j_results["results"]
  end

  # Get the address if we have been initialized with a lat/lng
  def reverse_geocode
    url = GOOGLE_URL.gsub("__latlng__", "#{@lat},#{@lng}")
    results = RestClient.get url
    j_results = JSON.parse(results.to_s)
    return unless j_results["status"] == "OK"
    @results = j_results["results"]
  end

  def lng
    (@lng || results) ? results[0]["geometry"]["location"]["lng"] : nil
  end

  def lat
    (@lat || results) ? results[0]["geometry"]["location"]["lat"] : nil
  end

  # Get the city or location name from the results
  def name
    return nil if results.nil? || results.empty?
    %w[locality administrative_area_level_2 administrative_area_level_1].each do |type|
      results.each do |r|
        r["address_components"].each do |ac|
          return ac["long_name"] if ac["types"].include? type
        end
      end
    end
    results[0]["long_name"]
  end

  # Get the address from the results
  def address
    return nil if results.nil? || results.empty?
    results.each do |r|
      return r["formatted_address"] unless r["formatted_address"].nil?
    end
    results[0]["formatted_address"]
  end

  def address_sans_postcode
    return nil if results.nil? || results.empty?
    address.gsub(" #{post_code}",'')
  end

  # Get the post code from the results
  def post_code
    return nil if results.nil? || results.empty?
    results.each do |r|
      r["address_components"].each do |ac|
        return ac["long_name"] if ac["types"].include? "postal_code"
      end
    end
    nil
  end

  # Determine if the lat/lng is within the given bounding box
  # @param [Array] bottom_left [lat, lng] of the bottom left corner of the bounding box
  # @param [Array] top_right [lat, lng] of the top right corner of the bounding box
  # @return [Boolean] true if the lat/lng is within the bounding box
  def is_within(bottom_left, top_right)
    if @lat.nil? || @lng.nil?
      puts "lat or lng is nil: #{@lat}, #{@lng}"
      nil
    else
      @lat >= bottom_left[0] && @lat <= top_right[0] && @lng >= bottom_left[1] && @lng <= top_right[1]
    end
  end
end
