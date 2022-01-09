
variable "as_config" {
  type = object({
    VPN_SERVER_SESSION_EXPIRE             = optional(number)
    VPN_TLS_RERESH_INTERVAL               = optional(number)
    PROP_AUTOLOGIN                        = bool
    NEW_USER                              = optional(string)
    NEW_USER_PASSWORD                     = optional(string)
    NEW_GROUP                             = optional(string)
    AUTH_LOCAL_0_MIN_LEN                  = optional(number)
    PROP_REROUTE_GW_OVERRIDE              = optional(bool)
    PROP_BLOCK_LOCAL                      = optional(bool)
    CS_WEB_SERVER_NAME                    = optional(string)
    SA_SESSION_EXPIRE                     = optional(number)
    CS_OPENSSL_CIPHERSUITES               = optional(string)
    CS_TLS_VERSION_MIN                    = optional(string)
    ADMIN_UI_HTTPS_IP_ADDRESS             = optional(string)
    ADMIN_UI_HTTPS_PORT                   = optional(string)
    CS_HTTPS_IP_ADDRESS                   = optional(string)
    CS_HTTPS_PORT                         = optional(string)
    SSL_API_LOCAL_ADDR                    = optional(string)
    SSL_API_LOCAL_PORT                    = optional(string)
    VPN_SERVER_PORT_SHARE_SERVICE_ONLY    = optional(string)
    VPN_SERVER_PORT_SHARE_SERVICE_DISABLE = optional(string)
    VPN_SERVER_DHCP_OPTION_DNS            = list(string)
  })
  default = {
    NEW_USER                   = "openvpn"
    NEW_USER_PASSWORD          = "openvpn"
    PROP_AUTOLOGIN             = false
    VPN_SERVER_DHCP_OPTION_DNS = []
  }
}

variable "egress_ports" {
  type        = list(number)
  description = "list of egress ports"
  default     = [80, 443]
}