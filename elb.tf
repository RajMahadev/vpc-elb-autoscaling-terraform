#create a new load balancer

resource "aws_elb" "terra-elb" {
  name =  "terra-elb"
  subnets = aws_subnet.public.*.id
  security_groups = [aws_security_group.webservers.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    interval            = 30
    target              = "HTTP:80/index.html"
    timeout             = 3
    unhealthy_threshold = 2
  }

  instances  =[aws_instance.webservers[0].id, aws_instance.webservers[1].id]
cross_zone_load_balancing = true
  idle_timeout =  100
  connection_draining = true
connection_draining_timeout = 300
  tags = {
    Name ="terraform-elb"

  }

}
output "elb-dns-name" {
  value = aws_elb.terra-elb.dns_name
}

# create autoscaling

resource "aws_launch_configuration" "terra-autoscaling" {
  name = "terra-autoscaling-launch-configuration"
  image_id      = "ami-0529ae4622e1288aa"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "terra-autoscaling" {
  availability_zones  = ["us-west-2a","us-west-2b"]
  desired_capacity = 2
  launch_configuration = aws_launch_configuration.terra-autoscaling.name
  max_size = 3
  min_size = 1
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "webservers"
  }

}