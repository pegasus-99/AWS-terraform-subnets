data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Create VPC with CIDR block 10.0.0.0/16  
resource "aws_vpc" "parth-tf-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = random_pet.random_pet.id
  }
}

# Create an NACL with inbound rules for SSH, HTTP, HTTPS, RDP, and outbound rules for all traffic
resource "aws_network_acl" "parth-tf-nacl" {
  vpc_id = aws_vpc.parth-tf-vpc.id
  subnet_ids = [aws_subnet.parth-tf-public-subnet.id, aws_subnet.parth-tf-private-subnet.id]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${chomp(data.http.myip.body)}/32"
    from_port  = 22
    to_port    = 22
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "${chomp(data.http.myip.body)}/32"
    from_port  = 3389
    to_port    = 3389
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 27017
    to_port    = 27017
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 600
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 49152
    to_port    = 65535
  }
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
    Name = random_pet.random_pet.id
  }
}


# Create Internet Gateway
resource "aws_internet_gateway" "parth-tf-igw" {
  vpc_id = aws_vpc.parth-tf-vpc.id
  tags = {
    Name = random_pet.random_pet.id
  }
}

# Create Public Route Table
resource "aws_route_table" "parth-tf-public-rt" {
  vpc_id = aws_vpc.parth-tf-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.parth-tf-igw.id
  }
  tags = {
    Name = random_pet.random_pet.id
  }
}

# Create Public Subnet
resource "aws_subnet" "parth-tf-public-subnet" {
  vpc_id                  = aws_vpc.parth-tf-vpc.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = random_pet.random_pet.id
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "parth-tf-public-rt-assoc" {
  subnet_id      = aws_subnet.parth-tf-public-subnet.id
  route_table_id = aws_route_table.parth-tf-public-rt.id
}

# Create Private Subnet
resource "aws_subnet" "parth-tf-private-subnet" {
  vpc_id            = aws_vpc.parth-tf-vpc.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = random_pet.random_pet.id
  }
}

# Create Public Web Windows Security Group for the public subnet with 
# port 80 open for HTTP traffic from anywhere and port 3389 open for RDP traffic from anywhere 
# and port 443 open for HTTPS traffic from anywhere

resource "aws_security_group" "parth-tf-public-web-sg" {
  name        = "parth-tf-public-web-sg"
  description = "Allow HTTP, HTTPS and RDP inbound traffic"
  vpc_id      = aws_vpc.parth-tf-vpc.id
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = random_pet.random_pet.id
  }
}

# Create Security Group for the Linux Web Server in the private subnet with
# SSH and MongoDB ports open for inbound traffic from the public subnet only

resource "aws_security_group" "parth-tf-private-web-sg" {
  name        = "parth-tf-private-web-sg"
  description = "Allow SSH and MongoDB inbound traffic from the public subnet"
  vpc_id      = aws_vpc.parth-tf-vpc.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/20"]
  }
  ingress {
    description = "MongoDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/20"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = random_pet.random_pet.id
  }
}

# Create a Windows EC2 instance in the public subnet and the public web security group attached

resource "aws_instance" "parth-tf-public-web-ec2" {
  ami                         = var.ami_id # ami-0d2f97c8735a48a15
  instance_type               = "t2.large"
  key_name                    = aws_key_pair.parth-tf-key-pair.key_name
  vpc_security_group_ids      = [aws_security_group.parth-tf-public-web-sg.id]
  subnet_id                   = aws_subnet.parth-tf-public-subnet.id
  associate_public_ip_address = true
  get_password_data = true #new
  tags = {
    Name = random_pet.random_pet.id
  }
}

# Create a key-pair and store the private key in a file
resource "tls_private_key" "parth-tf-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "parth-tf-private-key-file" {
  content  = tls_private_key.parth-tf-private-key.private_key_pem
  filename = "${random_pet.random_pet.id}.pem"
}

resource "aws_key_pair" "parth-tf-key-pair" {
  key_name   = random_pet.random_pet.id
  public_key = tls_private_key.parth-tf-private-key.public_key_openssh
}

#Save rdp file to local machine
resource "local_file" "parth-tf-windows-ec2-rdp" {
  content = <<EOF
auto connect:i:1
full address:s:${aws_instance.parth-tf-public-web-ec2.public_ip}
username:s:Administrator
audiomode:i:2
audiocapturemode:i:1
EOF
  filename = "parth-tf-windows-ec2.rdp"
  depends_on = [aws_instance.parth-tf-public-web-ec2] #Waits for the instance to be created
}

resource "null_resource" "execute_rdp" {
  triggers = {
    rdp_file = local_file.parth-tf-windows-ec2-rdp.filename
  }

provisioner "local-exec" {
  command     = "open ${local_file.parth-tf-windows-ec2-rdp.filename}"
  working_dir = path.module
  }
}

# create an output to print public IP address of the Windows EC2 instance
# and also name of the security group attached to the Windows EC2 instance,
# and also name of the windows instance

output "parth-tf-public-web-ec2-ip" {
  value = aws_instance.parth-tf-public-web-ec2.public_ip
}

output "parth-tf-public-web-ec2-sg" {
  value = aws_security_group.parth-tf-public-web-sg.name
}

output "parth-tf-public-web-ec2-name" {
  value = aws_instance.parth-tf-public-web-ec2.tags.Name
}

# Create an output to print my ip address
output "myip" {
  value = chomp(data.http.myip.body)
}



