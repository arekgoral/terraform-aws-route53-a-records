# create A records in route53 from a local file byip.txt 

# define mydomain.com zone in the AWS route53
resource "aws_route53_zone" "mydomain_com" {
  name = "mydomain.com"
}

# extract the hostnames and corresponding ips from the local file as local vars
# create a map of IP addresses and DNS names then 
locals {
  file_contents = file("byip.txt")
  split_lines   = split("\n", local.file_contents)
  split_values  = [split(",", local.split_lines[0]), split(",", local.split_lines[1])]
  map_of_records = { for idx, val in local.split_values[0] : val => local.split_values[1][idx] }
}

# use this map to create separate instances of the aws_route53_record resource, one for each key-value pair in the map
resource "aws_route53_record" "dns_records" {
  for_each = local.map_of_records
  zone_id  = aws_route53_zone.mydomain_com.zone_id
  name     = each.value
  type     = "A"
  ttl      = "300"
  records  = [each.key]
}


output "map_of_records" {
  value = local.map_of_records
}