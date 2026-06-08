# AWS Amplify Hosting — sirve el frontend estático (HTML + ethers.js).
# Amplify conecta con GitHub, construye y despliega automáticamente en cada push
# a la rama configurada, con HTTPS y CDN global incluidos.

resource "aws_amplify_app" "dapp" {
  # Provider sin default_tags: evita amplify:TagResource (bloqueado por SCP en
  # cuentas educativas). Ver el comentario en versions.tf.
  provider = aws.sin_tags

  name       = "${var.nombre_proyecto}-${var.entorno}"
  repository = var.github_repo_url

  # Token de acceso a GitHub para que Amplify pueda leer el repo y registrar webhooks.
  access_token = var.github_token

  # Instrucciones de build de Amplify (frontend estático en la carpeta frontend/).
  # No hay paso de compilación: solo se publica el contenido de frontend/.
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        build:
          commands:
            - echo "Sin compilacion: frontend estatico"
      artifacts:
        baseDirectory: frontend
        files:
          - '**/*'
      cache:
        paths: []
  EOT

  # Redirige rutas no encontradas al index (SPA-friendly).
  custom_rule {
    source = "/<*>"
    target = "/index.html"
    status = "404-200"
  }

  enable_branch_auto_build = true
}

resource "aws_amplify_branch" "principal" {
  provider = aws.sin_tags

  app_id      = aws_amplify_app.dapp.id
  branch_name = var.github_branch

  enable_auto_build = true
  stage             = var.entorno == "prod" ? "PRODUCTION" : "DEVELOPMENT"
}
