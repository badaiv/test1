module "users_group2" {
  source   = "terraform-aws-modules/iam/aws//modules/iam-user"
  version  = "5.39.0"
  for_each = toset(["Denys.Platon", "Ivan.Petrenko"])

  create_iam_user_login_profile = true
  create_iam_access_key         = true

  path = "/users/"

  name          = each.key
  force_destroy = true

  # we use pgp encryption here, because don't want to store plain secrets in state file
  # I'm using my private keybase, but in enterprise environments we should use custom pgp key
  pgp_key = "keybase:badaiv"

  password_reset_required = true
}

module "users_group1" {
  source   = "terraform-aws-modules/iam/aws//modules/iam-user"
  version  = "5.39.0"
  for_each = toset(["cli", "engine"])

  create_iam_user_login_profile = false
  create_iam_access_key         = true

  path = "/service_accounts/"

  name          = each.key
  force_destroy = true

  # we use pgp encryption here, because don't want to store plain secrets in state file
  # I'm using my private keybase, but in enterprise environments we should use custom pgp key
  pgp_key = "keybase:badaiv"

  password_reset_required = true
}

module "roleA" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  create_role = true

  role_name         = "roleA"
  role_requires_mfa = false
  allow_self_assume_role = true

  custom_role_policy_arns = [
    module.iam_policy_roleA.arn
  ]

  trusted_role_arns = values(module.users_group2).*.iam_user_arn
}

module "roleB" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  create_role = true

  role_name         = "roleB"
  role_requires_mfa = false
#  allow_self_assume_role = true


  trusted_role_arns = values(module.users_group2).*.iam_user_arn
}

module "roleC" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  providers = {
    aws = aws.account-1
  }

  create_role = true

  role_name         = "roleC"
  role_requires_mfa = false
  allow_self_assume_role = true

  custom_role_policy_arns = [
    module.iam_policy_roleC.arn
  ]

  trusted_role_arns = [
    module.roleB.iam_role_arn
  ]
}

data "aws_caller_identity" "account0" {}

module "iam_policy_roleA" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name = "roleA"
  path = "/"
  description = "All except IAM"

  policy = data.aws_iam_policy_document.roleA.json
}

module "iam_policy_roleC" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
  providers = {
    aws = aws.account-1
  }

  name = "roleC"
  path = "/"
  description = "Full Access to S3 aws-test-bucket"

  policy = data.aws_iam_policy_document.roleA.json
}

data "aws_iam_policy_document" "roleA" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }

  statement {
    effect  = "Deny"
    actions = [
      "iam:Add*",
      "iam:Create*",
      "iam:Deactivate*",
      "iam:Delete*",
      "iam:Detach*",
      "iam:Enable*",
      "iam:PassRole",
      "iam:Put*",
      "iam:Remove*",
      "iam:Resync*",
      "iam:Set*",
      "iam:Simulate*",
      "iam:Update*",
      "iam:Put*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "roleC" {
  statement {
    effect  = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:aws:s3:::aws-test-bucket",
      "arn:aws:s3:::aws-test-bucket/*"
    ]
  }
}
