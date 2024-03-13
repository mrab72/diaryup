data "aws_availability_zones" "all" {}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key 
    region = "us-east-1"
  }
}

resource "aws_launch_configuration" "example" {
  image_id           = "ami-40d28157"
  instance_type      = "t2.micro"
  security_groups    = [aws_security_group.example.id]
  key_name = aws_key_pair.example.key_name
 /*
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              echo "${data.terraform_remote_state.db.outputs.address}" > index.html
              echo "${data.terraform_remote_state.db.outputs.port}" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  */
 user_data = templatefile(
               "${path.module}/user_data.sh",
               {
                 config = {
                  db_address  = "${data.terraform_remote_state.db.outputs.address}"
                  db_port     = "${data.terraform_remote_state.db.outputs.port}"
                  server_port = "${var.server_port}"
                 }
               }
              )
 lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"  # Specify your desired CIDR block
  enable_dns_support = true
  enable_dns_hostnames = true
  

  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "example" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"  # Specify your desired CIDR block for the subnet
  availability_zone       = "us-east-1a"  # Specify your desired availability zone 

  map_public_ip_on_launch = true  # This enables public IP assignment to instances in this subnet

  tags = {
    Name = "example-subnet"
  }
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
}

resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.example.id
  route_table_id = aws_route_table.example.id
}

resource "aws_key_pair" "example" {
  key_name = "maryam-ssh-key"
  public_key = file("${path.module}/id_rsa.pub") # Specify the path to your public key file
}

resource "aws_autoscaling_group" "example" {
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  launch_configuration = aws_launch_configuration.example.id
  
  #availability_zones   = data.aws_availability_zones.all.names
  load_balancers       = [aws_elb.example.name]
  health_check_type    = "ELB"

  vpc_zone_identifier  = [aws_subnet.example.id]

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_elb" "example" {
  name                = "terraform-asg-example"
  #availability_zones  = data.aws_availability_zones.all.names
  security_groups     = [aws_security_group.example.id]
  subnets           = [aws_subnet.example.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = var.server_port
    lb_protocol       = "http"
  }
  
  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

}

resource "aws_security_group" "example" {
  name   = "terraform-example-elb"
  
  vpc_id = aws_vpc.example.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = "22" 
    to_port     = "22"
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

