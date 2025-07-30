require 'rails_helper'
require 'webmock/rspec'

RSpec.describe WeatherService do
  let(:service) { described_class.new }
  let(:api_key) { "test_api_key" }
  let(:base_url) { "http://api.weatherapi.com/v1/forecast.json" }
  let(:location) { "Toronto" }

  before do
    stub_const("WeatherService::API_KEY", api_key)
    stub_const("WeatherService::BASE_URL", base_url)
    Rails.cache.clear
  end

  describe "#forecast" do
    let(:api_response) do
      {
        "location" => {
          "name" => "Toronto",
          "region" => "ON",
          "country" => "Canada"
        },
        "current" => {
          "temp_c" => 15.0,
          "temp_f" => 59.0,
          "feelslike_c" => 13.0,
          "feelslike_f" => 55.4
        },
        "forecast" => {
          "forecastday" => [
            {
              "date" => "2024-01-01",
              "day" => {
                "maxtemp_c" => 16.0,
                "mintemp_c" => 10.0,
                "daily_chance_of_rain" => 20,
                "daily_chance_of_snow" => 0
              }
            }
          ]
        }
      }
    end

    context "when API key is not configured" do
      before do
        stub_const("WeatherService::API_KEY", nil)
      end

      it "raises a configuration error" do
        expect { service.forecast(location) }.to raise_error(StandardError, "API key not configured")
      end
    end

    context "when API key is configured" do
      context "when API request is successful" do
        before do
          stub_request(:get, base_url)
            .with(query: {
              key: api_key,
              q: location,
              days: 3
            })
            .to_return(status: 200, body: api_response.to_json, headers: { 'Content-Type' => 'application/json' })
        end

        it "returns parsed forecast data" do
          result = service.forecast(location)

          expect(result[:location][:name]).to eq("Toronto")
          expect(result[:location][:country]).to eq("Canada")
          expect(result[:current][:temperature][:celsius]).to eq(15.0)
          expect(result[:forecast].length).to eq(1)
        end

        it "returns cache metadata on first request" do
          result = service.forecast(location)

          expect(result[:from_cache]).to eq(false)
          expect(result[:cache_age_minutes]).to eq(0)
        end

        it "returns cached data on subsequent requests (case insensitive)" do
          service.forecast("Toronto")
          result = service.forecast("toronto")

          expect(result[:from_cache]).to eq(true)
          expect(result[:cache_age_minutes]).to be >= 0
        end
      end

      context "when API returns an error" do
        before do
          error_response = {
            "error" => {
              "code" => 1006,
              "message" => "No matching location found."
            }
          }

          stub_request(:get, base_url)
            .with(query: hash_including(q: location))
            .to_return(status: 400, body: error_response.to_json, headers: { 'Content-Type' => 'application/json' })
        end

        it "returns error hash" do
          result = service.forecast(location)
          expect(result).to eq({ error: "No matching location found." })
        end
      end

      context "when network error occurs" do
        before do
          stub_request(:get, base_url)
            .with(query: hash_including(q: location))
            .to_raise(Faraday::ConnectionFailed.new("Network error"))
        end

        it "returns network error hash" do
          result = service.forecast(location)
          expect(result).to eq({ error: "Network error: Network error" })
        end
      end
    end
  end
end
