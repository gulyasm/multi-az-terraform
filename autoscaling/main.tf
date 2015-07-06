variable "access_key" {}
variable "secret_key" {}

variable "zones" {
    default = {
        zone0 = "us-east-1a"
        zone1 = "us-east-1e"
        zone2 = "us-east-1c"
    }
}

provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "us-east-1"
}

resource "aws_elb" "multi-az-elb" {
    name = "multi-az-elb"
  availability_zones = ["us-east-1a", "us-east-1c", "us-east-1e"]
    security_groups = ["sg-f4bbd391"]
    listener = {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }
    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        target = "HTTP:80/index.html"
        interval = 30
  }
  cross_zone_load_balancing = true
}
resource "aws_launch_configuration" "multi-az-launch" {
    name = "multi-az-launch"
    image_id = "ami-46f5842e"
    instance_type = "t2.micro"
    key_name = "dmlab_prod"
    security_groups = ["default"]
}

resource "aws_autoscaling_group" "multiaz-autoscalinggroup" {
  availability_zones = ["us-east-1a", "us-east-1c", "us-east-1e"]
  name = "multiaz-autoscalinggroup"
  min_elb_capacity = 3
  max_size = 10
  min_size = 3
  health_check_grace_period = 300
  load_balancers = ["${aws_elb.multi-az-elb.name}"]
  health_check_type = "ELB"
  desired_capacity = 3
  force_delete = true
  launch_configuration = "${aws_launch_configuration.multi-az-launch.name}"
  tag {
    key = "Name"
    value = "multi-az-test"
    propagate_at_launch = true
  }
  tag {
    key = "Env"
    value = "dev"
    propagate_at_launch = true
  }
  tag {
    key = "Client"
    value = "all"
    propagate_at_launch = true
  }
}
