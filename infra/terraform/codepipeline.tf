# CodePipeline + CodeBuild — pipeline CI/CD "on-chain" dentro de AWS.
# Origen (GitHub) -> Build (compila, prueba y despliega el contrato con Hardhat).
# Complementa a Amplify, que se encarga del frontend.

# ---------------------------------------------------------------------------
# Bucket S3 para los artefactos del pipeline.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "artefactos" {
  bucket        = "${var.nombre_proyecto}-${var.entorno}-artefactos-${data.aws_caller_identity.actual.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "artefactos" {
  bucket                  = aws_s3_bucket.artefactos.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_caller_identity" "actual" {}

# ---------------------------------------------------------------------------
# Conexión con GitHub (CodeStar Connections).
# OJO: tras `terraform apply` queda en estado PENDING; hay que autorizarla a mano
# en la consola de AWS (Developer Tools > Connections). Ver guias/05-despliegue-aws.md.
# ---------------------------------------------------------------------------
resource "aws_codestarconnections_connection" "github" {
  name          = "${var.nombre_proyecto}-${var.entorno}-gh"
  provider_type = "GitHub"
}

# ---------------------------------------------------------------------------
# Rol IAM para CodeBuild.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "codebuild" {
  name = "${var.nombre_proyecto}-${var.entorno}-codebuild"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild" {
  name = "permisos-codebuild"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:GetBucketLocation"]
        Resource = [
          aws_s3_bucket.artefactos.arn,
          "${aws_s3_bucket.artefactos.arn}/*"
        ]
      },
      {
        # Leer secretos (RPC URL, clave privada) desde SSM Parameter Store.
        Effect   = "Allow"
        Action   = ["ssm:GetParameters", "ssm:GetParameter"]
        Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.actual.account_id}:parameter/${var.nombre_proyecto}/*"
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# Proyecto CodeBuild — ejecuta buildspec.yml (compile + test + deploy contrato).
# ---------------------------------------------------------------------------
resource "aws_codebuild_project" "build" {
  name         = "${var.nombre_proyecto}-${var.entorno}-build"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "NOMBRE_PROYECTO"
      value = var.nombre_proyecto
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

# ---------------------------------------------------------------------------
# Rol IAM para CodePipeline.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "codepipeline" {
  name = "${var.nombre_proyecto}-${var.entorno}-codepipeline"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "permisos-codepipeline"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:GetBucketLocation"]
        Resource = [aws_s3_bucket.artefactos.arn, "${aws_s3_bucket.artefactos.arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"]
        Resource = aws_codebuild_project.build.arn
      },
      {
        Effect   = "Allow"
        Action   = ["codestar-connections:UseConnection"]
        Resource = aws_codestarconnections_connection.github.arn
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# El pipeline: Source (GitHub) -> Build (CodeBuild).
# ---------------------------------------------------------------------------
resource "aws_codepipeline" "pipeline" {
  name     = "${var.nombre_proyecto}-${var.entorno}"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artefactos.bucket
    type     = "S3"
  }

  stage {
    name = "Origen"
    action {
      name             = "GitHub"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["codigo_fuente"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = replace(replace(var.github_repo_url, "https://github.com/", ""), ".git", "")
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "CompilarProbarDesplegar"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["codigo_fuente"]
      output_artifacts = ["artefacto_build"]

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }
}
