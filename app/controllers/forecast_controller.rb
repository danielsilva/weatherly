class ForecastController < ApplicationController
  def index
    # Display the form for entering location
  end

  def show
    return unless location_is_valid
    @forecast_data = weather_service.forecast(params[:location])
    handle_forecast_error
  end

  private

  def location_is_valid
    return true if params[:location].present?

    @error_message = "Please enter a location"
    render :error, status: :unprocessable_entity
    false
  end

  def handle_forecast_error
    return unless @forecast_data[:error]

    @error_message = @forecast_data[:error]
    render :error, status: :unprocessable_entity
  end

  def weather_service
    @_weather_service ||= WeatherService.new
  end
end
