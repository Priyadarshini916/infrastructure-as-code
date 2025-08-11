variable "private_subnet_cidrs" {
  description = "list of cidr blocks for private subnets"
  type = list(string)
  default = [ "10.81.1.0/24", "10.81.2.0/24" ]
}

variable "public_subnet_cidrs" {
  description = "a list of cidr blocks for public subnet"
  type = list(string)
  default = ["10.81.3.0/24", "10.81.4.0/24"]
}

variable "availability_zones" {
   description = "A list of availability zones to deploy subnets into."
      type        = list(string)
      default     = ["us-east-1a", "us-east-1b"]
    }

variable "vpc_cidr_block" {
  
}

variable "pub_rt" {
  
}

variable "pvt_rt" {
  
}