terraform {
  backend "s3" {
    bucket = "lannisters-bucket"
    key    = "state_lan_ecr"
    region = "ap-south-1"
  }
}
