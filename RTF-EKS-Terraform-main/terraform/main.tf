module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = var.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    rtf_workers = {
      name = "rtf-workers"

      instance_types = var.node_instance_types
      disk_size      = var.node_disk_size

      min_size     = var.min_node_count
      max_size     = var.max_node_count
      desired_size = var.desired_node_count

      labels = {
        workload = "runtime-fabric"
      }
    }
  }

  tags = var.tags
}

resource "terraform_data" "update_kubeconfig" {
  input = {
    cluster_name = module.eks.cluster_name
    region       = var.aws_region
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${self.input.region} --name ${self.input.cluster_name}"
  }

  depends_on = [module.eks]
}
