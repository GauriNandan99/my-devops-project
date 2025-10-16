module "vpc" {
    source = "./modules/vpc"
    vpc_info = {
    cidr_block           = "192.160.0.0/16"
    enable_dns_hostnames = true
    tags = {
      Name    = "simple-vpc"
      Purpose = "demo"
    }
  }
  public_subnets = [{
    cidr_block = "192.160.0.0/24"
    az         = "ap-south-1a"
    tags = {
      Name = "demo-public"
    }
  }]
  private_subnets = [{
    cidr_block = "192.160.1.0/24"
    az         = "ap-south-1a"
    tags = {
      Name = "demo-private"
    }
    }

  ]
  
}