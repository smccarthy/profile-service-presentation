require 'faraday'
require 'json'
require 'uri'

describe "Test" do
  def get_profile
    profile_name = 'test-profile'
    claim_url = "http://localhost:8080/profile/#{profile_name}/next"
    response = Faraday.get claim_url
    profile = JSON.parse(response.body)
    raise "No profile available for #{profile_name}" unless profile['_id']

    profile
  end

  def release_profile(profile_id)
    puts "Releasing profile #{profile_id}"
    Faraday.post "http://localhost:8080/profile/#{profile_id}/release", {}
  end

  it '[test-00001] this test should run test-00001' do
    profile = get_profile
    puts "Running test-00001 using profile #{profile}"
    sleep 2
    release_profile(profile['_id'])
  end
end
