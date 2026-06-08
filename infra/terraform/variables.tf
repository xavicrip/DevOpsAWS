# Variables de entrada. Sus valores se definen en terraform.tfvars (no se sube a git)
# o por línea de comandos. Mantener configuración fuera del código es buena práctica IaC.

variable "aws_region" {
  description = "Región de AWS donde se crea todo."
  type        = string
  default     = "us-east-1"
}

variable "entorno" {
  description = "Nombre del entorno (dev, staging, prod). Se usa en nombres y etiquetas."
  type        = string
  default     = "dev"
}

variable "nombre_proyecto" {
  description = "Prefijo para nombrar los recursos."
  type        = string
  default     = "registro-certificados"
}

# --- Conexión con GitHub ---

variable "github_repo_url" {
  description = "URL HTTPS del repositorio en GitHub (ej. https://github.com/usuario/repo)."
  type        = string
}

variable "github_branch" {
  description = "Rama que dispara los despliegues."
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "Personal Access Token de GitHub con permisos de repo (para Amplify y CodePipeline). SECRETO."
  type        = string
  sensitive   = true
}

# --- Configuración de la DApp ---

variable "sepolia_rpc_url" {
  description = "URL del nodo RPC (Alchemy/Infura) para que CodeBuild despliegue el contrato en Sepolia."
  type        = string
  default     = ""
  sensitive   = true
}
