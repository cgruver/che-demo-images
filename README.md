# dev-spaces-config

Configuration and Custom Images for Eclipse Che

```bash
podman login quay.io/cgruver0

export BUILDAH_FORMAT=docker

podman buildx build --arch=amd64 -t quay.io/cgruver0/che/devtools:amd64 .
```

Setup for non-root container build

```bash
oc apply -f - <<EOF
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: container-build
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities:
  - SETUID
  - SETGID
defaultAddCapabilities: null
fsGroup:
  type: MustRunAs
# Temporary workaround for https://github.com/devfile/devworkspace-operator/issues/884
priority: 20
readOnlyRootFilesystem: false
requiredDropCapabilities:
  - KILL
  - MKNOD
runAsUser:
  type: MustRunAsRange
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users: []
groups: []
volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
EOF

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: get-n-update-container-build-scc
rules:
- apiGroups:
  - "security.openshift.io"
  resources:
  - "securitycontextconstraints"
  resourceNames:
  - "container-build"
  verbs:
  - "get"
  - "update"
EOF
```

Add the role to the DevWorkspace controller Service Account

```bash
oc adm policy add-cluster-role-to-user \
       get-n-update-container-build-scc \
       system:serviceaccount:openshift-operators:devworkspace-controller-serviceaccount
```

```bash
oc adm policy add-scc-to-user container-build janedoe
```

```yaml
schemaVersion: 2.1.0
metadata:
  name: build-test
attributes:
  controller.devfile.io/scc: container-build
projects:
- name: dockerfile-hello-world
  git:
    remotes:
      origin: https://github.com/l0rd/dockerfile-hello-world
components:
- name: devtooling-container
  container:
    image: quay.io/devspaces/udi-rhel8:next
    memoryLimit: 1Gi
    cpuLimit: 1000m
```
