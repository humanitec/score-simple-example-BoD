# cloud provider and access details
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region}"
}
 
module "vpc" {
  source           = "./network/vpc"
  cidr_block       = "${var.cidr_block}"
 }
 
module "subnets" {
  source           = "./network/subnets"
  vpc_id           = "${module.vpc.vpc_id}"
  vpc_cidr_block   = "${module.vpc.vpc_cidr_block}"
}
 
module "route" {
  source              = "./network/route"
  main_route_table_id = "${module.vpc.main_route_table_id}"
  gw_id               = "${module.vpc.gw_id}"
 
  subnets = [
    "${module.subnets.subnets}",
  ]
}
 
 module "sec_group_rds" {
   source         = "./network/sec_group"
   vpc_id         = "${module.vpc.vpc_id}"
   vpc_cidr_block = "${module.vpc.vpc_cidr_block}"
 } 
 
module "mariadbrds" {
  source = "./rds"
 
  subnets = [
    "${module.subnets.subnets}",
  ]
 
  db_sub_gr_name    = "mariadbrdssub_gr_name"
  sec_grp_rds       = "${module.sec_group_rds.sec_grp_rds}"
  identifier        = "mariadbrds"
  storage_type      = "${var.storage_type}"
  allocated_storage = "${var.allocated_storage}"
  db_engine         = "mariadb"
  engine_version    = "10.3"
  instance_class    = "${var.instance_class}"
  db_username       = "${var.db_username}"
  db_password       = "${var.db_password}"
}
