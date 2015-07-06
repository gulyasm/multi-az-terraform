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

resource "aws_instance" "test-instance" {
    ami = "ami-1ecae776"
    instance_type = "t2.micro"
    key_name = "dmlab_prod"
    count = 3
    tags {
        Name = "HelloWorld"
    }
    availability_zone = "${lookup(var.zones, concat(\"zone\", count.index))}"
}



