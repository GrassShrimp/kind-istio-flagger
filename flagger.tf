resource "helm_release" "flagger" {
  name       = "flagger"
  repository = "https://flagger.app"
  chart      = "flagger"
  version    = "1.6.4"
  namespace  = "istio-system"

  values = [
  <<EOF
  metricsServer: "http://prometheus-operator-kube-p-prometheus.kube-mon:9090"
  meshProvider: "istio"
  EOF
  ]

  create_namespace = true

  depends_on = [ null_resource.installing-istio, helm_release.prometheus-operator ]
}