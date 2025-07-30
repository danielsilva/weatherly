require 'rails_helper'

RSpec.describe ForecastController, type: :request do
  let(:weather_service) { instance_double(WeatherService) }

  before do
    allow(WeatherService).to receive(:new).and_return(weather_service)
  end

  describe "index" do
    it "returns a success response" do
      get "/"

      expect(response).to be_successful
    end
  end

  describe "forecast" do
    context "when location is blank" do
      it "returns unprocessable entity status" do
        get "/forecast", params: { location: "" }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when location is provided" do
      let(:location) { "Toronto" }
      let(:forecast_data) do
        {
          location: {
            name: "Toronto",
            country: "Canada",
            region: "ON"
          },
          current: {
            temperature: { celsius: 15, feels_like_c: 13 },
            humidity: 80,
            wind: { kph: 10, direction: "W" },
            uv: 3
          },
          forecast: []
        }
      end

      context "when weather service returns successful data" do
        before do
          allow(weather_service).to receive(:forecast).with(location).and_return(forecast_data)
        end

        it "returns a success response" do
          get "/forecast", params: { location: location }

          expect(response).to be_successful
        end
      end

      context "when weather service returns an error" do
        let(:error_data) { { error: "Location not found" } }

        before do
          allow(weather_service).to receive(:forecast).with(location).and_return(error_data)
        end

        it "returns unprocessable entity status" do
          get "/forecast", params: { location: location }

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when weather service raises an exception" do
        before do
          allow(weather_service).to receive(:forecast).with(location).and_raise(StandardError, "API error")
        end

        it "returns internal server error status" do
          get "/forecast", params: { location: location }

          expect(response).to have_http_status(:internal_server_error)
        end
      end
    end
  end
end
