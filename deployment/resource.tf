
// clean up
resource "null_resource" "clean_step" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "rm -f bin/*"
  }

}

// build step (builds all in cmd)
resource "null_resource" "build_step" {
  depends_on = [null_resource.clean_step]
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "GOOS=linux GOARCH=amd64 go build -o ./bin/ -v ../cmd/..."
  }
}

// create archive(s)
data "archive_file" "zip_step" {
  depends_on = [null_resource.build_step]
  type        = "zip"
  source_file = "./bin/sso"
  output_path = "./bin/sso.zip"
}

// create bucket
resource "google_storage_bucket" "bucket" {
  name = var.bucket_name
}

// upload archive(s)
resource "google_storage_bucket_object" "archive" {
  name   = "sso.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.zip_step.output_path
}

// create function(s)
resource "google_cloudfunctions_function" "function" {
  name        = "function-test"
  description = "renders the SSO"
  runtime     = var.runtime

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "helloGET"
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}