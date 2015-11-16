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

require 'net/http'
require 'json'
require_relative './hmac.rb'

class RESTClient	
=begin
	This object is used to make the REST API calls using credentials found in your service account object 
	and store the results of the REST API calls.
	
	bundles = list of all the bundles associated to your service instance
	language = a map of the languages of your translated string in the following format: {sourceLanguage : [targetLanguages]}
	resource_data = hash containing your translalated strings in the following format: {locale: {key : translated_value}}
	service_account = ServiceAccount object that contains the credentials necessary to make the REST API calls. See service_account.rb
	bundle_id = ID of the bundle that contains the translated strings
=end
	
	BUNDLE_STRING ||= "bundle"
	SOURCE_LANGUAGE_STRING ||= "sourceLanguage"
	TARGET_LANGUAGES_STRING ||= "targetLanguages"
	RESOURCE_STRINGS ||= "resourceStrings"
	BUNDLE_ID_STRING ||= "bundleIds"
	
	URL_PATH ||= "v2/bundles"
	
	@supportedLangs = ['en','de','es','fr','it', 'ja','ko', 'pt-BR', 'zh-Hans', 'zh-Hant'] 
	@expectedMatches = {
            'en': 'en', 'en_US': 'en', 'en-US': 'en',
            'de': 'de', 'de_at': 'de', 'de-at': 'de',
            'es': 'es', 'es_mx': 'es', 'es-mx': 'es',
            'fr': 'fr', 'fr_FR': 'fr', 'fr-Fr': 'fr', 'fr_CA': 'fr',
            'it': 'it', 'it_ch': 'it', 'it-ch': 'it', 'it-IT': 'it',
            'ja': 'ja', 'ja_JA': 'ja', 'ja-JA': 'ja',
            'ko': 'ko', 'ko_KO': 'ko', 'ko-KO': 'ko',
            'pt-BR': 'pt-BR', 'pt': nil,
            'zh': 'zh-Hans', 'zh-tw': 'zh-Hant', 'zh-cn': 'zh-Hans',
            'zh-hk': 'zh-Hant', 'zh-sg': 'zh-Hans',
    }
	
	def initialize(service_account, bundle_id, locale = "")
		@bundles = []
		@languages = {}
		@resource_data = {}
		@service_account = service_account
		@bundle_id = bundle_id
		
		get_resource_strings(locale)
	end
	
	def get_bundles
		if @bundles.empty?
			url_string = "#{@service_account.get_url_string}/#{@service_account.get_instance_id}/#{URL_PATH}"
			response = make_request(url_string, service_account)
			@bundles = request[BUNDLE_ID_STRING]
		end
		@bundles
	end
	
	#bundle info contains the languages - used get_bundle_info to reflect current API
	def get_bundle_info
		if @languages.empty?
			url_string = "#{@service_account.get_url_string}/#{@service_account.get_instance_id}/#{URL_PATH}/#{@bundle_id}"
			puts url_string
			response = make_request(url_string, @service_account)
			source_language = response[BUNDLE_STRING][SOURCE_LANGUAGE_STRING]
			@languages[source_language] = response[BUNDLE_STRING][TARGET_LANGUAGES_STRING]
		end
		@languages
	end
	
	def get_resource_strings(locale = "")
		if @resource_data.empty?
			target_languages = []

			if locale.empty?
				language_dictionary = get_bundle_info
				target_languages = get_target_languages.dup
				target_languages << get_source_language
			else
				if (!@supportedLangs.include? locale)
					if (@expectedMatches.has_key? locale)
						locale = @expectedMatches[locale]
					else
						raise "Unsupported Locale: #{locale}"
					end
				end
				target_languages << locale
			end

			get_translations(@service_account, target_languages, @bundle_id)
		else
			@resource_data
		end
	end
		
	def has_language(language)
		if language.equal? get_source_language
			return true
		end
		get_target_languages.each do |lang|
			if lang.equal? language
				return true
			end
		end
		
		return false
	end
	
	def get_source_language
		@languages.keys[0]
	end
	
	def get_target_languages
		source_language = get_source_language
		@languages[source_language]
	end
	
	def get_service_account
		@service_account
	end
	
	def get_bundle_id
		@bundle_id
	end
	
	def set_resource_strings (map)
		@resource_data = map
	end

	def set_service_account(sa)
		@service_account = sa
	end
	
	def set_bundle_id(name)
		@bundle_id = name
	end
	
private

	def make_request(url, service_account, basic_auth = false)
		uri = URI.parse(url.to_s)
		request = Net::HTTP::Get.new uri.path
		
		if basic_auth
			request.basic_auth(service_account.get_user_id, service_account.get_password)
		else
			hmac = HMAC.new
			d = hmac.get_rfc1123_date
			request["Date"] = d
			request["Authorization"] = hmac.get_auth_credentials(service_account.get_user_id, service_account.get_password, "GET", url,d, "").strip
		end
		
		response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') {|http| 
			http.request(request)
		}
		json_response = JSON.parse(response.body)

		if json_response["status"] != "SUCCESS"
			raise "Invalid HTTP Request #{json_response["message"]}"
		end
		
		return json_response
	end
	
	def get_translations(service_account, locale_list, project_name)
		url_string = "#{service_account.get_url_string}/#{service_account.get_instance_id}/#{URL_PATH}/#{project_name}"
		
		locale_list.each do |language|
			target_lang_url = "#{url_string}/#{language}"
			response = make_request(target_lang_url, service_account)
			
			@resource_data[language] = {}

			response[RESOURCE_STRINGS].each do |key, value|
				I18n.backend.store_translations(language, {key => value}, :escape => false)
				@resource_data[language][key] = value
			end
		end
	end
end