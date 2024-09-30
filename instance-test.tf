# Configuración del proveedor
provider "aws" {
  region = "us-west-1"  # Cambia esto a tu región deseada
}

# Variables para los parámetros de la instancia
variable "ami_id" {
  description = "ami-0d53d72369335a9d6"
  type        = string
}

variable "instance_type" {
  description = "t2.micro"
  type        = string
  default     = "t2.micro"  # Tipo de instancia por defecto
}

variable "key_name" {
  description = "Demo-duty"
  type        = string
}

variable "subnet_id" {
  description = "subnet-f8fbfca3"
  type        = string
}

variable "vpc_id" {
  description = "vpc-88a199ef"
  type        = string
}

variable "disk_size" {
  description = "Tamaño del disco en GB"
  type        = number
  default     = 20  # Tamaño del disco en GB por defecto
}


# Recurso para la instancia EC2
resource "aws_instance" "my_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id



# Configuración para el disco adicional
  root_block_device {
    volume_size = var.disk_size  # Tamaño del disco en GB
  }
  # Configuración para permitir acceso SSH (puerto 22)
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
# User data para instalar software
  user_data = <<-EOF
              #!/bin/bash
              # Actualizar el sistema
              apt-get update -y && apt-get upgrade -y

              # Instalar Ansible
              apt-get install -y software-properties-common
              add-apt-repository --yes --update ppa:ansible/ansible
              apt-get install -y ansible

              # Instalar Terraform
              apt-get install -y wget unzip
              wget https://releases.hashicorp.com/terraform/1.5.4/terraform_1.5.4_linux_amd64.zip
              unzip terraform_1.5.4_linux_amd64.zip
              mv terraform /usr/local/bin/

              # Instalar Docker
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
              add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              apt-get update -y
              apt-get install -y docker-ce

              # Instalar kubectl
              curl -LO "https://dl.k8s.io/release/v1.27.0/bin/linux/amd64/kubectl"
              chmod +x ./kubectl
              mv ./kubectl /usr/local/bin/kubectl

              # Instalar AWS CLI v2
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install

              # Limpiar
              rm terraform_1.5.4_linux_amd64.zip awscliv2.zip
	      
	      #crear el servicio y el sh del runner
	      touch rdrunner.service
	      touch rdrunner.sh
              EOF
  tags = {
    Name = "Terrafor-instance"
  }
}


# Recurso para el grupo de seguridad
resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow-ssh-"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["181.46.138.165/32"]
  }

  tags = {
    Name = "terraform-instanceallow_ssh"
  }
}


# Output para mostrar la IP pública de la instancia
output "instance_public_ip" {
  description = "La IP pública de la instancia EC2"
  value       = aws_instance.my_instance.public_ip
}
