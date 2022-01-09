resource "aws_security_group" "openvpn_sg" {
  name        = "openvpn_sg"
  description = "Ingress for OpenVPN"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = formatlist("%s/32", var.as_config.VPN_SERVER_DHCP_OPTION_DNS)
  }
    egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = formatlist("%s/32", var.as_config.VPN_SERVER_DHCP_OPTION_DNS)
  }
  dynamic "egress" {
    for_each = var.egress_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}