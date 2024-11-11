#AWS SSM resources
resource "aws_iam_role" "this" {
  count              = var.asg_enabled ? 0 : 1
  name               = "${var.env}-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.this[count.index].json

}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.asg_enabled ? 0 : 1
  role       = aws_iam_role.this[count.index].name
  policy_arn = var.ssm_role
}

resource "aws_iam_instance_profile" "this" {
  count = var.asg_enabled ? 0 : 1
  name  = "${var.env}-${var.name}"
  role  = aws_iam_role.this[count.index].name
}

data "aws_iam_policy_document" "this" {
  count = var.asg_enabled ? 0 : 1
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
