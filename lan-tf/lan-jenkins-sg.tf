# Create Security Group for Jenkins Master
resource "aws_security_group" "lan-allow-ssh-1" {
  name = "allow-lan-SG-1"
  tags = {
    Name = "Lan-Jenkins-SG"
  }
 # Allow SSH for port 22
  ingress {
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
    from_port  = 22
    to_port    = 22
  }
  # Allow TCP for port 8080
    ingress {
      protocol = "tcp"
      cidr_blocks =["0.0.0.0/0"]
      from_port = 8080
      to_port = 8080
    }
  # Allow all outbound traffic
    egress {
      protocol = -1
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 0
      to_port = 0  
    }

    

}