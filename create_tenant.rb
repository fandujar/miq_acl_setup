#!/usr/bin/env ruby

require 'yaml'
require 'openssl'
require 'uri'
require 'net/http'


config = YAML.load_file('config.yaml')

ENDPOINT  = config['endpoint']
API_CREATE_TENANT = "%{endpoint}/api/tenants/" % { :endpoint => ENDPOINT}
API_GET_TENANT_ID = "%{endpoint}/api/tenants/?filter[]=name=%27%{tenant_name}%27&expand=resources&attributes=id"
JSON = '{"name":"%{name}","description":"%{description}","parent":{"id":"%{parent}"}}'
HEADER = {'Content-Type': 'application/json'}


tenants = config['create_tenant']['tenants']
DEFAULT_TENANT = config['create_tenant']['default_tenant']


OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

def edit_default_tenant()
    puts "Blz"

end

def create_tenant(tenant)
    puts "Creating new tenant..."
    puts "Tenant #{tenant['name']}, description #{tenant['description']}, parent #{tenant['parent']}"
    json_tenant = JSON % {:name => tenant['name'], :description => tenant['description'], :parent => tenant['parent']}
    uri = URI.parse(API_CREATE_TENANT)

    response = Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Post.new(uri.request_uri, HEADER)
        request.basic_auth('admin','smartvm')
        request.body = json_tenant
        puts request.body
        http.request(request)
    end

    puts response.body
end

def get_parent(tenant)
    if tenant['parent'] == DEFAULT_TENANT['name']
        return 1
    else
        return tenant['parent']
    end
end

# TODO - Aceitar tenant pelo nome

#edit_default_tenant()

for tenant in tenants
#    tenant['parent'] = get_parent(tenant)
#    puts tenant['parent']
    create_tenant(tenant)
end

