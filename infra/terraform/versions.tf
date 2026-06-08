# Versiones de Terraform y del proveedor AWS.
# Fijar versiones hace que la infraestructura sea reproducible (clave en IaC).

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }

  # Opcional pero recomendado: guardar el estado remoto en S3 para trabajo en equipo.
  # Descomenta y crea el bucket antes de usarlo (ver guias/05-despliegue-aws.md).
  # backend "s3" {
  #   bucket = "tu-bucket-de-estado-terraform"
  #   key    = "registro-certificados/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Proyecto  = "registro-certificados"
      Curso     = "Blockchain-UTPL"
      Entorno   = var.entorno
      ManagedBy = "Terraform"
    }
  }
}

# Provider alternativo SIN default_tags. Se usa solo para Amplify porque algunas
# cuentas educativas/sandbox de AWS aplican un SCP que deniega amplify:TagResource,
# lo que haría fallar la creación de la app si se intenta etiquetar.
provider "aws" {
  alias  = "sin_tags"
  region = var.aws_region
}
