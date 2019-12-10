provider "aws" {
  profile="ShellPowerUser"
  region="ap-south-1"
}

resource "aws_key_pair" "lan-jenkins-kp" {
  key_name   = "lan-jenkins-kp"
  #public_key = "${file("~/.ssh/id_rsa.pub")}"
  }

resource "aws_ebs_volume" "lan-jenkins-ebs" {
  size              = 10
  availability_zone = "ap-south-1a"

  tags = {
    Name = "lan-jenkins-EBS"
  }
}

resource "aws_instance" "lan-jenkins-dev" {
  ami           = "ami-0c763b9e1f2c3ab09"
  instance_type = "t2.micro"
  key_name= "lan-jenkins-kp"
  availability_zone= "ap-south-1a"
  tags ={
    Name ="lan-jenkins-dev"
  }
  security_groups = ["${aws_security_group.lan-allow-ssh-1.name}"]

}

resource "aws_volume_attachment" "lan-ebs-attach" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.lan-jenkins-ebs.id}"
  instance_id = "${aws_instance.lan-jenkins-dev.id}"
}

