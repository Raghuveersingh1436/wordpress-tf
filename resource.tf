provider "aws" {
  region = "ap-south-1"
}

#step-1 creating vpc
resource "aws_vpc" "bunnyvpc" {
  cidr_block = var.ars_vpc
  tags = {
    Name = "ars-vpc"
  }
}

#step-2 creating subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.bunnyvpc.id
  cidr_block = var.pub_subnet
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
  tags = {
    Name = "Public subnet"
  }
}

#step-3 creating Igw
resource "aws_internet_gateway" "bunny-igw" {
  vpc_id = aws_vpc.bunnyvpc.id
  tags = {
    Name = "Bunny Igw"
  }
}

#step-4 creating public route table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.bunnyvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bunny-igw.id
  }
  tags = {
    Name = "Public route"
  }
}

#Associating Public Route
resource "aws_route_table_association" "pub-ass" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

#Creating Security Group for Public
resource "aws_security_group" "pub-sg" {
  vpc_id = aws_vpc.bunnyvpc.id
  #ssh inbound rule
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #httpd inbound rule
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #outbound rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Web Pub SG"
  }
}

#Creating EC2 instance
resource "aws_instance" "wordpress" {
  ami = "ami-0d92749d46e71c34c"
  vpc_security_group_ids = ["${aws_security_group.pub-sg.id}"]
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name = "fe"
  subnet_id = aws_subnet.public-subnet.id
  user_data = file("data.sh")
  tags = {
    Name = "Wordpress"
  }
}
