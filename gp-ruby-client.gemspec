Gem::Specification.new do |s|
  s.name        = 'gp-ruby-client'
  s.version     = '0.2.0'
  s.date        = '2019-05-13'
  s.summary     = "Ruby SDK for Globalization Pipeline"
  s.description = "Ruby SDK for Globalization Pipeline on IBM Cloud"
  s.authors     = ["Visaahan Anandarajah"]
  s.email       = 'icuintl@us.ibm.com'
  s.licenses	= 'Apache-2.0'
  s.homepage	= 'https://github.com/IBM-Cloud/gp-ruby-client'
  s.metadata = {
  "documentation_uri" => "https://github.com/IBM-Cloud/gp-ruby-client",
  "source_code_uri"   => "https://github.com/IBM-Cloud/gp-ruby-client"
  }
  s.files       = ["lib/cache_control.rb", "lib/gp-ruby-client.rb", "lib/rest_client.rb", "lib/service_account.rb", "lib/hmac.rb"]
end
