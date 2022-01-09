data "aws_region" "default" {}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "openvpn" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.nano"
  key_name               = "openvpn"
  vpc_security_group_ids = [aws_security_group.openvpn_sg.id]
  user_data = templatefile("./templates/openvpn_userdata.tpl", {
    config = var.as_config
  })
  tags = { "Name" : "openvpn" }
}

resource "aws_eip" "openvpn_eip" {
  vpc = true
}

resource "aws_eip_association" "openvpn_eip_to_ec2" {
  instance_id   = aws_instance.openvpn.id
  allocation_id = aws_eip.openvpn_eip.id
}

output "public_ip" { value = aws_eip.openvpn_eip.public_ip }
