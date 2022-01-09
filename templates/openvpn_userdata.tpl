#!/bin/sh

yum -y remove openvpn-as-yum || true
yum -y install https://as-repository.openvpn.net/as-repo-amzn2.rpm
yum -y install openvpn-as

cd /usr/local/openvpn_as/scripts

./sacli start
### Session options
%{ if config.VPN_SERVER_SESSION_EXPIRE != null } 
./sacli --key "vpn.server.session_expire" --value ${config.VPN_SERVER_SESSION_EXPIRE} ConfigPut
%{ endif }
%{ if config.VPN_TLS_RERESH_INTERVAL != null } 
./sacli --key "vpn.tls_refresh.interval" --value ${config.VPN_TLS_RERESH_INTERVAL} ConfigPut
%{ endif }
#././sacli --user <USER_OR_GROUP> --key "prop_isec" --value 300 UserPropPut
#././sacli --user <USER_OR_GROUP> --key "prop_ibytes" --value 100000 UserPropPut

### DEFAULT User and Group options
%{ if config.PROP_AUTOLOGIN } 
./sacli --user __DEFAULT__ --key "prop_autologin" --value "true" UserPropPut
%{ endif }
%{ if config.NEW_USER != null } 
./sacli --user ${config.NEW_USER} --key "type" --value "user_connect" UserPropPut
%{ if config.NEW_USER_PASSWORD != null }
    ./sacli --user ${config.NEW_USER} --new_pass ${config.NEW_USER_PASSWORD} SetLocalPassword
%{ endif }
%{ endif }
%{ if config.NEW_GROUP != null } 
./sacli --user ${config.NEW_GROUP} --key "type" --value "group" UserPropPut
./sacli --user ${config.NEW_GROUP} --key "group_declare" --value "true" UserPropPut
%{ endif }
%{ if config.AUTH_LOCAL_0_MIN_LEN != null } 
./sacli --key "auth.local.0.min_len" --value ${config.AUTH_LOCAL_0_MIN_LEN} ConfigPut
%{ endif }
%{ if config.PROP_REROUTE_GW_OVERRIDE != null } 
./sacli --user __DEFAULT__ --key "prop_reroute_gw_override" --value ${config.PROP_REROUTE_GW_OVERRIDE} UserPropPut
%{ endif }
%{ if config.PROP_BLOCK_LOCAL != null } 
./sacli --user __DEFAULT__ --key "prop_block_local" --value "true" UserPropPut
%{ endif }

### Web Service settings
%{ if config.CS_WEB_SERVER_NAME != null }
./sacli --key "cs.web_server_name" --value ${config.CS_WEB_SERVER_NAME} ConfigPut
%{ endif }
%{ if config.SA_SESSION_EXPIRE != null }
./sacli --key "sa.session_expire" --value ${config.SA_SESSION_EXPIRE} ConfigPut
%{ endif }
%{ if config.CS_OPENSSL_CIPHERSUITES != null }
./sacli --key "cs.openssl_ciphersuites" --value ${config.CS_OPENSSL_CIPHERSUITES} ConfigPut
%{ endif }
%{ if config.CS_TLS_VERSION_MIN != null }
./sacli --key "cs.tls_version_min" --value ${config.CS_TLS_VERSION_MIN} ConfigPut
%{ endif }
%{ if config.ADMIN_UI_HTTPS_IP_ADDRESS != null }
./sacli --key "admin_ui.https.ip_address" --value ${config.ADMIN_UI_HTTPS_IP_ADDRESS} ConfigPut
%{ endif }
%{ if config.ADMIN_UI_HTTPS_PORT != null }
./sacli --key "admin_ui.https.port" --value ${config.ADMIN_UI_HTTPS_PORT} ConfigPut
%{ endif }
%{ if config.CS_HTTPS_IP_ADDRESS != null }
./sacli --key "cs.https.ip_address" --value ${config.CS_HTTPS_IP_ADDRESS} ConfigPut
%{ endif }
%{ if config.CS_HTTPS_PORT != null }
./sacli --key "cs.https.port" --value ${config.CS_HTTPS_PORT} ConfigPut
%{ endif }
%{ if config.SSL_API_LOCAL_ADDR != null }
./sacli --key "ssl_api.https.local_addr" --value ${config.SSL_API_LOCAL_ADDR} ConfigPut
%{ endif }
%{ if config.SSL_API_LOCAL_PORT != null }
./sacli --key "ssl_api.https.port" --value ${config.SSL_API_LOCAL_PORT} ConfigPut
%{ endif }
%{ if config.VPN_SERVER_PORT_SHARE_SERVICE_ONLY != null } 
./sacli --key "vpn.server.port_share.enable" --value "true" ConfigPut
./sacli --key "vpn.server.port_share.service" --value ${config.VPN_SERVER_PORT_SHARE_SERVICE_ONLY} ConfigPut
%{ endif }
%{ if config.VPN_SERVER_PORT_SHARE_SERVICE_DISABLE != null } 
./sacli --key "vpn.server.port_share.enable" --value "false" ConfigPut
./sacli --key "vpn.server.port_share.service" --value "custom" ConfigPut
%{ endif }
%{ if length(config.VPN_SERVER_DHCP_OPTION_DNS) > 0 } 
./sacli --key "vpn.client.routing.reroute_dns" --value "custom" ConfigPut
./sacli --key "vpn.server.routing.gateway_access" --value "true" ConfigPut
./sacli --key "vpn.server.dhcp_option.dns.0" --value "${config.VPN_SERVER_DHCP_OPTION_DNS[0]}" ConfigPut
    %{ if length(config.VPN_SERVER_DHCP_OPTION_DNS) > 0 }
        ./sacli --key "vpn.server.dhcp_option.dns.1" --value "${config.VPN_SERVER_DHCP_OPTION_DNS[1]}" ConfigPut

    %{ endif }

%{ endif }

./sacli --key "host.name" --value $( ./sacli IP | tr -d ':' ) ConfigPut

### Authentication Options and command line Config
# https://openvpn.net/vpn-server-resources/authentication-options-and-command-line-Configuration/

./sacli start

yum -y update