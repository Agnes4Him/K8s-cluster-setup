module "networking" {
  source          = "./modules/networking"
  name            = var.name
  vpc_cidr        = var.vpc_cidr
  public_subnet   = var.public_subnet
  private_subnet  = var.private_subnet
  azs             = var.azs
}

module "compute" {
  source            = "./modules/compute"
  name              = var.name
  ami               = var.ami
  k8s_type          = var.k8s_type
  bastion_type      = var.bastion_type
  k8s_sg         = module.networking.k8s_sg
  bastion_sg     = module.networking.bastion_sg
  private_subnet_id = module.networking.private_subnet_id
  public_subnet_id  = module.networking.public_subnet_id
}
