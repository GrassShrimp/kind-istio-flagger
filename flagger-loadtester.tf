resource "helm_release" "loadtester" {
  name       = "loadtester"
  repository = "https://flagger.app"
  chart      = "loadtester"
  version    = var.LOADTESTER_VERSION
  namespace  = "istio-system"
  depends_on = [ module.kind-istio-metallb, helm_release.flagger ]
}