module "label" {
  source  = "cloudposse/label/null"

  namespace = "private"
  name      = "pna"
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCThkLeft6bXLrFpeAivwwTNlRcJx5u5U0EbZvlwsmwu4aWtzP5iFS7tKVdrEu1uRs8/93oeAlhOCX1171NA2JW4WWZ2T8ovWvB/mbAioJAm3LdPzpOF4K1nNs6TzgMbFSQ8uef/vIkI7Ry7C34GwMP7sU/3EEmz6j9TtS8Iyx7SKquFMdLd6KYeWTWnw5Mr12HEuuER3xT/5ywSpo8GunrehQ9NlJN3m9jKdmBnlQe1V0tC6mamzWH4lUrLohwMdIzXamIET39Vxe06qWajAX9jfYxBGFPrT/LuvvZjnL1tsPiVI3wAm+Qim73iUCuKGu5cUSbrMjg1MXBF/XkVsZz maciej@office"
}

module "ecs_cluster" {
  source = "cloudposse/ecs-cluster/aws"

  context = module.label.context

  capacity_providers_ec2 = {
    pna = {
      image_id                    = "ami-082efb76d7dd52982"
      instance_type               = "t3.medium"
      key_name                    = "ec2-key"
      security_group_ids          = [aws_security_group.allin.id]
      subnet_ids                  = [aws_subnet.private-subnet-a.id,aws_subnet.private-subnet-b.id]
      associate_public_ip_address = false
      min_size                    = 1
      max_size                    = 1
    }
  }
}

module "ecs_alb_service_task_pna" {
  source = "cloudposse/ecs-alb-service-task/aws"
  
  namespace                          = var.namespace
  stage                              = var.stage
  name                               = var.name

  alb_security_group                 = aws_security_group.allin.id
  container_definition_json          = file("pna-revision2.json")
  ecs_cluster_arn                    = module.ecs_cluster.arn
  ecs_load_balancers                 =  [{
    container_name   = "pna"
    container_port   = 5000
    elb_name         = null
    target_group_arn = module.alb.default_target_group_arn
  }]

  launch_type                        = "EC2"
  vpc_id                             = aws_vpc.main.id
  security_group_ids                 = [aws_security_group.allin.id]
  subnet_ids                         = [aws_subnet.private-subnet-a.id,aws_subnet.private-subnet-b.id]
  network_mode                       = "awsvpc"
  desired_count                      = 1

}