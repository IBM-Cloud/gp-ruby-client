<!-- Copyright IBM Corp. 2015 Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License. --> 

#Ruby Client for Globalization Pipeline on IBM Bluemix.
--------------

##What is this?

This is a Ruby client for [Globalization Pipeline on IBM Bluemix](https://www.ng.bluemix.net/docs/services/GlobalizationPipeline/index.html). This service allows users to seamlessly translate their applications effectively thus satisfying the need to reach multiple locales. Translation for Ruby on Rails applications is typically done through the i18n gem and requires the user to provide translation files. With Globalization Pipeline, these files are no longer necessary; just upload a file containing key-value pairs of strings you want to translate and all the strings will be dynamically translated and ready to use in your application

--------------

## Licensing

This project is licensed under the [Apache License](License.txt)

-------------

##Sample Application

A sample application is provided [here](https://github.com/IBM-Bluemix/gp-ruby-sample). See the application's readme in the link for more details.

--------------

##Quickstart

Note: It is important to develop your application with the intention of using the translate function of the i18n gem. Develop your application as if you were going to provide the translation files.

[Click here for Ruby's i18n gem tutorial](http://guides.rubyonrails.org/i18n.html)

To familiarize yourself:

Create new Globalization Pipeline service instance
![Create new Globalization Pipeline service instance](https://ibm.box.com/shared/static/v59b5a19qjkfhxqaiwauz37nd9d8o8m2.gif)

Create new bundle
![Create new bundle](https://ibm.box.com/shared/static/8p2ytfm28smh29rl50c581gcfb4hsz8z.gif) 

To use Ruby Client for Globalization Pipeline
	
Add `gem 'gp-ruby-client'` in your gemfile. This will load up the Ruby SDK Gem and you can add require 'gp-ruby-client' in any file where you want to use the SDK.
If you want to use the translated strings locally, you may run `gem install gp-ruby-client` in your shell.

Inside your application controller, you would place initializer code to use the SDK.

Basic initialization code would look like this:

```Ruby 
before_filter :startUp

def startUp
  require 'gp-ruby-client'
  
  my_ruby_client = GP::Ruby::Client.new($bundle_id)
end
```
Using Ruby Client outside of Bluemix:

If you would like to use the Ruby Client outside of Bluemix, remember to add the following environment variables: GP_URL, GP_USER_ID, GP_PASSWORD, GP_INSTANCE_ID. These should correspond with the credentials in your Globalization Pipeline service instance.

----------------

##API Reference
----------------
##gp-ruby-client
---------------
Author: Visaahan Anandarajah

##class: GP::Ruby::Client
This object is meant to be the container of this entire SDK. This initializes all the objects necessary and allows to access and modify each object as necessary

#### Params
* bundle id
* locale (defaulted to "" - loads all the locales)
* ServiceAccount instance
* RESTClient instance
* CacheControl instance

####initialize
This functions initializes several objects, such as the ServiceAccount object and the RESTClient object

#### Params
* bundle_id

####get_bundle_id
Retrieves the name of your bundle.

####set_bundle_id
Sets the name of your bundle to the name you provide

#### Params
* bundle_id

####get_locale
Retrieves current locale of your application

#### set_locale
Sets the locale to a locale provided

#### Params
* locale

#### get_cache_control
Gets the CacheControl object that deals with when to update your application to retrieve new translations

#### get_service_account
Gets the ServiceAccount object that maps to your credentials and is needed to make the REST API calls

#### get_rest_client
Gets the RESTClient object that is used to make the REST API calls and to retrieve and store the results of those calls

#### disable_service
Disables the application from using the IBM Globalization service

#### enable_serivce
Enables the application to use the IBM Globalization service. Service already defaulted to this.

#### get_default_locale
Retrieves the http ACCEPT_LANGUAGE variable for your location

#### set_default_locale
Sets your locale to the default locale

##class: gp-ruby-client~ServiceAccount

This object acts as a storage for the user's credentials in order to make REST API Calls. 

#### initialize

Creates a new service account object. This function creates a service account object that will be used to identify the user either by using user-provided parameters, environment variables or vcap service variables. This object will contain everything necessary to make the appropriate REST API calls and receive the translations. Either you must provide all the params or none of them. If you would like for this to work outside of Bluemix, you would need to set the following environment variables: GP_URL, GP_USER_ID, GP_PASSWORD, GP_INSTANCE_ID as followed under credentials in your bound service

#### Params
* base URL String to call
* userId
* password
* instanceId
    
####get_url_string

Getter function to get object's URL String (url of the location of the resources)


####get_user_id

Getter function to get object's user id (for basic authentication purposes)


####get_password

Getter function to get object's password (for basic authentication purposes)


####get_instance_id

Getter function to get object's URL String (url of the location of the resources)

####set_url_string

Setter function to set object's URL String

#### Params
* url_string

####set_user_id

Setter function to set object's user id

#### Params
* user_id

####set_password

Setter function to set object's password

#### Params
* password

####set_instance_id

Setter function to set object's instance id

#### Params
* instance_id



## class: gp-ruby-client~RESTClient

This class is used to make the REST API calls and store the results of those calls

#### Params
* URL String (where to get the resources)
* resource_data (map of all the translations in the form {locale : {key : value}})
* servce_account (stores all the credentials)
* project_name
* locale

####initialize

This function is meant to create an object that makes the appropriate REST API calls and stores translations to be used by the application. You may provide a locale to search for translations in a specific languages. Should a locale not be provided, it will load translations for all languages specified in the bundle.

####Params
* service_account
* project_name
* locale (optional)
    
#### get_bundles

This function returns the name of all the bundles attached to the service you are using

#### get_bundle_info

Returns a hash of all the languages in the following format {source_language: [target_bundle_info]}

#### get_resource_strings
Populates the resource_data hash with all the translations. If you specify a specific locale, it will load only that locale, else it will load all the locales

####Params
* locale (optional)

#### get_source_language
Returns the language of the strings in the uploaded file

#### get_target_languages
Returns a list of languages you indicated you wanted your strings to be translated to

#### has_language
Returns true if language is either source language or in list of target languages else false.

#### Params
* language

#### get_resource_data

Getter funtion to get the hash where object stores the translated strings.


#### get_service_account
Get the ServiceAccount object whose credentials are used to make the REST API calls

#### get_bundle_id
Gets the id of your bundle

#### set_resource_strings

Setter function to set the hash which will store the translated strings

#### Params
* map of translated strings

   
#### set_service_account
Set the ServiceAccount object who's credentials the REST API calls will need

#### Params
* ServiceAccount

#### set_bundle_id
Set the id of the bundle that the REST API will called

####Params
* bundleId

## class : gp-ruby-client~CacheControl

This object is meant to control how frequent to application updates to retrieve new translations
#### Params
* number of seconds between each cache update
* last accessed time

#### get_ttl
Gets,in number of seconds, how frequently the cache updates

#### get_last_accessed_time
Gets the time the application was last accessed

#### set_ttl
Sets how frequent cache should update

#### Params
* number of seconds

#### set_last_accessed_time
Set the time application was last accessed

#### Params
* last accessed time

#### turn_off_cache_update
Set the cache update interval very high to a point where cache will rarely update

#### always_cache_update
Set the cache update interval to 0 so cache updates everytime the application loads


