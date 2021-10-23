# kind-istio-flagger

This is a demo for demonstrate canary deployment via istio with flagger

## Prerequisites

- [terraform](https://www.terraform.io/downloads.html)
- [docker](https://www.docker.com/products/docker-desktop)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://helm.sh/docs/intro/install/)

## Usage

initialize terraform module

```bash
$ terraform init
```

create kind cluster, and setup istio, prometheus, grafana, and flagger with the tester

```bash
$ terraform apply -auto-approve
```

Label the default namespace with istio-injection=enabled

```bash
$ kubectl label namespace default istio-injection=enabled --overwrite
```

initialize example istio-canary

```bash
$ helm upgrade --install podinfo ./examples/istio-canary/ --set image.tag=5.1.0
```

and then check log of flagger

```bash
$ kubectl logs -n istio-system -l app.kubernetes.io/name=flagger
```

![flagger01](https://github.com/GrassShrimp/kind-istio-flagger/blob/master/flagger01.png)

deploy a new version app

```bash
$ helm upgrade --install podinfo ./examples/istio-canary/ --set image.tag=5.1.1
```

and then check log of flagger again

```bash
$ kubectl logs -n istio-system -l app.kubernetes.io/name=flagger
```

![flagger02](https://github.com/GrassShrimp/kind-istio-flagger/blob/master/flagger02.png)

try manual rollback during deployment when confirm rollout is enabled of helm value

```bash
$ kubectl exec -n istio-system $(kubectl get pods -n istio-system -l app=loadtester --no-headers=true | awk '{print $1}') -- /bin/sh -c "curl -d '{\"name\": \"podinfo-istio-canary\", \"namespace\": \"default\"}' http://localhost:8080/rollback/open"
```

![flagger03](https://github.com/GrassShrimp/kind-istio-flagger/blob/master/flagger03.png)

try manual promotion when confirm promotion is enabled of helm value

```bash
$ kubectl exec -n istio-system $(kubectl get pods -n istio-system -l app=loadtester --no-headers=true | awk '{print $1}') -- /bin/sh -c "curl -d '{\"name\": \"podinfo-istio-canary\", \"namespace\": \"default\"}' http://localhost:8080/gate/open"
```

![flagger04](https://github.com/GrassShrimp/kind-istio-flagger/blob/master/flagger04.png)

destroy demo

```bash
$ terraform destroy -auto-approve
```
