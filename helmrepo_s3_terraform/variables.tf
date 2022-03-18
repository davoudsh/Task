variable "region" {
  default = "us-east-1"
}

variable "allowed_account_ids" {
  default     = ["398416956804"]
  description = "A list of AWS account IDs to grant read-only access to the repo. A maximum of 9 accounts"
  type        = list(string)
}

variable "allowed_account_ids_write" {
  default     = ["398416956804"]
  description = "A list of AWS account IDs to grant write access to the repo. A maximum of 9 accounts"
  type        = list(string)
}

variable "helmrepo_log_bucket_name" {
  default     = "helmrepo-log-bucket"
  description = "This is a bucket where the logs of helm repo are stored"
  type        = string
}

variable "name" {
  default     = "helmrepo-bucket"
  description = "A bucket name for the helm repo. Specify to control the exact name of the bucket"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to be added to supported resources"
  type        = map(string)
}

