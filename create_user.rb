#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'openssl'
require_relative 'create_group'

#HEADER = {'Content-Type': 'application/json'}
#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

def create_user(user, password)
    json_user = '{"userid":"%{userid}","password":"%{password}","name":"%{name}","group":{"id":%{group}}}'
    api = "%{endpoint}/api/users/" % { :endpoint => ENDPOINT}



    puts "Creating new admin..."
    puts "User #{user['id']} on group #{user['group']}, name #{user['name']} and password #{password}"
    body = json_user % {:userid => user['id'], :password => password, :name => user['name'], :group => get_groupid_byname(user['group'])}
    uri = URI.parse(api)

    response = Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Post.new(uri.request_uri, HEADER)
        request.basic_auth('admin','smartvm')
        request.body = body
        puts request.body
        http.request(request)
    end

    puts response.body
end