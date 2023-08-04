
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}


#  resource "aws_instance" "web" {
#  ami           = "ami-0f5ee92e2d63afc18"
#  instance_type = "t2.micro"
#  key_name = "demo-linux-machine"
#
#  tags = {
#    Name = "Terraform-demo-instance-15"
#  }
# }


# Creating the VPC

resource "aws_vpc" "webapp-vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Webapp-VPC"
  }
}


#creating subnet

resource "aws_subnet" "webapp-subnet-1a" {
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = "10.10.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "Webapp-subnet-1A"
  }
}


resource "aws_subnet" "webapp-subnet-1b" {
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "Webapp-subnet-1B"
  }
}


resource "aws_subnet" "webapp-subnet-1c" {
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "ap-south-1c"
  
  tags = {
    Name = "Webapp-subnet-1C"
  }
}



resource "aws_instance" "webapp-01" {
  ami           = "ami-08d609799a7b54dd4"
  instance_type = "t2.micro"
  key_name = aws_key_pair.webapp-key-pair.id
  #key_name = "demo-linux-machine"
  subnet_id = aws_subnet.webapp-subnet-1a.id
  #associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "Webapp-01"
  }
}

resource "aws_instance" "webapp-02" {
  ami           = "ami-08d609799a7b54dd4"
  instance_type = "t2.micro"
  key_name = aws_key_pair.webapp-key-pair.id
  #key_name = "demo-linux-machine"
  subnet_id = aws_subnet.webapp-subnet-1b.id
  #associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "Webapp-02"
  }
}


resource "aws_key_pair" "webapp-key-pair" {
  key_name   = "webapp-key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/riZ58whfli3vYeC22+8rN1DpzKEGUeWmThvi/IehLypEX7iaLFO4TXwa6SBha84fbzRsFv5yfJ9964O4x0BEnJHiG03Z5COYB78D+VCah2wyTWcXLgJ6jDWBSMsjTqY9QhgtnVsFNdr8o6b6UQawPLYB1mpKWRYpIntK3Xt5Aonv8ehNgTEvkJwZYFtSH+EnF4pRBzw7ebNTLkTk4y7oJcMXFTPLGL57QoaqJ02fMHwtrAPH0tfCpMukJAccT+XqzojfUN67mqoUDM0AMszxu69DbaTy2B14o84w6Di7pExwCoxpl3EcJCo5QFOCdxRjDzwPGkGgul1GPpRhQYhFilQbFX+qqwZOaeFcLHGdwDS4Zt5TWamdECcNKZLMGA+xq4t3R7r1a+Yqvz0i3t9kDZHqdOBmBq3shO9JMZG9yYW2WoVXDOhI8MbEK9Mp8HOMH4AtDSNTPhP1r4hO1IE+qTTMymZoFRCvFiW5EMOzhciPVzCwQz2Hc8WemoLdCUk= Mahant@Pramukh-Mahant"
}

# Internet IGW

resource "aws_internet_gateway" "webapp-IGW" {
  vpc_id = aws_vpc.webapp-vpc.id

  tags = {
    Name = "Webapp-IGW"
  }
}

# Route Table

resource "aws_route_table" "webapp-RT" {
  vpc_id = aws_vpc.webapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp-IGW.id
  }

  tags = {
    Name = "Webapp-RT"
  }
}

resource "aws_route_table_association" "webapp-RT-asso-01" {
  subnet_id      = aws_subnet.webapp-subnet-1a.id
  route_table_id = aws_route_table.webapp-RT.id
}


resource "aws_route_table_association" "webapp-RT-asso-02" {
  subnet_id      = aws_subnet.webapp-subnet-1b.id
  route_table_id = aws_route_table.webapp-RT.id
}

# Security Group

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.webapp-vpc.id

  ingress {
    description      = "ssh from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  ingress {
    description      = "http from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow_SSH"
  }
}


# target group creation

resource "aws_lb_target_group" "webapp-TG" {
  name     = "webapp-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.webapp-vpc.id
}

resource "aws_lb_target_group_attachment" "webapp-TG_attach-01" {
  target_group_arn = aws_lb_target_group.webapp-TG.arn
  target_id        = aws_instance.webapp-01.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "webapp-TG_attach-02" {
  target_group_arn = aws_lb_target_group.webapp-TG.arn
  target_id        = aws_instance.webapp-02.id
  port             = 80
}

# LB Listener

resource "aws_lb_listener" "webapp-listener" {
  load_balancer_arn = aws_lb.webapp_LB.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp-TG.arn
  }
}

# Load balancer

resource "aws_lb" "webapp_LB" {
  name               = "Webapp-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ssh.id]
  subnets            = [aws_subnet.webapp-subnet-1a.id,aws_subnet.webapp-subnet-1b.id,aws_subnet.webapp-subnet-1c.id]


  tags = {
    Environment = "production"
  }
}