#!/usr/bin/python

import argparse
import os
import yaml

def _get_fuel_settings(env_id, setting_type):
    command = 'fuel {0} --env {1} --download'.format(setting_type, env_id)
    output = os.popen(command).read()
    output = '/root/' + output.split('/root/')[1]
    path_to_settings = output.replace('\n','')  
    settings = yaml.load(open(path_to_settings, 'r'))
    return settings

def _is_rally_container_exist():
    command = 'docker images fuel/rally'
    output = os.popen(command).read()
    return 'fuel/rally' in output

def _collect_env_vars(scenario):

    # get latest env id
    command = "fuel env | awk '{print \$1}' | tail -1"
    env_id = os.popen(command).read().replace('\n','')
    try:
        int(env_id)
    except ValueError:
        raise Exception("Environment doesn't exist or environment id "
                        "is defined incorrectly {0}".format(env_id))

    # get nsettings 
    net_settings = _get_fuel_settings(env_id, 'network')
    env_settings = _get_fuel_settings(env_id, 'settings')
    fuel_setting = yaml.load(open('/etc/fuel/astute.yaml', 'r'))
    

    fuel_host = fuel_setting['ADMIN_NETWORK']['ipaddress']
    auth_url = ('http://{0}'
                ':5000/v2.0/'.format(net_settings['management_vip']))
    murano_repo_url = (env_settings['editable']['murano_settings']
                                   ['murano_repo_url']['value'])                                 
    os_tenant = env_settings['editable']['access']['tenant']['value']
    os_user = env_settings['editable']['access']['user']['value']
    os_password = env_settings['editable']['access']['password']['value']

    command = ('fuel nodes | grep controller | grep True | grep -E -o '
               '"([0-9]{1,3}[\.]){3}[0-9]{1,3}" | head -1')
    http_proxy = os.popen(command).read()
    if not http_proxy:
        raise Exception('ERROR!Not found active controller node!')
    http_proxy = 'http://{0}:8888/'.format(http_proxy.replace('\n',''))

    env_vars = {
        'OS_AUTH_URL': auth_url,
        'OS_TENANT_NAME': os_tenant,
        'OS_USERNAME': os_user,
        'OS_PASSWORD': os_password,
        'MURANO_REPO_URL': murano_repo_url,
        'FUEL_HOST': fuel_setting['ADMIN_NETWORK']['ipaddress'],
        'HTTP_PROXY': http_proxy,
        'OS_NO_CACHE':'true',
        'OS_AUTH_STRATEGY':'keystone',
        'OS_REGION_NAME':'RegionOne',
        'CINDER_ENDPOINT_TYPE':'publicURL',
        'GLANCE_ENDPOINT_TYPE':'publicURL',
        'KEYSTONE_ENDPOINT_TYPE':'publicURL',
        'NOVA_ENDPOINT_TYPE':'publicURL',
        'NEUTRON_ENDPOINT_TYPE':'publicURL',
        'OS_ENDPOINT_TYPE':'publicURL',
        'FUEL_USERNAME':'root',
        'FUEL_PASSWORD':'r00tme',
        'HAOS_IMAGE':"TestVM",
        'HAOS_FLAVOR':"m1.micro",
        'SCENARIO':scenario
    }
    return env_vars

def _run_docker_container(env_vars):
    command = 'docker run -t -i '
    for key, value in env_vars.items():
        command += '-e {0}={1} '.format(key, value)
    command += 'fuel/rally /bin/bash -c /usr/local/bin/start.sh'
    output = os.popen(command).read().split('cat output.html\r\n')[1][:-10]
    with open('{0}_result.html'.format(env_vars['SCENARIO'][:-5]) , 'w') as f:
        f.write(output)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-s',
                        '--scenario',
                        required=True, 
                        help='name json file with test scenario')
    args = parser.parse_args()
    scenario = args.scenario

    if not _is_rally_container_exist():
        raise Exception("ERROR! Docker image fuel/rally doesn't exist!")

    _run_docker_container(_collect_env_vars(scenario))

if __name__ == "__main__":
    main()

