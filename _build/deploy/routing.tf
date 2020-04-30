// set up GCR if not aleady
resource "google_container_registry" "registry" {
  provider = google-beta
  project  = var.project
  location = "eu"
}

// log in to GCR with Docker (this is correct)
resource "null_resource" "docker_auth" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    //command = "cat \"${var.credentials_file}\" | docker login -u _json_key --password-stdin https://${lower(google_container_registry.registry.location)}.gcr.io"
    command = "docker login -u _json_key -p '${file(var.credentials_file)}' https://${lower(google_container_registry.registry.location)}.gcr.io"
  }
  depends_on = [google_container_registry.registry]
}

// build the docker image
resource "null_resource" "docker_build" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "docker build -t ${var.project}-${var.service} ${path.module}/../proxy"
  }

}

resource "null_resource" "docker_tag" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "docker tag ${var.project}-${var.service} ${lower(google_container_registry.registry.location)}.gcr.io/${var.project}/${var.project}-${var.service}"
  }

  depends_on = [null_resource.docker_build]
}

resource "null_resource" "docker_push" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "docker push ${lower(google_container_registry.registry.location)}.gcr.io/${var.project}/${var.project}-${var.service}"
  }

  depends_on = [null_resource.docker_tag, null_resource.docker_auth]

}

resource "google_cloud_run_service" "my-service" {
  name     = "my-service"
  location = "us-central1"

  metadata {
    namespace = var.project
  }

  template {
    spec {
      containers {
        image = "${lower(google_container_registry.registry.location)}.gcr.io/${var.project}/${var.project}-${var.service}"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [null_resource.docker_push]

}

resource "google_cloud_run_domain_mapping" "my-service" {
  location = "us-central1"
  name     = "sso.machinely.co.uk"

  metadata {
    namespace = var.project
  }

  spec {
    route_name = google_cloud_run_service.my-service.name
  }

  depends_on = [google_cloud_run_service.my-service]
}

resource "google_cloud_run_service_iam_member" "allUsers" {
  service  = google_cloud_run_service.my-service.name
  location = google_cloud_run_service.my-service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "url" {
  value = google_cloud_run_service.my-service.status[0].url
}

