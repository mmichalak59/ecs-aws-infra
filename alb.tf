module "alb" {
  source = "cloudposse/alb/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"

  namespace  = var.namespace
  stage      = var.stage
  name       = var.name

  vpc_id                                  = aws_vpc.main.id
  security_group_ids                      = [aws_security_group.allin.id]
  subnet_ids                              = [aws_subnet.public-subnet-a.id,aws_subnet.public-subnet-b.id]
  internal                                = false
  http_enabled                            = true

  target_group_port                       = "5000"
  target_group_target_type                = "ip"
  access_logs_enabled                     = false
}