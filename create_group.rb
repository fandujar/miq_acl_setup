#!/usr/bin/env ruby

require 'net/http'
require 'yaml'
require 'uri'
require 'json'
require 'openssl'

config = YAML.load_file('config.yaml')

HEADER = {'Content-Type': 'application/json'}
API = "%{endpoint}/api/groups/" % { :endpoint => config['endpoint']}
JSON = '{"description":"%{name}","role":{"name":"%{role}"},"tenant":{"id":%{tenantid}},"filters":{"managed":[[%{tags}]]}}'

groups = config['create_groups']['groups']

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

def create_group(group)
    group = group.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

    puts "Creating new group ..."
    puts "Group %{name}, role: %{role}, tenantid: %{tenantid}, tags: %{tags}" % group
    
    body = JSON % group
    resource = URI.parse(API)
    
    response = Net::HTTP.start(resource.host, resource.port,:use_ssl => resource.scheme == 'https') do |http|
        request = Net::HTTP::Post.new(resource.request_uri, HEADER)
        request.basic_auth('admin','smartvm')
        request.body = body
        puts request.body
        http.request(request)
    end

    puts response.body
end

for group in groups
    create_group(group)
end
