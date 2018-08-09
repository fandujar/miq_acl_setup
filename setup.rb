require_relative 'create_user'
require_relative 'create_group'
require_relative 'create_tenant'
require 'yaml'


CONFIG = YAML.load_file('config.yaml')
ENDPOINT = CONFIG['endpoint']
HEADER = {'Content-Type': 'application/json'}
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

def create_users()
    default_password = CONFIG['create_user']['default_password']
    for user in CONFIG['create_user']['users']
        create_user(user, default_password)
    end
end

def create_groups()
    for group in CONFIG['create_group']['groups']
        create_group(group)
    end
end

def create_tenants()
    for tenant in CONFIG['create_tenant']['tenants']
        create_tenant(tenant)
    end        
end   

create_tenants()
create_groups()
create_users()