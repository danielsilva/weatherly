class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  rescue_from StandardError, with: :handle_standard_error

  def handle_standard_error(exception)
    @error_message = "Failed to fetch forecast: #{exception.message}"
    render :error, status: :internal_server_error
  end
end
