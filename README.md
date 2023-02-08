# Set Up for Eclipse Che / OpenShift Dev Spaces Demos

Configuration and Custom Images for Eclipse Che

Work In Progress

```bash
yarn set version latest
WORK_DIR=$(mktemp -d)/che-plugin-registry
git clone -b 7.60.x --single-branch https://github.com/eclipse-che/che-plugin-registry.git ${WORK_DIR}
cp openvsx-sync.json ${WORK_DIR}
cd ${WORK_DIR}
# BASH_PATH=$(which bash)
# sed -i "s|\#\!/bin/bash|\#\!${BASH_PATH}|g" ./build.sh
# sed -i "s|\#\!/bin/bash|\#\!${BASH_PATH}|g" ./build/dockerfiles/test_entrypoint.sh
./build.sh -o eclipse-che -r ${LOCAL_REGISTRY} -t che-code-vsx --offline

rm -rf ${WORK_DIR}

oc import-image che-plugin-registry:che-code-vsx --from=${LOCAL_REGISTRY}/eclipse-che/che-plugin-registry:che-code-vsx --confirm -n eclipse-che-images
```

```bash
labctx

labenv -k

chectl update stable
chectl server:deploy --platform openshift
oc patch CheCluster eclipse-che -n eclipse-che --type merge --patch '{"spec":{"devEnvironments":{"disableContainerBuildCapabilities":false,"storage":{"pvcStrategy":"per-workspace"}}}}'
oc patch CheCluster eclipse-che -n eclipse-che --type merge --patch '{"spec":{"components":{"pluginRegistry":{"openVSXURL":"","deployment":{"containers":[{"image":"image-registry.openshift-image-registry.svc:5000/eclipse-che-images/che-plugin-registry:che-code-vsx"}]}}}}}'

```

```bash
DW_OP=$(oc get csv -n openshift-operators | grep devworkspace-operator | cut -d" " -f1)
oc get csv ${DW_OP} -n openshift-operators -o yaml > dw-csv.yaml
sed -i "s|registry.redhat.io/openshift4/ose-kube-rbac-proxy:v4.8|quay.io/openshift/origin-kube-rbac-proxy:4.12.0|g" dw-csv.yaml
oc apply -f dw-csv.yaml -n openshift-operators
sleep 5
oc scale deployment devworkspace-webhook-server --replicas=0 -n openshift-operators
oc scale deployment devworkspace-controller-manager --replicas=0 -n openshift-operators
sleep 5
oc scale deployment devworkspace-webhook-server --replicas=1 -n openshift-operators
oc scale deployment devworkspace-controller-manager --replicas=1 -n openshift-operators
```

```bash
podman run -it --ipc none --net none registry.access.redhat.com/ubi9/ubi-minimal --log-level debug
```

```bash
systemctl enable --now --user podman.socket
systemctl status --user podman.socket

systemctl --user daemon-reload

loginctl enable-linger $USER
export XDG_RUNTIME_DIR=/run/user/$(id -u)

```

```bash
oc new-build -n eclipse-che-images --to='podman-basic:latest' -D - < ./basic-podman.Dockerfile
oc new-build -n eclipse-che-images --to='quarkus:latest' -D - < ./quarkus-podman.Dockerfile
```

```yaml
apiVersion: org.eclipse.che/v2
kind: CheCluster
metadata:
  name: devspaces
  namespace: devspaces
spec:
  components:
    pluginRegistry:
      openVSXURL: ''
    cheServer:
      debug: false
      logLevel: INFO
    database:
      credentialsSecretName: postgres-credentials
      externalDb: false
      postgresDb: dbche
      postgresHostName: postgres
      postgresPort: '5432'
      pvc:
        claimSize: 1Gi
    metrics:
      enable: true
  containerRegistry: {}
  devEnvironments:
    secondsOfRunBeforeIdling: -1
    containerBuildConfiguration:
      openShiftSecurityContextConstraint: container-build
    disableContainerBuildCapabilities: false
    defaultEditor: che-incubator/che-code/insiders
    defaultComponents:
      - container:
          sourceMapping: /projects
          image: >-
            registry.redhat.io/devspaces/udi-rhel8@sha256:aa39ede33bcbda6aa2723d271c79ab8d8fd388c7dfcbc3d4ece745b7e9c84193
        name: universal-developer-image
    defaultNamespace:
      autoProvision: true
      template: <username>-devspaces
    secondsOfInactivityBeforeIdling: 1800
    storage:
      pvcStrategy: per-workspace
  gitServices: {}
  networking: {}
```