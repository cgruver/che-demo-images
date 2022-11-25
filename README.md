# dev-spaces-config

Configuration and Custom Images for Eclipse Che

podman login quay.io/cgruver0

export BUILDAH_FORMAT=docker

podman buildx build --arch=amd64 -t quay.io/cgruver0/che/devtools:amd64 .
