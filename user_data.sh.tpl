#!/bin/bash
set -e

# Update and install dependencies
yum update -y
yum install -y git

# Get public IP (IMDSv2)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Install OpenVPN using Angristan's script
curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh

# Set environment variables for auto-install
export AUTO_INSTALL=y
export APPROVE_IP=$PUBLIC_IP
export ENDPOINT=$PUBLIC_IP
export IPV6_SUPPORT=n
export PORT_CHOICE=1
export PROTOCOL_CHOICE=1
export DNS=1
export COMPRESSION_ENABLED=n
export CUSTOMIZE_ENC=n
export CLIENT=client01
export PASS=1

# Run the installer
./openvpn-install.sh

# Move config to user home for SCP access
cp /root/client01.ovpn /home/ec2-user/client.ovpn
chown ec2-user:ec2-user /home/ec2-user/client.ovpn
chmod 644 /home/ec2-user/client.ovpn
