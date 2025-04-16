module "rds_instance" {
    source = "cloudposse/rds/aws"
    depends_on = [aws_subnet.private-subnet-a,aws_subnet.private-subnet-b]
    namespace  = var.namespace
    stage      = var.stage
    name       = "rds"
    enabled    = true
    host_name                   = "db"
    associate_security_group_ids = [aws_security_group.allow_sql.id]
    database_name               = "pna"
    database_user               = "admin"
    database_password           = "password"
    database_port               = 3306
    multi_az                    = false
    storage_type                = "gp2"
    allocated_storage           = 20
    storage_encrypted           = false
    engine                      = "mysql"
    engine_version              = "8.0.40"
    major_engine_version        = "8.0"
    instance_class              = "db.t4g.micro"
    db_parameter_group          = "mysql8.0"
    publicly_accessible         = false
    subnet_ids                  = [aws_subnet.private-subnet-a.id,aws_subnet.private-subnet-b.id]
    vpc_id                      = aws_vpc.main.id

}