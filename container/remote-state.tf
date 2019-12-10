terraform {
  backend "s3" {
    bucket = "lannisters-bucket"
    key    = "state_lan_eks"
    region = "ap-south-1"
  }
}
