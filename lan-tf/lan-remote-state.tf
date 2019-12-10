terraform {

  backend "s3" {
    bucket = "lannisters-bucket"
    key    = "state_lan"
    region = "ap-south-1"
    profile="ShellPowerUser"
  }
}