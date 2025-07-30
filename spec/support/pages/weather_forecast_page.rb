class WeatherForecastPage
  include Capybara::DSL

  def has_current_weather?(temperature = nil)
    within_forecast_results do
      if temperature
        find('[data-testid="current-temperature"]').has_content?("#{temperature}°C")
      else
        has_css?('[data-testid="current-temperature"]')
      end
    end
  end

  def has_error_message?(message)
    within_forecast_results do
      has_css?('[data-testid="error-message"]') && find('[data-testid="error-message"]').has_content?(message)
    end
  end

  def has_forecast_days?(count = 3)
    within_forecast_results do
      has_css?('[data-testid="forecast-day"]', count: count)
    end
  end

  def has_location?(location_name)
    within_forecast_results do
      find('[data-testid="location-name"]').has_content?(location_name)
    end
  end

  def has_feels_like?(temperature)
    within_forecast_results do
      find('[data-testid="feels-like"]').has_content?("Feels like #{temperature}°C")
    end
  end

  def has_welcome_message?
    has_content?("Weatherly") &&
      has_content?("Enter a location to get the current weather and forecast")
  end

  def search_for_location(location)
    fill_in "Enter city, address, or zip code...", with: location
    click_button "Get Weather"
    self
  end

  def visit_page
    visit '/'
    self
  end

  def within_forecast_results(&block)
    within("#forecast_results") do
      block.call
    end
  end
end
