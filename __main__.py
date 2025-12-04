import pulumi
import pulumi_aws as aws
import pulumi_tls as tls
import os

# Configuration
config = pulumi.Config()
aws_config = pulumi.Config("aws")
region = aws_config.get("region") or "us-east-1"
instance_type = config.get("instanceType") or "t2.micro"

# Config flag to toggle SSH access
# Default to True so initial provisioning works.
# We will flip this to False after retrieving the config.
ssh_open = config.get_bool("sshOpen")
if ssh_open is None:
    ssh_open = True

# Create an SSH Key Pair
key = tls.PrivateKey("vpn-key",
    algorithm="RSA",
    rsa_bits=4096
)

# Register the public key with AWS
key_pair = aws.ec2.KeyPair("vpn-key-pair",
    public_key=key.public_key_openssh
)

# Save the private key to a local file for SCP access
def write_private_key(content):
    with open("vpn_key.pem", "w") as f:
        f.write(content)
    os.chmod("vpn_key.pem", 0o400)

key.private_key_pem.apply(write_private_key)

# Security Group Rules
ingress_rules = [
    aws.ec2.SecurityGroupIngressArgs(
        protocol="udp",
        from_port=1194,
        to_port=1194,
        cidr_blocks=["0.0.0.0/0"],
        description="OpenVPN UDP"
    )
]

# Only add SSH ingress if the flag is enabled
if ssh_open:
    ingress_rules.append(
        aws.ec2.SecurityGroupIngressArgs(
            protocol="tcp",
            from_port=22,
            to_port=22,
            cidr_blocks=["0.0.0.0/0"],
            description="SSH (Temporary)"
        )
    )

group = aws.ec2.SecurityGroup("vpn-sg",
    description="VPN Security Group",
    ingress=ingress_rules,
    egress=[
        aws.ec2.SecurityGroupEgressArgs(
            protocol="-1",
            from_port=0,
            to_port=0,
            cidr_blocks=["0.0.0.0/0"],
        )
    ]
)

# AMI Lookup (Amazon Linux 2023)
ami = aws.ec2.get_ami(
    most_recent=True,
    owners=["amazon"],
    filters=[aws.ec2.GetAmiFilterArgs(
        name="name",
        values=["al2023-ami-2023.*-x86_64"]
    )]
)

# User Data
with open("user_data.sh.tpl", "r") as f:
    user_data = f.read()

# EC2 Instance
server = aws.ec2.Instance("vpn-server",
    instance_type=instance_type,
    ami=ami.id,
    key_name=key_pair.key_name,
    vpc_security_group_ids=[group.id],
    user_data=user_data,
    tags={
        "Name": "OpenVPN-JIT-Pulumi"
    }
)

# Outputs
pulumi.export("instance_ip", server.public_ip)
pulumi.export("private_key_pem", key.private_key_pem)
