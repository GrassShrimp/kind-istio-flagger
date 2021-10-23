resource "helm_release" "loadtester" {
  name       = "loadtester"
  repository = "https://flagger.app"
  chart      = "loadtester"
  version    = var.LOADTESTER_VERSION
  namespace  = "istio-system"
  depends_on = [ time_sleep.wait_istio_ready, helm_release.flagger ]
}