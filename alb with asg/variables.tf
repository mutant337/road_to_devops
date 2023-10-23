variable "vpc_id" {
  description = "Existing VPC to use (specify this, if you don't want to create new VPC)"
  type        = string
  default     = "vpc-02bc8ac492cf733a7"
}

variable "public_a" {
  description = "public a subnet"
  type        = string
  default     = "subnet-0040af26b3787ba27"
}

variable "public_b" {
  description = "public b subnet"
  type        = string
  default     = "subnet-0299fc35e8296ea20"
}