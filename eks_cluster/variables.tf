variable "region" {
  default = "ap-south-1"
}

# variable "map_accounts" {
#   description = "Additional AWS account numbers to add to the aws-auth configmap."
#   type        = list(string)

#   default = [
#     "580572941932",
#   ]
# }

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::580572941932:role/ShellPowerUser"
      username = "ShellPowerUser"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::580572941932:role/Lannister_Jenkins_Instance_Role"
      username = "Lannister_Jenkins_Instance_Role"
      groups   = ["system:masters"]
    }
  ]
}

# variable "map_users" {
#   description = "Additional IAM users to add to the aws-auth configmap."
#   type = list(object({
#     userarn  = string
#     username = string
#     groups   = list(string)
#   }))

#   default = [
#     {
#       userarn  = "arn:aws:iam::580572941932:user/utshahansen2604"
#       username = "utshahansen2604"
#       groups   = ["system:masters"]
#     },]
# }
  #   {
  #     userarn  = "arn:aws:iam::580572941932:user/eswarkp"
  #     username = "eswarkp"
  #     groups   = ["system:masters"]
  #   },
  #   {
  #     userarn  = "arn:aws:iam::580572941932:user/Abhishek5340"
  #     username = "Abhishek5340"
  #     groups   = ["system:masters"]
  #   },
  # ]
