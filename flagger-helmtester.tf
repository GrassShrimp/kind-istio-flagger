resource "helm_release" "helmtester" {
  name       = "helmtester"
  repository = "https://flagger.app"
  chart      = "loadtester"
  version    = var.LOADTESTER_VERSION
  namespace  = "kube-system"
  depends_on = [ module.kind-istio-metallb, helm_release.flagger ]
}