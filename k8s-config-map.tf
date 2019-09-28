data "external" "aws_iam_authenticator" {
  program = [
    "sh",
    "-c",
    "aws-iam-authenticator token -i ${var.cluster-name} | jq -r -c .status"]
}

locals {
  config-map-aws-auth = <<CONFIGMAPAWSAUTH

apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

provider "kubernetes" {
  host = aws_eks_cluster.eks-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster.certificate_authority.0.data)
  token = data.external.aws_iam_authenticator.result.token
  load_config_file = false
  version = "~> 1.5"
}

resource "kubernetes_config_map" "aws_auth_cm" {
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = <<EOF
- rolearn: ${aws_iam_role.eks-node.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
EOF
  }

  depends_on = [
    aws_eks_cluster.eks-cluster]
}
