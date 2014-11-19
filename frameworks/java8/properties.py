#!/usr/bin/env python
from __future__ import print_function
import urllib2
import os
import sys
import re
import json
import requests
import consulate
import netifaces

# CONSUL_HOST is set as an environment variable
CONSUL_HOST=""
CONSUL_PORT=8500
CONSUL_KV_SCHEME = 'http'
CONSUL_KV_VERSION = 'v1'
CONSUL_KV_PREFIX='properties' 

# TODO: get datacenter from http://paas44-3.mobile.rz:8500/v1/agent/self
### TESTING - SET ENV VARIABLES HERE
#os.environ['APPLICATION_NAME'] = 'mobile-public-search-germany-webapp'
#os.environ['DATACENTER_NUMBER'] = '44'
#os.environ['SERVERCLASS_NAME'] = 'SEARCH'
#os.environ['CONSUL_HOST'] = '10.44.229.67'

file_output_path="/opt/etc"
environment_file_path="/opt/etc"
config_assembler_base_url='http://maven.corp.mobile.de/config-assembler'
APPLICATION_NAME=str(os.environ.get('APPLICATION_NAME')).lower()
DATACENTER_NUMBER=str(os.environ.get('DATACENTER_NUMBER','none'))
SERVERCLASS_NAME=str(os.environ.get('SERVERCLASS_NAME')).lower()
ENVIRONMENT_NAME=""

if (DATACENTER_NUMBER == str(46) or DATACENTER_NUMBER == str(38) or DATACENTER_NUMBER == str(47)):
    ENVIRONMENT_NAME='prod'
else:
    ENVIRONMENT_NAME='integra'

missing_envs=[]
properties={}

if (not APPLICATION_NAME or APPLICATION_NAME == "none"):
    missing_envs.append("APPLICATION_NAME")
if (not DATACENTER_NUMBER or DATACENTER_NUMBER == "none"):
    missing_envs.append("DATACENTER_NUMBER")
if (not SERVERCLASS_NAME or SERVERCLASS_NAME == "none"):
    missing_envs.append("SERVERCLASS_NAME")

if (len(missing_envs) > 0):
    print("ERROR: missing environment variables: " + ','.join(missing_envs), file=sys.stderr)
    sys.exit(1)
            
# get network interfaces for communicating with consul from within the container
default_gateway=""
if not CONSUL_HOST:
    if str(os.environ.get('CONSUL_HOST')) == 'None':
        try:
            default_gateway =  netifaces.gateways()['default'].values()[0][0]
            if not default_gateway:
                print("ERROR: CONSUL_HOST cannot be determined from default gateway " + str(default_gateway), file=sys.stderr)
                sys.exit(1)
                
            print("using ip %s as CONSUL_HOST" % default_gateway)
            CONSUL_HOST=default_gateway
        except KeyError as ke:
            print("ERROR: CONSUL_HOST cannot be determined from default gateway " + str(ke), file=sys.stderr)
            sys.exit(1)
            
    else:
        CONSUL_HOST=os.environ.get('CONSUL_HOST')
        print("using set variable consul_host " + os.environ.get('CONSUL_HOST'))
else:
    print("using set variable CONSUL_HOST = " + CONSUL_HOST)
    
# determine the container id  
container_id="dummyhost"

if os.path.exists('/proc/self/cgroup'):  
    with open('/proc/self/cgroup', 'r') as cgroup:
        for line in cgroup:
            hash_id = re.sub('.*\/','',line.strip().split(':')[-1])
            if hash_id:
                container_id = hash_id[0:12]
                properties['CONTAINER_ID'] = container_id
                
        if not container_id:
            print("could not identify container id from /proc/self/cgroup",file=sys.stderr)
            sys.exit(1)
                
# make properties directory if not exists     
try: 
    os.makedirs(file_output_path)
except OSError:
    if not os.path.isdir(file_output_path):
        print("ERROR: Could not create directory %s " % file_output_path,file=sys.stderr)
        sys.exit(1)
        
url=config_assembler_base_url + '/' + APPLICATION_NAME + '?common=all&rz=' + DATACENTER_NUMBER + '&env=' + ENVIRONMENT_NAME + '&confidential=' + ENVIRONMENT_NAME + '&serverclass=' + SERVERCLASS_NAME + '&application=' + APPLICATION_NAME + '&marketplace=germany' 
 
print("calling property assembler with url: " + url)

try:
    response = urllib2.urlopen(url, timeout=3)
except (RuntimeError,urllib2.HTTPError,urllib2.URLError) as e:
    print("ERROR: encountered error calling the property assembler: " + str(e),file=sys.stderr)
    sys.exit(1)

status_code = response.getcode()

if status_code != 200:
    print("ERROR: received response code %d from property assembler call (expected 200)" % status_code, file=sys.stderr)
    sys.exit(1)

#print(output)
# write properties to output file 
properties_file = file_output_path + os.path.sep + APPLICATION_NAME + '.properties'

target = open(properties_file, 'w')
target.write(response.read())
target.close()

response.close()

if os.path.getsize(properties_file) == 0:
    print("ERROR: %s has zero size. No properties were not downloaded from the property assembler" % properties_file,file=sys.stderr)
    sys.exit(1)
else:
    print("generated properties file: %s" % properties_file )


with open(properties_file) as f:
    for line in f:
        if not line.strip() or line.startswith('#') or not "=" in line:
            continue
        (key,value) = line.strip().split("=",1)
        properties[key]=value


environment_file = environment_file_path + os.path.sep + APPLICATION_NAME + '.env'

def create_env(dictionary,upper=False):
    env_dict={}     
    for key in dictionary:
        if upper:
            env_dict[(re.sub('[_]+','_',re.sub('[\W]','_',key)).upper())] = dictionary[key]
        else:
            env_dict[(re.sub('[_]+','_',re.sub('[\W]','_',key)))] = dictionary[key]
    return env_dict

with open(environment_file , 'w') as f:
    for k,v in create_env(properties).iteritems():
        print(k + '=' + '\'' + v + '\'', file=f)
        
if os.path.getsize(environment_file) == 0:
    print("ERROR: %s has zero size. Could not write environment variables file" % environment_file,file=sys.stderr)
    sys.exit(1)
else:
    print("generated environment variables file: %s" % environment_file )
        
print("using consul url: %s" % str(CONSUL_HOST) + ':' + str(CONSUL_PORT))

# we don't want to use http_proxy to talk to the local consul agent
os.environ['http_proxy']=''
os.environ['https_proxy']=''

session = consulate.Consulate(host=CONSUL_HOST,port=CONSUL_PORT)

CONSUL_BASE_URI=CONSUL_KV_SCHEME + '://' + str(CONSUL_HOST) + ':' + str(CONSUL_PORT) + '/' + str(CONSUL_KV_VERSION) + '/kv'

for k,v in create_env(properties).iteritems():  
    try:
        print("setting consul key %s = %s" % (CONSUL_KV_PREFIX + '/' + APPLICATION_NAME + '/' + container_id + '/' + k, v))
        session.kv[ CONSUL_KV_PREFIX + '/' + APPLICATION_NAME + '/' + container_id + '/' + k] = v
    except requests.exceptions.ConnectionError as e:
        print("ERROR: cannot connect to consul server api : " + str(e),file=sys.stderr) 
        sys.exit(1)
    except Exception as e:
        print("ERROR: cannot set consul kv data: " + str(e),file=sys.stderr) 
        sys.exit(1)
    
print("script finished")
#del session.kv[ CONSUL_KV_PREFIX + '/' + APPLICATION_NAME + '/' + container_id + '/' + k]
#print(session.kv.items())
#print(session.kv[CONSUL_KV_PREFIX + '/' + APPLICATION_NAME + '/' + container_id + '/' + 'MOBILE_DATASOURCE_PASSWORD'])

#print(APPLICATION_NAME)
#print("DC:" + DATACENTER_NUMBER)
#print(ENVIRONMENT_NAME)
#print(SERVERCLASS_NAME)
#print(properties)
