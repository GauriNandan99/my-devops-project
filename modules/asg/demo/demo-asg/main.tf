module "asgwithlb" {
  source = "../.."
  ami_info = {
    id       = "ami-0360c520857e3138f" #ami id of ec2
    username = "ubuntu"
  }
  template_details = {
    name                        = "nginx"
    instance_type               = "t2.micro"
    key_name                    = "my_idrsa"
    #script_path                 = "installnginx.sh"
    security_group_ids          = ["sg-091f82f762a77f070"]
    associate_public_ip_address = true
  }
  scaling_details = {
    min_size   = 1
    max_size   = 2
    subnet_ids = ["subnet-067813a42fj87bebe", "subnet-04b2162ws48085216"] #subnet values can be found from output.tf of vpc module
  }
  lb_details = {
    type               = "application"
    internal           = false
    security_group_ids = ["sg-091f82f762a77f070"]
    subnet_ids         = ["subnet-067813a42fj87bebe", "subnet-04b2162ws48085216"]
    vpc_id             = "vpc-08k49f5988f46fd88"
    application_port   = 80
    port               = 80

  }


}
