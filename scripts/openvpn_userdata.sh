#!/bin/sh
# export admin_user=bbetic
# export admin_pw=bbetic\@openvpn
# export reroute_dns=1
# sudo apt-get update
# sudo apt-get upgrade

yum -y remove openvpn-as-yum || true
yum -y install https://as-repository.openvpn.net/as-repo-amzn2.rpm
yum -y install openvpn-as

cd /usr/local/openvpn_as/scripts

./sacli start
### Session options
if [ ! -z "${VPN_SERVER_SESSION_EXPIRE}" ] ; then 
    ./sacli --key "vpn.server.session_expire" --value "${VPN_SERVER_SESSION_EXPIRE}" ConfigPut
fi
if [ ! -z "${VPN_TLS_RERESH_INTERVAL}" ] ; then 
    ./sacli --key "vpn.tls_refresh.interval" --value "${VPN_TLS_RERESH_INTERVAL}" ConfigPut
fi
#././sacli --user <USER_OR_GROUP> --key "prop_isec" --value 300 UserPropPut
#././sacli --user <USER_OR_GROUP> --key "prop_ibytes" --value 100000 UserPropPut

### DEFAULT User and Group options
if [ ! -z "${PROP_AUTOLOGIN}" ] ; then 
    ./sacli --user __DEFAULT__ --key "prop_autologin" --value "true" UserPropPut
fi
if [ ! -z "${NEW_USER}" ] ; then 
    ./sacli --user ${NEW_USER} --key "type" --value "user_connect" UserPropPut
    if [ ! -z "${NEW_USER_PASSWORD}" ] ; then
        ./sacli --user ${NEW_USER} --new_pass "${NEW_USER_PASSWORD}" SetLocalPassword
    fi
fi
if [ ! -z "${NEW_GROUP}" ] ; then 
    ./sacli --user ${NEW_GROUP} --key "type" --value "group" UserPropPut
    ./sacli --user ${NEW_GROUP} --key "group_declare" --value "true" UserPropPut
fi
if [ ! -z "${AUTH_LOCAL_0_MIN_LEN}" ] ; then 
    ./sacli --key "auth.local.0.min_len" --value "${AUTH_LOCAL_0_MIN_LEN}" ConfigPut
fi
if [ ! -z "${PROP_REROUTE_GW_OVERRIDE}" ] ; then 
    ./sacli --user __DEFAULT__ --key "prop_reroute_gw_override" --value "${PROP_REROUTE_GW_OVERRIDE}" UserPropPut
fi
if [ ! -z "${PROP_BLOCK_LOCAL}" ] ; then 
    ./sacli --user __DEFAULT__ --key "prop_block_local" --value "true" UserPropPut
fi

### Web Service settings
if [ ! -z "${CS_WEB_SERVER_NAME}" ] ; then
    ./sacli --key "cs.web_server_name" --value "${CS_WEB_SERVER_NAME}" ConfigPut
fi
if [ ! -z "${SA_SESSION_EXPIRE}" ] ; then
    ./sacli --key "sa.session_expire" --value "${SA_SESSION_EXPIRE}" ConfigPut
fi
if [ ! -z "${CS_OPENSSL_CIPHERSUITES}" ] ; then
    ./sacli --key "cs.openssl_ciphersuites" --value "${CS_OPENSSL_CIPHERSUITES}" ConfigPut
fi
if [ ! -z "${CS_TLS_VERSION_MIN}" ] ; then
    ./sacli --key "cs.tls_version_min" --value "${CS_TLS_VERSION_MIN}" ConfigPut
fi
if [ ! -z "${ADMIN_UI_HTTPS_IP_ADDRESS}" ] ; then
    ./sacli --key "admin_ui.https.ip_address" --value "${ADMIN_UI_HTTPS_IP_ADDRESS}" ConfigPut
fi
if [ ! -z "${ADMIN_UI_HTTPS_PORT}" ] ; then
    ./sacli --key "admin_ui.https.port" --value "${ADMIN_UI_HTTPS_PORT}" ConfigPut
fi
if [ ! -z "${CS_HTTPS_IP_ADDRESS}" ] ; then
    ./sacli --key "cs.https.ip_address" --value "${CS_HTTPS_IP_ADDRESS}" ConfigPut
fi
if [ ! -z "${CS_HTTPS_PORT}" ] ; then
    ./sacli --key "cs.https.port" --value "${CS_HTTPS_PORT}" ConfigPut
fi
if [ ! -z "${SSL_API_LOCAL_ADDR}" ] ; then
    ./sacli --key "ssl_api.https.local_addr" --value "${SSL_API_LOCAL_ADDR}" ConfigPut
fi
if [ ! -z "${SSL_API_LOCAL_PORT}" ] ; then
    ./sacli --key "ssl_api.https.port" --value "${SSL_API_LOCAL_PORT}" ConfigPut
fi
if [ ! -z "${VPN_SERVER_PORT_SHARE_SERVICE_ONLY}" ] ; then 
    ./sacli --key "vpn.server.port_share.enable" --value "true" ConfigPut
    ./sacli --key "vpn.server.port_share.service" --value "${VPN_SERVER_PORT_SHARE_SERVICE_ONLY}" ConfigPut
fi
if [ ! -z "${VPN_SERVER_PORT_SHARE_SERVICE_DISABLE}" ] ; then 
    ./sacli --key "vpn.server.port_share.enable" --value "false" ConfigPut
    ./sacli --key "vpn.server.port_share.service" --value "custom" ConfigPut
fi

### Authentication Options and command line config
# https://openvpn.net/vpn-server-resources/authentication-options-and-command-line-configuration/

./sacli start