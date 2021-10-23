resource "helm_release" "flagger" {
  name       = "flagger"
  repository = "https://flagger.app"
  chart      = "flagger"
  version    = var.FLAGGER_VERSION
  namespace  = "istio-system"
  values = [
  <<EOF
  metricsServer: "http://prometheus-operator-kube-p-prometheus.kube-mon:9090"
  meshProvider: "istio"
  EOF
  ]
  create_namespace = true
  depends_on = [ time_sleep.wait_istio_ready, helm_release.prometheus-operator ]
}