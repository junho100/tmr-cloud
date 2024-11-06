data "aws_route53_zone" "target_host_zone" {
  provider = aws.cheego

  name = "${var.domain_name}."
}

module "route53_records" {
  source = "terraform-aws-modules/route53/aws//modules/records"

  zone_id = data.aws_route53_zone.target_host_zone.zone_id

  providers = {
    aws = aws.cheego
  }

  records = [
    {
      name = "tmr"
      type = "A"
      alias = {
        name    = module.alb.dns_name
        zone_id = module.alb.zone_id
      }
    },
  ]
}
