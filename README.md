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
```

Replace `registry.redhat.io/openshift4/ose-kube-rbac-proxy:v4.8` with `quay.io/openshift/origin-kube-rbac-proxy:4.12.0`
