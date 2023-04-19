variable "peering_configs" {
  description = "A list of maps containing VPC peering configuration details"
  type = list(object({
    vpc_peering_connection_id  = string
    destination_cidr_block     = string
    route_table_ids            = list(string)
  }))
  default = []
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  count = length(var.peering_configs) > 0 ? length(var.peering_configs) : 0

  vpc_peering_connection_id = var.peering_configs[count.index].vpc_peering_connection_id
  auto_accept               = true
}

locals {
  peering_routes = flatten([
    for pc in var.peering_configs : [
      for rt_id in pc.route_table_ids : {
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

output "vpc_peering_connection_ids" {
  value = aws_vpc_peering_connection_accepter.accepter.*.id
}
