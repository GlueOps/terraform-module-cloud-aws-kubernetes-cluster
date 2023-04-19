


module "vpc_peering_accepter_with_routes" {
  source              = "./modules/vpc_peering_accepter_with_routes"
  main_route_table_id = module.vpc.vpc_main_route_table_id
  peering_configs     = var.peering_configs
}
