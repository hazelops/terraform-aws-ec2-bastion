#AWS SSM resources
resource "aws_iam_role" "ssm_bastion" {
  name               = "${var.name}-ssm-bastion"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2_ssm.json
}

resource "aws_iam_role_policy_attachment" "ssm_bastion" {
  role       = aws_iam_role.ssm_bastion.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "ssm-poc-instance-profile"
  role = aws_iam_role.ssm_bastion.name
}

data "aws_iam_policy_document" "assume_ec2_ssm" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
        "ssm.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}
