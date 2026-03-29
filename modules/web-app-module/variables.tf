variable "server_port" {
  description = "The port the web server will listen on"
  type        = number
  default     = 8080
}

variable "ami" {
  description = "The Amazon Machine Image (AMI) of the EC2 instance"
  type        = string
  default     = "ami-08f5d9f4870fa3a73"
}

variable "instance_type" {
  description = "The size of the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances to deploy"
  type        = number
  default     = 2
}