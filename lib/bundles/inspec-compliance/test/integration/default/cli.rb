# encoding: utf-8

# options
inspec_bin = 'BUNDLE_GEMFILE=/inspec/Gemfile bundle exec inspec'
api_url = 'https://0.0.0.0'
profile = '/inspec/examples/profile'

# TODO: determine tokens automatically, define in kitchen yml
access_token = ENV['COMPLIANCE_ACCESSTOKEN']
refresh_token = ENV['COMPLIANCE_REFRESHTOKEN']

%w{refresh_token access_token}.each do |type|
  case type
  when 'access_token'
    token_options = "--token '#{access_token}'"
  when 'refresh_token'
    token_options = "--refresh_token '#{refresh_token}'"
  end

  # verifies that the help command works
  describe command("#{inspec_bin} compliance help") do
    its('stdout') { should include 'inspec compliance help [COMMAND]' }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
  end

  # version command fails gracefully when server not configured
  describe command("#{inspec_bin} compliance version") do
    its('stdout') { should include 'Server configuration information is missing' }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
  end

  # login via access token token
  describe command("#{inspec_bin} compliance login #{api_url} --insecure --user 'admin' #{token_options}") do
    its('stdout') { should include 'Successfully authenticated' }
    its('stdout') { should_not include 'Your server supports --user and --password only' }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
  end

  # see available resources
  describe command("#{inspec_bin} compliance profiles") do
    its('stdout') { should include 'base/ssh' }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
  end

  # upload a compliance profile
  describe command("#{inspec_bin} compliance upload #{profile} --overwrite") do
    its('stdout') { should include 'Profile is valid' }
    its('stdout') { should include 'Successfully uploaded profile' }
    its('stdout') { should_not include 'error(s)' }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
  end

  # returns the version of the server
  describe command("#{inspec_bin} compliance version") do
    its('stdout') { should include 'Chef Compliance version:' }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
  end

  # logout
  describe command("#{inspec_bin} compliance logout") do
    its('stdout') { should include 'Successfully logged out' }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
  end
end
