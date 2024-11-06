module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name               = format(module.naming.result, "alb")
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.security_group_for_alb.security_group_id]

  enable_deletion_protection = false

  target_groups = {
    backend = {
      name             = format(module.naming.result, "backend-tg")
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      target_id        = module.backend.id
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/api/health"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      create_attachment = false
    }
  }

  listeners = {
    http-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = data.aws_acm_certificate.certificate.arn
      fixed_response = {
        content_type = "text/plain"
        status_code  = 403
        message_body = "invalid access"
      }
      rules = {
        backend-rule = {
          priority = 1
          actions = [
            {
              type             = "forward"
              target_group_key = "backend"
            }
          ]
          conditions = [
            {
              host_header = {
                values = ["tmr.${var.domain_name}"]
              }
            }
          ]
        }
      }
    }
  }
}
