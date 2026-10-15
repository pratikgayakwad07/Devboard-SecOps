resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
  ]

  tags = var.common_tags
}

data "aws_iam_policy_document" "github_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}/${var.github_repository}:ref:refs/heads/${var.github_branch}"]
    }
  }
}

resource "aws_iam_role" "ecr_push" {
  name               = "${var.project_name}-${var.environment}-github-ecr-push"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json

  tags = var.common_tags
}

data "aws_iam_policy_document" "ecr_push" {
  statement {
    sid       = "AuthenticateToECR"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "PushProjectImages"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = values(var.ecr_repository_arns)
  }
}

resource "aws_iam_role_policy" "ecr_push" {
  name   = "${var.project_name}-${var.environment}-ecr-push"
  role   = aws_iam_role.ecr_push.id
  policy = data.aws_iam_policy_document.ecr_push.json
}

resource "aws_iam_role" "cluster_deployer" {
  name               = "${var.project_name}-${var.environment}-github-eks-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json

  tags = var.common_tags
}

data "aws_iam_policy_document" "cluster_deployer" {
  statement {
    sid       = "DescribeDeploymentCluster"
    effect    = "Allow"
    actions   = ["eks:DescribeCluster"]
    resources = [var.cluster_arn]
  }

  statement {
    sid       = "ReadDatabaseCredentialForNamespaceSecret"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.database_secret_arn]
  }
}

resource "aws_iam_role_policy" "cluster_deployer" {
  name   = "${var.project_name}-${var.environment}-eks-deploy"
  role   = aws_iam_role.cluster_deployer.id
  policy = data.aws_iam_policy_document.cluster_deployer.json
}
