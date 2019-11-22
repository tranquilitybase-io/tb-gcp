data "helm_repository" "istio" {
  name = "istio.io"
  url = "https://storage.googleapis.com/istio-release/releases/${var.istio_version}/charts/"
}
