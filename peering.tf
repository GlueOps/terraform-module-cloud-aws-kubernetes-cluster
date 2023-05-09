


module "vpc_peering_accepter_with_routes" {
  source          = "./modules/vpc_peering_accepter_with_routes"
  route_table_ids = concat(module.subnets.private_route_table_ids, module.subnets.public_route_table_ids)
  peering_configs = var.peering_configs
}
