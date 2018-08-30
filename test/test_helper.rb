ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def login_user(user, password='passw0rd')
    user = users(:one)
    post user_sessions_url, params: {email: user.email, password: password}
    follow_redirect!
  end
end
