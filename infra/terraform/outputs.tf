# Valores útiles que Terraform muestra tras `terraform apply`.

output "amplify_app_id" {
  description = "ID de la app de Amplify."
  value       = aws_amplify_app.dapp.id
}

output "amplify_url" {
  description = "URL pública del frontend desplegado en Amplify."
  value       = "https://${var.github_branch}.${aws_amplify_app.dapp.default_domain}"
}

output "codepipeline_nombre" {
  description = "Nombre del pipeline de CodePipeline."
  value       = aws_codepipeline.pipeline.name
}

output "codestar_connection_arn" {
  description = "ARN de la conexión con GitHub. DEBES autorizarla manualmente en la consola (queda PENDING)."
  value       = aws_codestarconnections_connection.github.arn
}

output "bucket_artefactos" {
  description = "Bucket S3 con los artefactos del pipeline."
  value       = aws_s3_bucket.artefactos.bucket
}
