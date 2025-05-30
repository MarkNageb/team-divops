variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type = string
}

variable "ssh_private_key_path" {
  type = string
}

variable "roles" {
  type    = list(string)
  default = ["frontend","backend","genai"]
}
