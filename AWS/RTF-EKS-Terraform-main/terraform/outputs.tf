output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.eks.cluster_endpoint
}

output "aws_region" {
  description = "AWS region."
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs."
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnets
}

output "kubeconfig_command" {
  description = "Command to update local kubeconfig."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "nginx_load_balancer_lookup_command" {
  description = "Command to retrieve the NGINX LoadBalancer hostname."
  value       = "kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "rtf_wildcard_dns_instruction" {
  description = "DNS instruction for Runtime Fabric Mule app hostnames."
  value       = "Create wildcard DNS: *.${var.rtf_domain} -> NGINX LoadBalancer hostname"
}
