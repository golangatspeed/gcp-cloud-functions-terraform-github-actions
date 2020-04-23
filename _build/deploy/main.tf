provider "google" {
  version = "3.5.0"
  credentials = var.credentials_file
  project = var.project
  region = var.region
  zone = var.zone
}

// clean up
resource "null_resource" "clean_step" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "rm -f archive/*"
  }
}

// create archive
data "archive_file" "zip_step" {
  depends_on = [null_resource.clean_step]
  type        = "zip"
  excludes = ["_build", "cmd", ".gitignore", ".DS_Store", "README.md"]

  for_each = tomap(var.functions)
  source_dir = "${path.module}/../../${each.key}"
  output_path = "${path.module}/archive/${each.key}.zip"
}

// create bucket(s)
resource "google_storage_bucket" "state" {
  name = "tf-state-${var.service}"
}

resource "google_storage_bucket" "bucket" {
  name = var.bucket_name
}

// upload archive(s)
resource "google_storage_bucket_object" "archive" {
  for_each = tomap(var.functions)
  name   = "${var.service}-${each.key}.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.zip_step[each.key].output_path
}

// create src(s)
resource "google_cloudfunctions_function" "function" {
  for_each = tomap(var.functions)
  name        = each.key
  description = "Service: ${var.service}. Function: ${each.key}."
  runtime     = var.runtime
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive[each.key].name
  trigger_http          = true
  entry_point           = each.value
}

# IAM permissions
resource "google_cloudfunctions_function_iam_member" "invoker" {
  for_each = tomap(var.functions)
  project        = google_cloudfunctions_function.function[each.key].project
  region         = google_cloudfunctions_function.function[each.key].region
  cloud_function = google_cloudfunctions_function.function[each.key].name
  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}