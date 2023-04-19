


module "vpc_peering_accepter_with_routes" {
  source = "./modules/vpc_peering_accepter_with_routes"

  peering_configs = [
    {
      vpc_peering_connection_id  = "pcx-xxxxxxxxxxxx1"
      destination_cidr_block     = "10.1.0.0/16"
      route_table_ids            = [module.vpc.vpc_main_route_table_id]
    },
  ]
}
