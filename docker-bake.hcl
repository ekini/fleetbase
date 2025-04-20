// docker-bake.hcl
variable "REGISTRY" { default = "" }
variable "VERSION" { default = "latest" }
variable "CACHE" { default = "" }
variable "GCP" { default = false }
variable "GHCR" { default = false } // github container registry
variable "GITHUB_AUTH_KEY" { default = "" }

group "default" {
  targets = ["app", "app-httpd"]
}

group "all" {
  targets = ["default", "console"]
}

target "docker-metadata-action" {
  tags = []
}

target "app" {
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

  annotations = target.docker-metadata-action.annotations

  tags = notequal("", REGISTRY) ? formatlist(
    GCP ? "${REGISTRY}/${tgt}:%s" : GHCR ? "${REGISTRY}/fleetbase-${tgt}:%s" : "${REGISTRY}:${tgt}-%s",
    compact(concat(["latest", VERSION], target.docker-metadata-action.tags))
  ) : []

  args = {
    GITHUB_AUTH_KEY = "${GITHUB_AUTH_KEY}"
  }

  cache-from = notequal("", CACHE) ? ["${CACHE}"] : []
  cache-to   = notequal("", CACHE) ? ["${CACHE},mode=max,ignore-error=true"] : []
}

target "app-httpd" {
  context    = "./"
  dockerfile = "docker/httpd/Dockerfile"
  platforms = [
    "linux/amd64",
  ]

  annotations = target.docker-metadata-action.annotations

  tags = notequal("", REGISTRY) ? formatlist(
    GCP ? "${REGISTRY}/app-httpd:%s" : GHCR ? "${REGISTRY}/fleetbase-app-httpd:%s" : "${REGISTRY}:app-httpd-%s",
    compact(concat(["latest", VERSION], target.docker-metadata-action.tags))
  ) : []
}
target "console" {
  context    = "./"
  dockerfile = "console/Dockerfile.server-build"
  platforms = [
    "linux/amd64",
  ]

  annotations = target.docker-metadata-action.annotations

  tags = notequal("", REGISTRY) ? formatlist(
    GCP ? "${REGISTRY}/console:%s" : GHCR ? "${REGISTRY}/fleetbase-console:%s" : "${REGISTRY}:console-%s",
    compact(concat(["latest", VERSION], target.docker-metadata-action.tags))
  ) : []
}
