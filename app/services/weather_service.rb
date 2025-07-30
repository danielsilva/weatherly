class WeatherService
  API_KEY = ENV["WEATHERAPI_KEY"]
  BASE_URL = ENV["WEATHERAPI_BASE_URL"]

  CacheMetadata = Struct.new(:from_cache, :cached_at, :cache_age_minutes, keyword_init: true)

  def initialize
    @connection = Faraday.new do |faraday|
      faraday.request :url_encoded
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter Faraday.default_adapter
    end
  end

  def forecast(location)
    raise StandardError, "API key not configured" if API_KEY.blank?

    fetch_with_cache(location) do
      fetch_from_api(location)
    end
  rescue Faraday::Error => e
    { error: "Network error: #{e.message}" }
  end

  private

  def fetch_with_cache(location)
    cached_data = Rails.cache.read(cache_key(location))

    if cached_data
      merge_cache_metadata(cached_data, from_cache: true)
    else
      fresh_data = yield
      return fresh_data if fresh_data[:error]

      cache_forecast_data(location, fresh_data)
    end
  end

  def fetch_from_api(location)
    response = @connection.get(BASE_URL, {
      key: API_KEY,
      q: location,
      days: 3
    })

    if response.success?
      parse_forecast_data(response.body)
    else
      { error: response.body.dig("error", "message") || "Failed to fetch weather data" }
    end
  end

  def cache_forecast_data(location, forecast_data)
    data_with_timestamp = forecast_data.merge(cached_at: Time.current)
    Rails.cache.write(cache_key(location), data_with_timestamp, expires_in: 30.minutes)
    merge_cache_metadata(data_with_timestamp, from_cache: false)
  end

  def merge_cache_metadata(data, from_cache:)
    cache_metadata = CacheMetadata.new(
      from_cache: from_cache,
      cached_at: data[:cached_at],
      cache_age_minutes: from_cache ? ((Time.current - data[:cached_at]) / 60).round : 0
    )
    data.merge(cache_metadata.to_h)
  end

  def parse_forecast_data(data)
    {
      location: {
        name: data["location"]["name"],
        region: data["location"]["region"],
        country: data["location"]["country"]
      },
      current: {
        temperature: {
          celsius: data["current"]["temp_c"],
          feels_like_c: data["current"]["feelslike_c"]
        }
      },
      forecast: data["forecast"]["forecastday"].map { |day|
        {
          date: day["date"],
          day: {
            max_temp_c: day["day"]["maxtemp_c"],
            min_temp_c: day["day"]["mintemp_c"],
            chance_of_rain: day["day"]["daily_chance_of_rain"],
            chance_of_snow: day["day"]["daily_chance_of_snow"]
          }
        }
      }
    }
  end

  def cache_key(location)
    normalized_location = location.to_s.strip.downcase.gsub(/\s+/, "_")
    "weather_forecast:#{normalized_location}"
  end
end
