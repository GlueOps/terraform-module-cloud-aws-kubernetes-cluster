variable "peering_configs" {
  description = "A list of maps containing VPC peering configuration details"
  type = list(object({
    vpc_peering_connection_id = string
    destination_cidr_block    = string
  }))
  default = []
}

variable "route_table_ids" {
  description = "A list of route table ids"
  type        = list(string)
}

locals {
  peering_configs_map = {
    for pc in var.peering_configs :
    pc.vpc_peering_connection_id => pc
  }
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  for_each = local.peering_configs_map

  vpc_peering_connection_id = each.key
  auto_accept               = true
}

locals {
  peering_routes = flatten([
    for pc in var.peering_configs : [
      for rt_id in var.route_table_ids : {
        vpc_peering_connection_id = pc.vpc_peering_connection_id
        destination_cidr_block    = pc.destination_cidr_block
        route_table_id            = rt_id
      }
    ]
  ])
}

resource "aws_route" "peering_routes" {
  for_each = {
    for pr in local.peering_routes :
    "${pr.vpc_peering_connection_id}-${pr.route_table_id}" => pr
  }

  route_table_id            = each.value.route_table_id
  destination_cidr_block    = each.value.destination_cidr_block
  vpc_peering_connection_id = each.value.vpc_peering_connection_id
}

