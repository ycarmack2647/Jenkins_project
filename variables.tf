# Variables
variable "region" {
  default = "us-east-1"
}

variable "jenkins_ami" {
  description = "AMI ID for the Jenkins server"
  default     = "ami-00f251754ac5da7f0" # Update with the latest Amazon Linux 2 AMI ID for your region
}

variable "web_app_ami" {
  description = "AMI ID for the web application servers"
  default     = "ami-06b21ccaeff8cd686" # Update with the latest Amazon Linux 2 AMI ID for your region
}

variable "initial_private_key" {
  type    = string
  default = "id_rsa.pem"
}

variable "initial_public_key" {
  type    = string
  default = "id_rsa.pub" # Replace with your initial public key path
}
