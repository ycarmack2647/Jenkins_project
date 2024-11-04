# Bastion Host EC2 Instance (Bastion)
resource "aws_instance" "bastion_server" {
  ami                         = var.jenkins_ami
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet_1.id
  key_name                    = aws_key_pair.shon.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_server_sg.id]
  associate_public_ip_address = true


  provisioner "file" {
    source      = "${path.module}/mykey"
    destination = "/home/ec2-user/.ssh/id_rsa"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.initial_private_key
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/.ssh/id_rsa",
      "chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.initial_private_key
      host        = self.public_ip
    }
  }
  tags = {
    Name = "Bastion Server"
  }
}

# Web Application EC2 Instances in Private Subnets
resource "aws_instance" "web_app_servers" {
  count                       = 2
  ami                         = var.web_app_ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnet_1.id
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.alb_sg.id]
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              # Install your web application dependencies here
              mkdir -p /home/ec2-user/.ssh
              echo ${var.key_pair_name} >> /home/ec2-user/.ssh/authorized_keys
              chown -R ec2-user:ec2-user /home/ec2-user/.ssh
              chmod 700 /home/ec2-user/.ssh
              chmod 600 /home/ec2-user/.ssh/authorized_keys
              EOF

  tags = {
    Name = "Web App Server ${count.index + 1}"
  }
}

# Jenkins EC2 Instance 2
resource "aws_instance" "jenkins_server2" {
  ami                         = "ami-0fff1b9a61dec8a5f" # Replace with your preferred AMI
  instance_type               = "t2.micro"
  key_name                    = "mykey"
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http.id]
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              sudo yum upgrade -y
              sudo yum install java-17-amazon-corretto -y
              sudo yum install jenkins -y
              sudo systemctl enable jenkins
              sudo systemctl start jenkins
              # Optional: print Jenkins status to the logs
              sudo systemctl status jenkins
              # Optional: print the initial admin password to the logs (can be retrieved later)
              sudo cat /var/lib/jenkins/secrets/initialAdminPassword
              EOF

  tags = {
    Name = "Jenkins-Server2"
  }
}

# Output the private IP address of Jenkins Server 2
output "instance_private_ip" {
  description = "The private IP of the Jenkins EC2 instance"
  value       = aws_instance.jenkins_server2.private_ip
}

# Create an EC2 instance with the key pair
resource "aws_instance" "jenkins_server" {
  ami           = "ami-0fff1b9a61dec8a5f" # Amazon Linux 2 AMI ID
  instance_type = "t2.micro"

  key_name        = aws_key_pair.shon.key_name
  security_groups = [aws_security_group.webapp_sg.name]

  tags = {
    Name = "JenkinsServer"
  }

  # Provisioner to install Jenkins
  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install java-openjdk11 -y",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo yum install jenkins -y",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins"
    ]

    # Configure SSH connection
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa") # Reference to your private key file
      host        = self.public_ip
    }
  }
}
