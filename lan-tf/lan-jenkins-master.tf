## Terraform Jenkins Master 

# Declaring AWS Region and Profile
provider "aws" {
  profile="ShellPowerUser"
  region="ap-south-1"
}

# Creating Key Pair for EC2 using Local Machine Public Key
resource "aws_key_pair" "lan-jenkins-kp" {
  key_name   = "lan-jenkins-kp"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
  }

# Creating EBS Voulme to attach
resource "aws_ebs_volume" "lan-jenkins-ebs" {
  size              = 10
  availability_zone = "ap-south-1a"

  tags = {
    Name = "lan-jenkins-EBS"
  }
}

# Creating EC2 Instance for Jenkins Master
resource "aws_instance" "lan-jenkins-dev" {
  ami           = "ami-0c763b9e1f2c3ab09"
  instance_type = "t2.micro"
  key_name= "lan-jenkins-kp"
  availability_zone= "ap-south-1a"
  tags ={
    Name ="lan-jenkins-dev"
  }
  security_groups = ["${aws_security_group.lan-allow-ssh-1.name}"] # Security Group for Jenkins Master

}

# Creating Voulme Attachment for EC2 and EBS
resource "aws_volume_attachment" "lan-ebs-attach" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.lan-jenkins-ebs.id}"
  instance_id = "${aws_instance.lan-jenkins-dev.id}"
}