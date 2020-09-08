#AWS SSM resources
resource "aws_iam_role" "ssm_role" {
  name               = "${var.name}-ssm-terraform"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy_attachment" "ssm_role" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = var.ssm_role
}

resource "aws_iam_instance_profile" "bastion" {
  name = "ssm-poc-instance-profile"
  role = aws_iam_role.ssm_role.name
}

data "aws_iam_policy_document" "assume" {
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
