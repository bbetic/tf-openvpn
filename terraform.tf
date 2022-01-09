terraform {
  backend "http" {
    config = {
      address  = var.openvpn_remote_state_address
      username = var.openvpn_username
      password = var.openvpn_access_token
    }
  }
  experiments = [module_variable_optional_attrs]

}
provider "aws" {
  region = "us-east-1"
}