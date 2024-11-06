//ACM is created manually in the AWS console
data "aws_acm_certificate" "certificate" {
  domain = var.domain_name
}
