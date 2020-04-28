variable "credentials_file" {
  description = "Our GCP credentials (not a file anymore)"
  default = "/Users/olliephillips/Dropbox/Teet Lab/credentials/gcp/terraform-service-account.json"
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
  default = "go113"
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
    // 'function' = 'entrypoint'
    "hello" = "TestHello"
    "bye" = "TestBye"
  }
}

// Cloud Run
variable "domain" {
  default = "sso.teet.io"
}