variable "credentials_file" {
  default = "../../../../Credentials/GCP/terraform-service-account.json"
}

variable "project" {
  default = "teet-lab"
}

variable "region" {
  default = "europe-west2"
}

variable "zone" {
  default = "europe-west2-a"
}

variable "runtime" {
  default = "go111"
}

variable "bucket_name" {
  default = "functions-development"
  description = "Bucket for functions in development"
}

variable "service" {
  description = "The name of this service"
  default = "sso"
}

variable "functions" {
  description  = "Functions contained in this repository"
  type    = map(string)
  default = {
    "hello" = "TestHello"
    "bye" = "TestBye"
  }
}
