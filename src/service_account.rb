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

require 'json'

class ServiceAccount
=begin
	This object is meant to identify the user and contains credentials needed to make the REST API calls
	
	This class will either use user-provided variables, environment variables or vcap_services variables in your application
	
	url = base url string user must call for REST API
	user_id = ID of user
	password = password of user
	instance_id = ID of your specific service instanceId
=end

	GP_URL ||= "GP_URL"
	GP_USER_ID ||= "GP_USER_ID"
	GP_PWD ||= "GP_PASSWORD"
	GP_INSTANCE_ID ||="GP_INSTANCE_ID"
	
	APP_NAME ||= "g11n-pipeline"
	APP_NAME_REGEX = /gp-(.*)/
	
	VCAP_SERVICES ||= "VCAP_SERVICES"
	
	CREDENTIALS ||= "credentials"
	CREDENTIALS_INDEX = 0
	
	URL_STRING  ||="url"
	USER_ID_STRING ||= "userId"
	PASSWORD_STRING ||= "password"
	INSTANCE_ID_STRING ||= "instanceId"
	
	def initialize(url_string = "", user_id = "", pwd = "", instance_id = "")
		if !url_string.empty? && !user_id.empty? && !pwd.empty? && !instance_id.empty?
			@url_string = url_string
			@user_id = user_id
			@pwd = pwd
			@instance_id = instance_id
		else
			account = get_service_account_via_env_var
			
			if account.nil?
				account = get_service_account_via_vcap_service
					if account.nil?
						raise "Couldn't create a service account"
					end
			end
			
			@url_string = account[0]
			@user_id = account[1]
			@pwd = account[2]
			@instance_id=account[3]
			
		end
	end
		
	def get_url_string
		@url_string
	end
	
	def get_user_id
		@user_id
	end
	
	def get_password
		@pwd
	end
	
	def get_instance_id
		@instance_id
	end
	
	def set_url_string(url)
		@url_string = url
	end
	
	def set_user_id(user_id)
		@user_id = user_id
	end
	
	def set_password(password)
		@pwd = password
	end
	
	def set_instance_id(instance_id)
		@instance_id = instance_id
	end
	
private

	def get_service_account_via_env_var
	
		url_string = ENV[GP_URL]
		if url_string.nil?
			return
		end
		
		user_id = ENV[GP_USER_ID]
		if user_id.nil?
			return
		end
		
		pwd = ENV[GP_PWD]
		if pwd.nil?
			return
		end
		
		instance_id = ENV[GP_INSTANCE_ID]
		if instance_id.nil?
			return
		end
	
		return [url_string, user_id, pwd,instance_id]
	end
	
	def get_service_account_via_vcap_service
	
		vcap_services = ENV[VCAP_SERVICES]

		if vcap_services.nil?
			return
		end
		
		json_vcap_services = JSON.parse(vcap_services)
		
		app_name = ""
		json_vcap_services.each do |key, value|
			if (key =~ APP_NAME_REGEX or key.equals? (APP_NAME))
				app_name = key
				break
			end
		end

		credentials_list = JSON.parse(vcap_services)[app_name][CREDENTIALS_INDEX][CREDENTIALS]
		
		if !credentials_list.nil?
			url = credentials_list[URL_STRING]
			user_id = credentials_list[USER_ID_STRING]
			pwd = credentials_list[PASSWORD_STRING]
			instance_id = credentials_list[INSTANCE_ID_STRING]
			if url.nil? || user_id.nil? || pwd.nil? || instance_id.nil?
				return
			end
			
			return [url, user_id, pwd, instance_id]
		end
		
		return
	end
end