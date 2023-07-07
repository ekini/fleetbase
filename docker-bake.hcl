// docker-bake.hcl
variable "REGISTRY" { default = "" }
variable "tags" { default = "[]" }
target "docker-metadata-action" {}

group "default" {

  targets = ["app"] #, "scheduler"]

}

target "app" {
  name = "app-${tgt}"

  inherits = ["docker-metadata-action"]

  matrix = {
    tgt = ["app", "scheduler", "jobs", "events"]
  }
  context    = "./"
  target     = tgt
  dockerfile = "docker/Dockerfile"
  platforms = [
    "linux/amd64",
  ]
  tags = notequal("", REGISTRY) ? formatlist(
    "${REGISTRY}/fleetbase-${tgt}:%s",
    concat(["latest"], jsondecode(replace(tags, "willbereplaced:", "")))
  ) : []
}
