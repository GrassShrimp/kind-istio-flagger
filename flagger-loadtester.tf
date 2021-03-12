resource "helm_release" "loadtester" {
  name       = "loadtester"
  repository = "https://flagger.app"
  chart      = "loadtester"
  version    = "0.18.0"
  namespace  = "istio-system"

  depends_on = [ null_resource.installing-istio, helm_release.flagger ]
}