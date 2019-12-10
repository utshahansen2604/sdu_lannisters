resource "aws_security_group" "lan-allow-ssh-1" {
  name = "allow-lan-SG-1"
 #allow port 22
  ingress {
    protocol   = "tcp"
    //rule_no    = 100
    //action     = "allow"
    cidr_blocks = ["0.0.0.0/0"] 
    from_port  = 22
    to_port    = 22
  }
  

    ingress {
      protocol = "tcp"
      cidr_blocks =["0.0.0.0/0"]
      from_port = 8080
      to_port = 8080
    }

    egress {
      protocol = -1
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 0
      to_port = 0  
    }

    

}