#!/usr/bin/env ruby

require 'net/http'
require 'yaml'
require 'uri'
require 'json'
require 'openssl'

config = YAML.load_file('config.yaml')

ENDPOINT  = config['endpoint']
API = "%{endpoint}/api/users/" % { :endpoint => ENDPOINT}
JSON = '{"userid":"%{userid}","password":"%{password}","name":"%{name}","group":{"id":2}}'
HEADER = {'Content-Type': 'application/json'}

users = config['create_user']['users']
default_password = config['create_user']['default_password']

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

def create_user(user, password)
    puts "Creating new admin..."
    puts "User #{user['id']}, name #{user['name']} and password #{password}"
    json_user = JSON % {:userid => user['id'], :password => password, :name => user['name']}
    uri = URI.parse(API)

    response = Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Post.new(uri.request_uri, HEADER)
        request.basic_auth('admin','smartvm')
        request.body = json_user
        puts request.body
        http.request(request)
    end

    puts response.body
end

for user in users
    create_user(user, default_password)
end
