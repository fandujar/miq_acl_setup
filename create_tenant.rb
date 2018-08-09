#!/usr/bin/env ruby

require 'openssl'
require 'uri'
require 'net/http'


#config = YAML.load_file('config.yaml')
#ENDPOINT  = config['endpoint']
#API_GET_TENANT_ID = "%{endpoint}/api/tenants?expand=resources"

def edit_default_tenant()
    #TODO
    puts "Blz"
end

def create_tenant(tenant)
    json_tenant = '{"name":"%{name}","description":"%{description}","parent":{"id":"%{parent}"}}'
    api_create_tenant = "%{endpoint}/api/tenants/" % { :endpoint => ENDPOINT}

    puts "Creating new tenant..."
    puts "Tenant #{tenant['name']}, description #{tenant['description']}, parent #{tenant['parent']}"
    body = json_tenant % {:name => tenant['name'], :description => tenant['description'], :parent => get_tenantid_byname(tenant['parent'])}
    uri = URI.parse(api_create_tenant)

    response = Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Post.new(uri.request_uri, HEADER)
        request.basic_auth('admin','smartvm')
        request.body = body
        puts request.body
        http.request(request)
    end

    puts response.body
end

def get_tenantid_byname(name)
    puts "Getting tenant id by name #{name}"
    api_get_tenants = "%{endpoint}/api/tenants?expand=resources" % { :endpoint => ENDPOINT}
    uri = URI.parse(api_get_tenants)
    response = Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri.request_uri, HEADER)
        request.basic_auth('admin','smartvm')
        http.request(request)
    end

    for p in JSON.parse(response.body)['resources']
        if name == p['name']
            return p['id'].to_i
        end
    end
    return 0
end