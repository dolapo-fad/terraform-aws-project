module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnet1_cidr = var.public_subnet1_cidr
  public_subnet2_cidr = var.public_subnet2_cidr
  private_subnet1_cidr = var.private_subnet1_cidr
  private_subnet2_cidr = var.private_subnet2_cidr
}
# LOADBALANCER

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_app.id]
  subnets            = [
    module.vpc.public_subnet1_id,
    module.vpc.public_subnet2_id
  ]

  enable_deletion_protection = false

  tags = {
    Environment = "development"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  target_type = "instance"

    health_check {
        enabled             = true
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        path                = "/"
        matcher             = "200-399"
        port                = "8000"
    }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# SECURITY GROUPS

resource "aws_security_group" "bastion_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic for bastion host from my IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "SSH from my-ip"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["68.146.18.77/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_instance_ssh" {
  name        = "allow_ssh_bastion"
  description = "Allow SSH inbound traffic for private instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "SSH from bastion host"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion_ssh.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_app" {
  name        = "alb_app"
  description = "Allow HTTP inbound traffic for application server"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "HTTP from ALB"
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
}

resource "aws_security_group" "allow_app" {
  name        = "allow_app"
  description = "Allow HTTP inbound traffic for application server"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    security_groups = [aws_security_group.alb_app.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]    
    }
}


# INSTANCES

resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform"
  public_key = file("/home/dolapo/ssh2/id_rsa.pub")
}

resource "aws_instance" "bastion_host" {
  ami                    = "ami-0b6c6ebed2801a5cb" 
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnet1_id
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_ssh.id]

  tags = {
    Name = "Bastion Host"
  }
}

resource "aws_launch_template" "asg" {
  name_prefix   = "asg-demo"
  image_id      = "ami-0b6c6ebed2801a5cb"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.terraform_key.key_name

  user_data = base64encode(templatefile("${path.module}/userdata.tftpl", {
    html_content = file("${path.module}/index.html")
  }))

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.allow_app.id, aws_security_group.private_instance_ssh.id]
  }

  tags = {
    Name = "ASG Instance"
  }

}

resource "aws_autoscaling_group" "terraform-demo" {

  vpc_zone_identifier = [
    module.vpc.private_subnet1_id,
    module.vpc.private_subnet2_id
  ]
  desired_capacity   = 2
  max_size           = 4
  min_size           = 1
  target_group_arns = [aws_lb_target_group.app_tg.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.asg.id
    version = "$Latest"
  }
  
}

