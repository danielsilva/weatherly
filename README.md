# Weatherly

Weatherly fetches weather data from the `weatherapi.com` service and displays current conditions plus a 3-day forecast. An API_KEY was added to the `.env` file and pushed up on purpose to make the evaluation process seamless.  

The application implements caching to minimize API calls:

- Weather data is cached for 30 minutes per location. The cache key is based on the location text searched. Caching per zip code could be implemented by adding an additional external API call to a third-party address service, or by making the location input an autocomplete field. Either way would allow the app to get the zip code for the text searched.
- Cache metadata shows when data was last updated

## Architecture

#### Controllers
- **ForecastController** (`app/controllers/forecast_controller.rb`)
  - `index`: Renders the search form
  - `show`: Handles location submission and coordinates weather data retrieval

#### Services
- **WeatherService** (`app/services/weather_service.rb`)
  - Encapsulates all weather API interactions
  - Implements caching logic
  - `forecast(location)`: Main entry point, returns weather data or error

#### Views
- **Layout**: Uses Twitter Bootstrap (CDN) for styling. The js file is included to allow dismissing the error alert.
- **Turbo Frames**: Provides seamless updates without full page reloads
  - `forecast_results` element updates dynamically with weather data
- **Partials**:
  - `forecast/show.html.erb`: Displays weather data
  - `forecast/error.html.erb`: Shows error messages

#### Testing Infrastructure
- **Page Objects** (`spec/support/pages/weather_forecast_page.rb`)
  - Encapsulates Capybara interactions for maintainable system tests
  - Uses data-testid attributes for reliable element selection
- **Test Helpers** (`spec/support/weather_api_helpers.rb`)
  - Provides consistent API stubbing across tests

## Test Suite

### Contract Tests
- **Contract specs** (`spec/contract/services/weather_service_contract_spec.rb`): Test against the real WeatherAPI (run with `--tag contract`)

### Integration Tests
- **Request specs** (`spec/requests/forecast_spec.rb`): Test controller actions and HTTP responses
- **Service specs** (`spec/services/weather_service_spec.rb`): Test the weather service logic including caching behavior by decoupling tests from production code

### End to End Tests

- **System specs** (`spec/system/weather_forecast_spec.rb`): Full user journey tests using Capybara with Page Object pattern

## Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```

## Running the Application

Start the Rails server:
```bash
rails server
```

Visit http://localhost:3000 and enter a location to get the weather forecast.

## Running Tests

Run all tests:
```bash
bundle exec rspec
```

Run contract tests (contract tests do not run by default to prevent reaching API limits):
```bash
bundle exec rspec --tag contract
```

## Code Quality

Run RuboCop for style checking:
```bash
bundle exec rubocop
```

Run Brakeman for security analysis:
```bash
bundle exec brakeman
```