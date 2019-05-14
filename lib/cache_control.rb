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

class CacheControl
=begin
	This class is meant to control how often the application updates
	
	ttl = how many seconds the application waits before updating
	last_accessed = when you last accessed the application
=end
	@@cache_ttl = 600
	@@cache_last_accessed = Time.now
	
	def get_ttl
		@@cache_ttl
	end
	
	def set_ttl(seconds)
		@@cache_ttl = seconds
	end
	
	# Sets cache_ttl to a high number so it never (rarely) updates
	def turn_off_cache_update
		@@cache_ttl = 9999999999
	end
	
	# Sets cache_ttl to 0 so cache will update every time
	def always_cache_update
		@@cache_ttl = 0
	end
	
	def get_last_accessed_time
		@@cache_last_accessed
	end
	
	def set_last_accessed_time(time)
		@@cache_last_accessed = time
	end
end
