=begin
 Copyright IBM Corp. 2015
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License. 
=end

=begin
				This class is meant to be the main container that holds all the necessary objects
				
				It contains a service account object that identifies who you are and a REST client object
				that makes the REST API calls and store the results of those calls. You must provide your bundle identifies
				in order for the application to run effectively. You can choose the default translation language you would like 
				by setting the locale
				
				cache_control = Cache Control Object - See cache_control.rb
				locale = locale of the translated strings. Default is "" which indicates all locales will be loaded
				use_service = parameter to set if user would like to disable/enable service
				bundle_id = ID of the bundle that contains the translations
				service_account = Service Account Object - See service_account.rb
				rest_client = REST Client object - See rest_client.rb
=end	
			
module GP
	module Ruby
		class Client
			require_relative './service_account.rb'
			require_relative './rest_client.rb'
			require_relative './cache_control.rb'
			
			@@cache_control = CacheControl.new
			
			@@locale = ""
			
			@@just_started = true
			@@use_service = true

			def initialize(bundle_id, srvc_account=ServiceAccount.new)
			  @@bundle_id = bundle_id
				
				if @@use_service && (Time.now - @@cache_control.get_last_accessed_time >= @@cache_control.get_ttl || @@just_started)
					@@just_started = false
					@@cache_control.set_last_accessed_time(Time.now)
					
					backend = {}
					I18n.backend = I18n::Backend::Chain.new(I18n::Backend::KeyValue.new(backend), I18n.backend)
					
					@@service_account = srvc_account
					if @@service_account.nil?
						raise "No valid service account"
					end
					
					@@rest_client = RESTClient.new(@@service_account, @@bundle_id, @@locale)
				end				
			end
			
			def get_bundle_id
				@@bundle_id
			end
			
			def set_bundle_id(bundle_id)
				@@bundle_id = bundle_id
			end
			
			def get_locale
				@@locale
			end
			
			def set_locale(locale)
				@@locale = locale
			end
			
			def get_cache_control
				@@cache_control
			end
			
			def get_service_account
				@@service_account
			end
			
			def get_rest_client
				@@rest_client
			end
			
			def disable_service
				@@use_service = false
			end
			
			def enable_service
				@@use_service = true
			end
			
			def get_default_locale
				request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
			end
			
		end
	end
end