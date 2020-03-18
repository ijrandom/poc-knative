#!/bin/bash

snap install microk8s --classic
microk8s.status enable ingress
microk8s.status enable storage
microk8s.status enable helm3
microk8s.enable dns
iptables -P FORWARD ACCEPT


kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/serving-crds.yaml
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/serving-core.yaml


export ISTIO_VERSION=1.3.6
curl -L https://git.io/getLatestIstio | sh -
cd istio-${ISTIO_VERSION}

for i in install/kubernetes/helm/istio-init/files/crd*yaml; do microk8s.kubectl apply -f $i; done

cat <<EOF | microk8s.kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: istio-system
  labels:
    istio-injection: disabled
EOF

microk8s.helm template --namespace=istio-system \
  --set prometheus.enabled=false \
  --set mixer.enabled=false \
  --set mixer.policy.enabled=false \
  --set mixer.telemetry.enabled=false \
  `# Pilot doesn't need a sidecar.` \
  --set pilot.sidecar=false \
  --set pilot.resources.requests.memory=128Mi \
  `# Disable galley (and things requiring galley).` \
  --set galley.enabled=false \
  --set global.useMCP=false \
  `# Disable security / policy.` \
  --set security.enabled=false \
  --set global.disablePolicyChecks=true \
  `# Disable sidecar injection.` \
  --set sidecarInjectorWebhook.enabled=false \
  --set global.proxy.autoInject=disabled \
  --set global.omitSidecarInjectorConfigMap=true \
  --set gateways.istio-ingressgateway.autoscaleMin=1 \
  --set gateways.istio-ingressgateway.autoscaleMax=2 \
  `# Set pilot trace sampling to 100%` \
  --set pilot.traceSampling=100 \
  --set global.mtls.auto=false \
  install/kubernetes/helm/istio \
  > ./istio-lean.yaml

microk8s.kubectl apply -f istio-lean.yaml

microk8s.kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/serving-istio.yaml
