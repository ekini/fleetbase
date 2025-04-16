// docker-bake.hcl
variable "REGISTRY" { default = "" }
variable "VERSION" { default = "latest" }
variable "CACHE" { default = "" }
variable "GCP" { default = false }
variable "GITHUB_AUTH_KEY" { default = "" }
variable "tags" { default = "[]" }

group "default" {
  targets = ["app", "app-httpd"]
}

target "docker-metadata-action" {}

target "app" {
  inherits = ["docker-metadata-action"]

  name = "app-${tgt}"

  // use matrix strategy to build several targets at once
  matrix = {
    tgt = ["app", "scheduler", "events"]
  }
  context = "./"
  // set the target from matrix
  target     = tgt
  dockerfile = "docker/Dockerfile"
  platforms = [
    "linux/amd64",
  ]

  tags = notequal("", REGISTRY) ? formatlist(
    GCP ? "${REGISTRY}/${tgt}:%s" : "${REGISTRY}:${tgt}-%s",
    compact(concat(["latest", VERSION], jsondecode(tags)))
  ) : []

  args = {
    GITHUB_AUTH_KEY = "${GITHUB_AUTH_KEY}"
  }

  cache-from = notequal("", CACHE) ? ["${CACHE}"] : []
  cache-to   = notequal("", CACHE) ? ["${CACHE},mode=max,ignore-error=true"] : []
}

target "app-httpd" {
  inherits = ["docker-metadata-action"]

  context    = "./"
  dockerfile = "docker/httpd/Dockerfile"
  platforms = [
    "linux/amd64",
  ]

  tags = notequal("", REGISTRY) ? formatlist(
    GCP ? "${REGISTRY}/app-httpd:%s" : "${REGISTRY}:app-httpd-%s",
    compact(concat(["latest", VERSION], jsondecode(tags)))
  ) : []
}
