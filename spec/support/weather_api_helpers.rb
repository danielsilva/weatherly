module WeatherApiHelpers
  def stub_weather_api_request(location, response_data)
    stub_request(:get, "https://api.weatherapi.com/v1/forecast.json")
      .with(
        query: hash_including(
          q: location,
          days: "3"
        )
      )
      .to_return(
        status: 200,
        body: response_data.to_json,
        headers: { 'Content-Type': 'application/json' }
      )
  end

  def stub_weather_api_error(location, error_message = "No matching location found.")
    stub_request(:get, "https://api.weatherapi.com/v1/forecast.json")
      .with(
        query: hash_including(q: location)
      )
      .to_return(
        status: 400,
        body: {
          error: {
            code: 1006,
            message: error_message
          }
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )
  end
end

RSpec.configure do |config|
  config.include WeatherApiHelpers, type: :system
  config.include WeatherApiHelpers, type: :feature
end
