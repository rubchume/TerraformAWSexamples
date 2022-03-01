aws_region  = "us-west-2"
aws_profile = "udacity_student"

dwh_iam_role_name = "dwhRole"

vpc_cidr               = "10.0.0.0/16"
redshift_subnet_cidr_1 = "10.0.1.0/24"
redshift_subnet_cidr_2 = "10.0.2.0/24"

subnet_availability_zone = "us-west-2a"

rs_cluster_identifier      = "dwh-cluster"
rs_database_name           = "dwh"
rs_master_username         = "dwhuser"
rs_master_pass             = "Passw0rd"
rs_nodetype                = "dc2.large"
rs_cluster_type            = "multi-node"
rs_cluster_number_of_nodes = 4
