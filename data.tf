data "terraform_remote_state" "openvpn" {
  backend = "http"
  config = {
    address  = var.openvpn_remote_state_address
    username = var.openvpn_username
    password = var.openvpn_access_token
  }
}