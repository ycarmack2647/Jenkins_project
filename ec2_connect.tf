resource "aws_iam_role" "ec2_instance_connect_role" {
  name = "ec2-instance-connect-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_instance_connect_policy" {
  name        = "ec2-instance-connect-policy"
  description = "Allows EC2 Instance Connect to push SSH keys to instances"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "ec2-instance-connect:SendSSHPublicKey",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ec2_instance_connect_policy" {
  role       = aws_iam_role.ec2_instance_connect_role.name
  policy_arn = aws_iam_policy.ec2_instance_connect_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_connect_profile" {
  name = "ec2-instance-connect-profile"
  role = aws_iam_role.ec2_instance_connect_role.name
}

resource "aws_instance" "bastion_server_01" {
  ami           = "ami-00f251754ac5da7f0" # Replace with your AMI ID
  instance_type = "t3.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_connect_profile.name

  # Other instance settings like security groups, key name, etc.
}

resource "aws_iam_user" "my_user" {
  name = "ec2-connect-user"
}

resource "aws_iam_user_policy" "ec2_instance_connect_access" {
  name = "ec2-instance-connect-user-policy"
  user = aws_iam_user.my_user.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "ec2-instance-connect:SendSSHPublicKey",
        "Resource" : "*"
      }
    ]
  })
}
