require 'faraday'
require 'json'
require 'uri'

class ProfileService
  @@profile_service_url = 'http://localhost:8080'

  # 1st API request - Add data to profile in the profile service.
  # This will be done prior to your tests running.
  def add_to_profile(profile_name:, profile_data:)
    Faraday.post "#{@@profile_service_url}/profile/#{profile_name}", profile_data
  rescue StandardError => e
    puts "Error adding to profile : #{e.message}"
  end

  # 2nd API request - Retrieves an object from the profile service.
  # This will lock that profile so another test can not use it.
  def profile(profile_name:)
    claim_url = "#{@@profile_service_url}/profile/#{profile_name}/next"
    response = Faraday.get claim_url
    profile = JSON.parse(response.body)
    raise "No profile available for #{profile_name}" unless profile
    profile
  end

  # 3rd API request - Releases profile lock, so another test can get this profile.
  def release_profile(profile_id:)
    Faraday.post "#{@@profile_service_url}/profile/#{profile_id}/release", {}
  rescue StandardError => e
    puts "Error releasing profile : #{e.message}"
  end
end

profile_service = ProfileService.new

profile_name = 'test-profile'
profile_data = {
  username: 'myTestUserName1',
  password: 'myTestPassword1'
}
p = profile_service.add_to_profile(profile_name: profile_name, profile_data: profile_data)
puts "Response from adding to profile #{p.body}"
p = profile_service.profile(profile_name: profile_name)
puts "Response from getting a profile #{p}"
profile_id = p['_id']
r = profile_service.release_profile(profile_id: profile_id)
puts "Response from releasing profile #{r.body}"

# Add two more entries
p = profile_service.add_to_profile(profile_name: profile_name, profile_data: {username: 'myTestUserName2', password: 'myTestPassword2'})
p = profile_service.add_to_profile(profile_name: profile_name, profile_data: {username: 'myTestUserName3', password: 'myTestPassword3'})

# ruby profile-service-example.rb