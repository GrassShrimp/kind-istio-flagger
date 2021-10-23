resource "helm_release" "helmtester" {
  name       = "helmtester"
  repository = "https://flagger.app"
  chart      = "loadtester"
  version    = var.LOADTESTER_VERSION
  namespace  = "kube-system"
  depends_on = [ time_sleep.wait_istio_ready, helm_release.flagger ]
}