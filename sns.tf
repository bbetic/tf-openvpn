
resource "aws_sns_topic" "openvpn" {
  name              = "openvpn"
  kms_master_key_id = "alias/aws/sns"

}

resource "aws_sns_topic_subscription" "openvpn_subscription" {
  protocol  = "email"
  endpoint  = var.email
  topic_arn = aws_sns_topic.openvpn.arn
}
