provider "kubectl" {
  config_path       = "~/.kube/config.ignite-dev"
}


provider "helm" {
  # Several Kubernetes authentication methods are possible: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#authentication
  kubernetes {
    config_path = pathexpand(var.kube_config)
  }
}

provider "kubernetes" {
  config_path = pathexpand(var.kube_config)
}

resource "kubectl_manifest" "expressapp" {
    yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: expressapp-deployment
  labels:
    app: expressapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: expressapp
  template:
    metadata:
      labels:
        app: expressapp
    spec:
      containers:
      - name: expressapp
        image: deedeo/expressapp
        ports:
        - containerPort: 3000
YAML
}

resource "kubectl_manifest" "expressapp_service" {
    yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  name: expressapp-service
spec:
  selector:
    app: expressapp
  ports:
  - port: 80
    targetPort: 3000
YAML
}


              
resource "kubectl_manifest" "expressapp_ingress" {
    yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: expressapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: expressapp-service
            port:
              number: 80
YAML
}
