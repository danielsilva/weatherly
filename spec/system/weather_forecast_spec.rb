require 'rails_helper'

RSpec.describe "Weather Forecast", type: :system, js: true do
  let(:weather_page) { WeatherForecastPage.new }

  before do
    Rails.cache.clear
  end

  it "displays welcome message" do
    weather_page.visit_page

    expect(weather_page).to have_welcome_message
  end

  it "allows searching for weather in a valid city" do
    stub_weather_data(location: "Toronto")

    weather_page
      .visit_page
      .search_for_location("Toronto")

    expect(weather_page).to have_location("Toronto")
    expect(weather_page).to have_content("Last updated 0 minutes ago")
    expect(weather_page).to have_current_weather(26)
    expect(weather_page).to have_feels_like(24)
    expect(weather_page).to have_forecast_days(3)
  end

  it "shows error for invalid location" do
    stub_weather_api_error("Invalid Location")

    weather_page
      .visit_page
      .search_for_location("Invalid Location")

    expect(weather_page).to have_error_message("No matching location found")
    expect(weather_page).not_to have_current_weather
  end

  it "shows error when searching without a location" do
    stub_weather_api_error("")

    weather_page
      .visit_page
      .search_for_location("")

    expect(weather_page).to have_error_message("Please enter a location")
  end

  it "displays cached data on second search" do
    stub_weather_data(location: "Toronto")

    weather_page
      .visit_page
      .search_for_location("Toronto")

    expect(weather_page).to have_location("Toronto")
    expect(weather_page).to have_content("Last updated 0 minutes ago")
    expect(weather_page).to have_current_weather(26)

    travel_to 5.minutes.from_now do
      weather_page.search_for_location("Toronto")

      expect(weather_page).to have_location("Toronto")
      expect(weather_page).to have_content("Last updated 5 minutes ago")
      expect(weather_page).to have_current_weather(26)
    end
  end

  def stub_weather_data(location:)
    stub_weather_api_request(location, {
      "location": {
        "name": location,
        "region": "Test Region",
        "country": "Test Country"
      },
      "current": {
        "temp_c": 25.5,
        "feelslike_c": 23.5
      },
      "forecast": {
        "forecastday": 3.times.map do |i|
          {
            "date": (Date.today + i).to_s,
            "day": {
              "maxtemp_c": 22.0 + i,
              "mintemp_c": 15.0 + i,
              "daily_chance_of_rain": 20,
              "daily_chance_of_snow": 0
            }
          }
        end
      }
    })
  end
end
