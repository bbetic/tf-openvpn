terraform {
  backend "http" {
    address  = var.openvpn_remote_state_address
    username = var.openvpn_username
    password = var.openvpn_access_token
    lock_address = var.openvpn_lock_address ? var.openvpn_lock_address : "${var.openvpn_remote_state_address}/lock"
    unlock_address = var.openvpn_lock_address ? var.openvpn_lock_address : "${var.openvpn_remote_state_address}/lock"
  }
  experiments = [module_variable_optional_attrs]

}
provider "aws" {
  region = "us-east-1"
}