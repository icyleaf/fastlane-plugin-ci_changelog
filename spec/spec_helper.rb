$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)


require 'fastlane' # to import the Action super class
require 'fastlane/plugin/ci_changelog' # import the actual plugin
require 'webmock/rspec'
require 'base64'

# WebMock.disable_net_connect!(allow_localhost: true)

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)

def stub_jenkins_auth(user: nil, token_or_password: nil)
  api_url = "#{ENV['JENKINS_URL']}/api/json"

  if user && token_or_password
    stub_request(:get, api_url)
      .to_return(
        status: 403,
        headers: { 'Content-Type' => 'text/html;charset=UTF-8' },
        body: "<html><head><meta http-equiv='refresh' content='1;url=#{ENV['JENKINS_URL']}/login?from=%2Fjob%2FCustom%2520Project%2F1%2Fapi%2Fjson'/><script>window.location.replace('#{ENV['JENKINS_URL']}/login?from=%2Fjob%2FCustom%2520Project%2F1%2Fapi%2Fjson');</script></head><body style='background-color:white; color:white;'>"
      )

    stub_request(:get, api_url)
      .with(basic_token_header(user, token_or_password))
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json;charset=UTF-8' },
        body: '{}'
      )
  else
    stub_request(:get, api_url)
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json;charset=UTF-8' },
        body: '{}'
      )
  end
end

def stub_jenkins_project(count, commits, failure_number: nil, user: nil, token_or_password: nil)
  failure_number ||= count

  template_url = Addressable::Template.new("#{ENV['JOB_URL']}/{id}/api/json")
  count.downto(failure_number).each do |i|
    mock = stub_request(:get, template_url)

    if user && token_or_password
      mock = mock.with(basic_token_header(user, token_or_password))
    end

    mock.to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json;charset=UTF-8' },
      body: {
        result: i == failure_number ? 'SUCCESS' : 'FAILURE',
        changeSet: {
          items: commits
        }
      }.to_json
    )
  end
end


def basic_token_header(user, token_or_password)
  token_encode = Base64.encode64("#{user}:#{token_or_password}").strip
  { headers: { 'Authorization' => "Basic #{token_encode}" } }
end