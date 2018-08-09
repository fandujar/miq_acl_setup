#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'openssl'
require 'json'
require_relative 'create_tenant'

#HEADER = {'Content-Type': 'application/json'}
#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

def create_group(group)
    api = "%{endpoint}/api/groups/" % { :endpoint => ENDPOINT}
    json_group = '{"description":"%{name}","role":{"name":"%{role}"},"tenant":{"id":%{tenantid}},"filters":{"managed":[%{tags}]}}'

    #group = group.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

    puts "Creating new group ..."
    puts "Group %{name}, role: %{role}, tenantid: %{tenantid}, tags: %{tags}"
    
    body = json_group % {:name => group['name'], :role => group['role'], :tenantid => get_tenantid_byname(group['tenant']), :tags => group['tags']}
    resource = URI.parse(api)
    
    response = Net::HTTP.start(resource.host, resource.port,:use_ssl => resource.scheme == 'https') do |http|
        request = Net::HTTP::Post.new(resource.request_uri, HEADER)
        request.basic_auth('admin','smartvm')
        request.body = body
        puts request.body
        http.request(request)
    end

    puts response.body
end

def get_groupid_byname(name)
    puts "Getting group id by name #{name}"
    api_get_tenants = "%{endpoint}/api/groups?expand=resources" % { :endpoint => ENDPOINT}
    uri = URI.parse(api_get_tenants)
    response = Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri.request_uri, HEADER)
        request.basic_auth('admin','smartvm')
        http.request(request)
    end

    for p in JSON.parse(response.body)['resources']
        if name == p['description']
            return p['id'].to_i
        end
    end
    return 0
end