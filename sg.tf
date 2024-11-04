# Security Group for Jenkins Server
resource "aws_security_group" "bastion_server_sg" {
  name        = "jenkins_sg"
  description = "Allow SSH and HTTP access to Jenkins server"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["your ip/32"] # Replace YOUR_IP with your actual IP address
  }

  ingress {
    description = "Bastion Web Interface"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["your ip/32"] # Replace with allowed IPs
  }

  ingress {
    description = "Bastion Web Interface"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["your ip/32"] # Replace with allowed IPs
  }

  ingress {
    description = "Bastion Web Interface"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["your ip/32"] # Replace with allowed IPs
  }

  ingress {
    description = "Bastion Web Interface"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with allowed IPs
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion Security Group"
  }
}

# Security Group for Web Application Servers
resource "aws_security_group" "web_app_sg" {
  name        = "web_app_sg"
  description = "Allow traffic to web application servers"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "SSH from Jenkins Server"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_server_sg.id]
  }

  ingress {
    description     = "HTTP from Jenkins Server"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_server_sg.id]
  }

  ingress {
    description     = "HTTPS from Jenkins Server"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_server_sg.id]
  }

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web App Security Group"
  }
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTP and HTTPS traffic to ALB"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB Security Group"
  }
}

# Security Group to Allow SSH and HTTP (port 8080 for Jenkins)
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["your ip/32"] # Allow SSH from a specific IP
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["your ip/32"] # Allow HTTP access for Jenkins
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["your ip/32"] # Allow HTTPS access for Jenkins
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow SSH and HTTP Security Group"
  }
}

# Security Group for Jenkins server
resource "aws_security_group" "webapp_sg" {
  name_prefix = "jenkins-sg-"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP for security
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
