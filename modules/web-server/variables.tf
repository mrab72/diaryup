variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 80
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the Terraform remote state"
  type        = string
}

variable "db_remote_state_key" {
  description = "The name of the key for the Terraform remote state"
  type        = string
}
