#!/bin/bash

# Check if Docker and kubectl are installed
if ! command -v docker &> /dev/null; then
  echo "Error: Docker is not installed. Please install it before running this script."
  exit 1
fi

if ! command -v kubectl &> /dev/null; then
  echo "Error: kubectl is not installed. Please install it before running this script."
  exit 1
fi

# Create a Kind cluster named "ignite-dev" with ingress configuration
cat <<EOF | kind create cluster --name ignite-dev --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    listenAddress: "0.0.0.0" # Optional, defaults to "0.0.0.0"
    protocol: tcp
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
EOF

# Download the Kubeconfig file
echo "Downloading Kubeconfig for 'ignite-dev'..."
kind get kubeconfig --name ignite-dev > ~/.kube/config.ignite-dev

echo "Kubeconfig downloaded and saved to ~/.kube/config.ignite-dev"

echo "Your Kind cluster 'ignite-dev' is ready."

