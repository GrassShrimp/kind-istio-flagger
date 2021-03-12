resource "helm_release" "helmtester" {
  name       = "helmtester"
  repository = "https://flagger.app"
  chart      = "loadtester"
  version    = "0.18.0"
  namespace  = "kube-system"

  depends_on = [ null_resource.installing-istio, helm_release.flagger ]
}