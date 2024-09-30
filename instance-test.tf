provider "aws" {
    region = "us-west-1"
}

resource "aws_instance" "instance-test"{
  ami = "ami-0ff591da048329e00"
  instance_type = "t2.micro"
  key_name = "Demo-duty"
  vpc_security_group_ids = ["sg-0136d11c485276a4c"]
  tags = {
    Name = "Terraform_Instance"
  }
# Auto-assign public IP
  associate_public_ip_address = true
 # subnet_id = subnet-0e3da092ea0fb6ed3

# Output para mostrar la IP pública de la instancia
#output "instance_public_ip" {
 # description = "La IP pública de la instancia EC2"
#  value       = aws_instance.my_instance.public_ip
#}
root_block_device {
    volume_size = 64  # Size of the root volume in gigabytes
    volume_type = "gp2"  # Type of the root volume (e.g., gp2, io1, st1, sc1)
  }

user_data = <<-EOF
              #!/bin/bash
              # Actualiza el sistema
              apt-get update -y

              # Instala dependencias
              apt-get install -y curl unzip

              # Instala Docker
              curl -fsSL https://get.docker.com -o get-docker.sh
              sh get-docker.sh
              usermod -aG docker $(whoami)

              # Instala Terraform
              curl -fsSL https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_linux_amd64.zip -o terraform.zip
              unzip terraform.zip
              mv terraform /usr/local/bin/
              rm terraform.zip

              # Instala kubectl
              curl -LO "https://dl.k8s.io/release/v1.27.1/bin/linux/amd64/kubectl"
              chmod +x ./kubectl
              mv ./kubectl /usr/local/bin/kubectl

              # Instala Ansible
              apt-get install -y software-properties-common
              add-apt-repository ppa:ansible/ansible
              apt-get update
              apt-get install -y ansible

              # Instala AWS CLI v2
              curl "https://d1uj6qtbmh3dt5.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install
              rm awscliv2.zip

              EOF

}
