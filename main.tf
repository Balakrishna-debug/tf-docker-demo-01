provider "aws" {

  region     = "eu-north-1"
}
data "aws_availability_zones" "all" {}

### Creating Security Group for EC2
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # "-1" represents all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}
## Creating Launch Template
resource "aws_launch_template" "example" {
  name_prefix           = "example-launch-template"
  image_id              = "${lookup(var.amis, var.region)}"
  instance_type         = "t3.micro"
  security_group_names = [ aws_security_group.instance.name]
  key_name              = "${var.key_name}"

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    dnf install -y docker
    systemctl start docker
    systemctl enable docker
    docker run -d -p 80:80 yeasy/simple-web
  EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "example" {
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  availability_zones = data.aws_availability_zones.all.names
  min_size           = 2
  max_size           = 10
  load_balancers     = ["${aws_elb.example.name}"]
  health_check_type  = "ELB"

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "terraform-example-elb"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
### Creating ELB
resource "aws_elb" "example" {
  name = "terraform-asg-example"
  security_groups = ["${aws_security_group.elb.id}"]
  availability_zones = data.aws_availability_zones.all.names
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 3
    interval = 60
    target = "HTTP:80/"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
}