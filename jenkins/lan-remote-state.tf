# Terraform Remote State File. 
terraform {
  backend "s3" {
    bucket = "lannisters-bucket" # Bucket Name
    key    = "state_lan"  # Name of Remote State File in the bucket
    region = "ap-south-1" 
    profile="ShellPowerUser" # Important to declare Profile
  }
}