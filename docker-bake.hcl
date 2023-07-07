// docker-bake.hcl
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
}
target "scheduler" {
  inherits = ["app"]
  target   = "scheduler"
}
