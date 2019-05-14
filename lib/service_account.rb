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
	This object is meant to identify the user and contains credentials needed to make the REST API calls. 
  Access to Globalization Pipeline RC enabled service instances for users in is controlled by IBM Cloud Identity and Access Management 
  (IAM) and/or Globalization Pipeline Authentication. Whereas for CF instances only Globalization Pipeline Authentication can be used.
	
  There are three options for creating a valid instance:
    1. Provide the credentials as parameters.
  
       url_string = base url string user must call for REST API
       user_id = ID of user
       pwd = password of user
       instance_id = ID of your specific service instanceId
       api_key = IAM API Key to access the instance.
  
       Mandatory for both authentication mechanisms
       url_string, instance_id
       
       For Globalization Pipeline authentication:
       user_id and pwd
       
       For IAM authentication:
       api_key
    
       If both Globalization Pipeline and IAM authentication credentials are provided then
       instance will be initialized with Globalization Pipeline authentication.
    
    
    2. Use the user defined environment variables for providing credentials (no params required).
       GP_URL = base url string user must call for REST API
       GP_USER_ID = ID of user
       GP_PWD = password of user
       GP_INSTANCE_ID = ID of your specific service instanceId
       GP_IAM_API_KEY = IAM API Key to access the instance.
       
       Mandatory for both authentication mechanisms:
       GP_URL, GP_INSTANCE_ID
       
       For Globalization Pipeline authentication:
       GP_USER_ID, GP_PWD
    
       For IAM authentication:
       GP_IAM_API_KEY
    
       If both Globalization Pipeline and IAM authentication credentials are provided then
       instance will be initialized with Globalization Pipeline authentication.
  
    3. Use the ``VCAP_SERVICES`` environment variable for the first matching GP service instance, 
       where matching is defined as app name = g11n-pipeline or matches the regex /gp-(.*)/
  
=end

	GP_URL ||= "GP_URL"
	GP_USER_ID ||= "GP_USER_ID"
	GP_PWD ||= "GP_PASSWORD"
	GP_INSTANCE_ID ||="GP_INSTANCE_ID"
	GP_IAM_API_KEY ||= "GP_IAM_API_KEY"

	
	APP_NAME ||= "g11n-pipeline"
	APP_NAME_REGEX = /gp-(.*)/
	
	VCAP_SERVICES ||= "VCAP_SERVICES"
	
	CREDENTIALS ||= "credentials"
	CREDENTIALS_INDEX = 0
	
	URL_STRING  ||="url"
	USER_ID_STRING ||= "userId"
	PASSWORD_STRING ||= "password"
	INSTANCE_ID_STRING ||= "instanceId"
	IAM_API_KEY_STRING ||= "apikey"
	
	def initialize(url_string = "", user_id = "", pwd = "", instance_id = "", api_key="", credsFilePath = "")
	  
	  if !url_string.nil?  && !url_string.empty? && 
      !user_id.nil? &&  !user_id.empty? && 
      !pwd.nil? &&  !pwd.empty? &&
      !instance_id.nil? &&  !instance_id.empty?
			@url_string = url_string
			@user_id = user_id
			@pwd = pwd
			@instance_id = instance_id
			@iam_enabled = false
			
		elsif !url_string.nil? && !url_string.empty? && !instance_id.nil? && !instance_id.empty? && !api_key.nil? && !api_key.empty?
      @url_string = url_string
      @instance_id = instance_id
      @api_key = api_key
      @iam_enabled = true
    
	  else
	    account = get_service_account_via_env_var
	    if account.nil?
	      account = get_service_account_via_vcap_service
			end
			if account.nil? && !credsFilePath.empty?
			  File.open(credsFilePath) do |credsFile|
          creds = JSON.parse(credsFile.read) 
          if !creds.nil?
            if creds.has_key?("credentials")
              creds=creds["credentials"]
            end
            account = extractCredsFromJson(creds)
            if account.nil?
                   raise "Couldn't create a service account from file"
            end
          end
        end
      end
      if account.nil?
        raise "Couldn't create a service account"
      end
      
			@url_string = account[0]
			@user_id = account[1]
			@pwd = account[2]
			@instance_id=account[3]
			@api_key = account[4]
      @iam_enabled = account[5]
			
    end
	end
		
	def is_iam_enabled
    @iam_enabled
	end
  
  def get_api_key
    @api_key
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
    
    instance_id = ENV[GP_INSTANCE_ID]
    if instance_id.nil?
      return
    end
    
    user_id = ENV[GP_USER_ID]
    pwd = ENV[GP_PWD]
    api_key=ENV[GP_IAM_API_KEY]
    
    if (user_id.nil? || pwd.nil?) && api_key.nil?
      return
    end
    
    iam_enabled=api_key.nil??false:true

    return [url_string, user_id, pwd, instance_id, api_key, iam_enabled]
  end
  
  def get_service_account_via_vcap_service
  
    vcap_services = ENV[VCAP_SERVICES]

    if vcap_services.nil?
      return
    end
    
    json_vcap_services = JSON.parse(vcap_services)
    
    app_name = ""
    json_vcap_services.each do |key, value|
      if (key =~ APP_NAME_REGEX or APP_NAME.eql? key)
        app_name = key
        break
      end
    end

    credentials_list = JSON.parse(vcap_services)[app_name][CREDENTIALS_INDEX][CREDENTIALS]
    return extractCredsFromJson(credentials_list)
  end
  
  def extractCredsFromJson(credentials_list)
    
    if credentials_list.nil?
      return
    end
    url = credentials_list[URL_STRING]
    user_id = credentials_list[USER_ID_STRING]
    pwd = credentials_list[PASSWORD_STRING]
    instance_id = credentials_list[INSTANCE_ID_STRING]
    api_key= credentials_list[IAM_API_KEY_STRING]
    if url.nil? || instance_id.nil?
      return
    end
    if (user_id.nil? || pwd.nil?) && api_key.nil?
      return
    end
    iam_enabled=api_key.nil??false:true
    return [url, user_id, pwd, instance_id, api_key, iam_enabled]
  end
	
end