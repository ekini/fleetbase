// docker-bake.hcl
variable "REGISTRY" { default = "" }
target "docker-metadata-action" {}

group "default" {

  targets = ["app"]

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
    "${REGISTRY}/app:latest",
  ] : []
}
target "scheduler" {
  inherits = ["app"]
  target   = "scheduler"
  tags = notequal("", REGISTRY) ? [
    "${REGISTRY}/app:latest",
  ] : []
}
