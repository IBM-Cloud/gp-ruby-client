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

require 'time'
require 'openssl'
require 'base64'

class HMAC
=begin
	This class is meant to provide HMAC authentication when making the REST API calls.
=end
	GAAS_SCHEME_STRING ||= "GaaS-HMAC"
	SEPARATOR ||= ":"
	ENCODING ||= "ISO-8859-1"
	SHA1_STRING ||= "sha1"
	
	def get_auth_credentials(uid, secret, method, url, rfc1123date, body)
		signature = get_signature(secret,method,url,rfc1123date,body)
		if !signature.empty?
			output = "#{GAAS_SCHEME_STRING} #{uid}#{SEPARATOR}#{signature}"
			return output
		end
	end
	
	def get_signature(secret,method,url,rfc1123date,body)
		secret.encode(ENCODING)
		
		key = "#{method.encode(ENCODING)}\n#{url.encode(ENCODING)}\n#{rfc1123date.encode(ENCODING)}\n#{body.encode(ENCODING)}"
		
		digest = OpenSSL::Digest.new(SHA1_STRING)
		hex_string = OpenSSL::HMAC.digest(digest,secret,key)
		return Base64.encode64(hex_string)
	end
	
	def get_rfc1123_date
		Time.now.httpdate
	end
end