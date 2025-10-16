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

module "websg" {
  source = "./modules/sg"
  vpc_id = module.vpc.id
  security_group_info = {
    name        = "web"
    description = "this opens 80 and 22 port"
    inbound_rules = [{
      port        = 22
      protocol    = "tcp"
      source      = "0.0.0.0/0"
      description = "open ssh"
      }, {
      port        = 80
      protocol    = "tcp"
      source      = "0.0.0.0/0" #this is for demo, when using in production select vpc-cidr/ALB sg or any other appropriate range but not 0.0.0.0/0
      description = "open http"
      }, {
      port        = 443
      protocol    = "tcp"
      source      = "0.0.0.0/0" #this is for demo, when using in production select vpc-cidr/ALB sg or any other appropriate range but not 0.0.0.0/0
      description = "open https"
    }]
  }

}