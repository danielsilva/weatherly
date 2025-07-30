require 'rails_helper'

# Run with: bundle exec rspec --tag contract
RSpec.describe WeatherService, :contract do
  let(:service) { described_class.new }

  before(:all) do
    WebMock.allow_net_connect!
  end

  after(:all) do
    WebMock.disable_net_connect!
  end

  before do
    Rails.cache.clear
    # Add a small delay between tests to respect rate limits
    sleep 0.5
  end

  describe "#forecast" do
    context "with valid location" do
      it "returns weather data" do
        result = service.forecast("Toronto")

        expect(result).not_to have_key(:error)
        expect(result).to match(
          a_hash_including(
            location: a_hash_including(
              name: a_kind_of(String),
              region: a_kind_of(String),
              country: a_kind_of(String)
            ),
            current: a_hash_including(
              temperature: a_hash_including(
                celsius: a_kind_of(Numeric),
                feels_like_c: a_kind_of(Numeric)
              )
            ),
            forecast: all(
              a_hash_including(
                date: a_kind_of(String),
                day: a_hash_including(
                  max_temp_c: a_kind_of(Numeric),
                  min_temp_c: a_kind_of(Numeric),
                  chance_of_rain: a_kind_of(Integer),
                  chance_of_snow: a_kind_of(Integer)
                )
              )
            )
          )
        )
      end
    end

    context "with invalid location" do
      it "returns error for non-existent location" do
        result = service.forecast("ThisIsNotARealLocationXYZ123")

        expect(result[:error]).to be_present
        expect(result[:error]).to include("No matching location found")
      end

      it "returns error for empty location" do
        result = service.forecast("")

        expect(result[:error]).to be_present
      end
    end
  end
end
