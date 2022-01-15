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
  iam_instance_profile   = aws_iam_instance_profile.ec2_sns.name
  user_data = templatefile("./templates/openvpn_userdata.tpl", {
    config = var.as_config,
    snsarn = aws_sns_topic.openvpn.arn
    # region = data.aws_region.default.name
  })
  tags                        = { "Name" : "openvpn" }
  associate_public_ip_address = true
}

# resource "aws_eip" "openvpn_eip" {
#   vpc = true
# }

# resource "aws_eip_association" "openvpn_eip_to_ec2" {
#   instance_id   = aws_instance.openvpn.id
#   allocation_id = aws_eip.openvpn_eip.id
# }

# output "public_ip" { value = aws_eip.openvpn_eip.public_ip }
