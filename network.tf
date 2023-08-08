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