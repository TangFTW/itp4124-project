resource "aws_security_group" "rds_sg" {
  name        = "ea2_rds_sg"
  vpc_id      = aws_vpc.ea2_vpc.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_eg_rds" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_f_node" {
  security_group_id = aws_security_group.rds_sg.id
  referenced_security_group_id = aws_eks_cluster.ea2_eks.vpc_config[0].cluster_security_group_id
  ip_protocol = -1
}
/*
resource "aws_vpc_security_group_ingress_rule" "allow_all_f_dev" {
  security_group_id = aws_security_group.rds_sg.id
  referenced_security_group_id = "sg-06654b8d6a913c78c"
  ip_protocol = -1
}
*/
resource "aws_vpc_security_group_ingress_rule" "allow_all_f_azure" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4 = "10.10.0.0/16"
  ip_protocol = -1
}

resource "aws_db_subnet_group" "ea2_db_sng" {
    name       = "ea2_db_sng"
    subnet_ids = [aws_subnet.ea2_psn1.id,aws_subnet.ea2_psn2.id]

    tags = {
        Name = "EA2 DB subnet group"
  }
}

resource "aws_db_instance" "ea2_rds" {
    allocated_storage = 10
    db_name = "ea2_rds"
    engine = "mysql"
    engine_version = "8.0.35"
    instance_class = "db.t3.micro"
    username = "ea2rdsadmin"
    password = "1016385336qQ"
    skip_final_snapshot  = true
    vpc_security_group_ids = [aws_security_group.rds_sg.id]
    db_subnet_group_name = aws_db_subnet_group.ea2_db_sng.name
    publicly_accessible = false
}