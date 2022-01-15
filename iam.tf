data "aws_iam_policy_document" "ec2-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_sns" {
  name               = "ec2_sns"
  assume_role_policy = data.aws_iam_policy_document.ec2-assume-role-policy.json
}

data "aws_iam_policy_document" "ec2_sns_fullaccess" {
  statement {
    actions   = ["sns:*"]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "sns_policy" {
  name = "sns_policy"
  role = aws_iam_role.ec2_sns.id

  policy = data.aws_iam_policy_document.ec2_sns_fullaccess.json
}

resource "aws_iam_instance_profile" "ec2_sns" {
  name = "ec2_sns"
  role = aws_iam_role.ec2_sns.name

}