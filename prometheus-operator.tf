resource "helm_release" "prometheus-operator" {
  name              = "prometheus-operator"
  repository        = "https://prometheus-community.github.io/helm-charts" 
  chart             = "kube-prometheus-stack"
  version           = var.PROMETHEUS_VERSION
  namespace         = "kube-mon"
  values = [
  <<EOF
  prometheus:
    prometheusSpec:
      storageSpec:
        volumeClaimTemplate:
          spec:
            storageClassName: "standard"
            resources:
              requests:
                storage: 10Gi
      additionalScrapeConfigs:
      - job_name: 'istiod'
        kubernetes_sd_configs:
        - role: endpoints
          namespaces:
            names:
            - istio-system
        relabel_configs:
        - source_labels: [__meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
          action: keep
          regex: istiod;http-monitoring
      - job_name: 'envoy-stats'
        metrics_path: /stats/prometheus
        kubernetes_sd_configs:
        - role: pod
        relabel_configs:
        - source_labels: [__meta_kubernetes_pod_container_port_name]
          action: keep
          regex: '.*-envoy-prom'
  alertmanager:
    enabled: false
  grafana:
    adminPassword: admin
  EOF
  ]
  create_namespace  = true
  depends_on = [
    time_sleep.wait_istio_ready
  ]
}
resource "local_file" "grafana-route" {
  content  = <<-EOF
  apiVersion: networking.istio.io/v1alpha3
  kind: Gateway
  metadata:
    name: grafana
  spec:
    selector:
      istio: ingressgateway
    servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
      - "grafana.${data.kubernetes_service.istio-ingressgateway.status.0.load_balancer.0.ingress.0.ip}.nip.io"
  ---
  apiVersion: networking.istio.io/v1alpha3
  kind: VirtualService
  metadata:
    name: grafana
  spec:
    hosts:
    - "grafana.${data.kubernetes_service.istio-ingressgateway.status.0.load_balancer.0.ingress.0.ip}.nip.io"
    gateways:
    - grafana
    http:
    - route:
      - destination:
          host: prometheus-operator-grafana.kube-mon.svc.cluster.local
          port:
            number: 80
  EOF
  filename = "${path.root}/configs/grafana-route.yaml"
  provisioner "local-exec" {
    command = "kubectl apply -f ${self.filename} -n ${helm_release.prometheus-operator.namespace}"
  }
  depends_on = [
    helm_release.prometheus-operator
  ]
}
