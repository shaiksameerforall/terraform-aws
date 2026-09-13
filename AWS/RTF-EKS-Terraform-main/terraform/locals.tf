data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.availability_zones_count)

  private_subnets = [
    for index, az in local.azs : cidrsubnet(var.vpc_cidr, 8, index)
  ]

  public_subnets = [
    for index, az in local.azs : cidrsubnet(var.vpc_cidr, 8, index + 100)
  ]

  rtf_template_host = "app-name.${var.rtf_domain}"
}
