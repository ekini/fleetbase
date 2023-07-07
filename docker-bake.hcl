// docker-bake.hcl
variable "REGISTRY" { default = "" }
target "docker-metadata-action" {}

group "default" {

  targets = ["app", "scheduler"]

}

target "app" {
  inherits   = ["docker-metadata-action"]
  context    = "./"
  target     = "app"
  dockerfile = "docker/Dockerfile"
  platforms = [
    "linux/amd64",
  ]
  tags = notequal("", REGISTRY) ? [
    "${REGISTRY}/fleetbase-app:latest",
  ] : []
}
target "scheduler" {
  inherits = ["app"]
  target   = "scheduler"
  tags = notequal("", REGISTRY) ? [
    "${REGISTRY}/fleetbase-scheduler:latest",
  ] : []
}
