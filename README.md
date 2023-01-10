# dev-spaces-config

Configuration and Custom Images for Eclipse Che

Work In Progress

```bash
podman login quay.io/cgruver0

export BUILDAH_FORMAT=docker

podman buildx build --arch=amd64 -t quay.io/cgruver0/che/devtools:amd64 .
```

```bash
labctx

labenv -k

chectl update stable
chectl server:deploy --platform openshift
oc patch CheCluster eclipse-che -n eclipse-che --type merge --patch '{"spec":{"devEnvironments":{"disableContainerBuildCapabilities":false}}}'
oc patch dwoc devworkspace-config -n eclipse-che --type merge --patch '{"config":{"workspace":{"containerSecurityContext":{"allowPrivilegeEscalation":true}}}}'
```

Replace `registry.redhat.io/openshift4/ose-kube-rbac-proxy:v4.8` with `quay.io/openshift/origin-kube-rbac-proxy:4.12.0`

```bash
DW_OP=$(oc get csv -n openshift-operators | grep devworkspace-operator | cut -d" " -f1)
oc get csv ${DW_OP} -n openshift-operators -o yaml > dw-csv.yaml
sed -i "s|registry.redhat.io/openshift4/ose-kube-rbac-proxy:v4.8|quay.io/openshift/origin-kube-rbac-proxy:4.12.0|g" dw-csv.yaml

sed -i "s|registry.redhat.io/openshift4/ose-kube-rbac-proxy:v4.8|gcr.io/kubebuilder/kube-rbac-proxy:v0.13.1|g" dw-csv.yaml

oc apply -f dw-csv.yaml -n openshift-operators
sleep 5
oc scale deployment devworkspace-webhook-server --replicas=0 -n openshift-operators
oc scale deployment devworkspace-controller-manager --replicas=0 -n openshift-operators
sleep 5
oc scale deployment devworkspace-webhook-server --replicas=1 -n openshift-operators
oc scale deployment devworkspace-controller-manager --replicas=1 -n openshift-operators
```
