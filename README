Terraform Module to provision an EC2 Instances that is running Apache

Not intended for production use. Just showcasing how to create a public module on Terraform Registry


```hcl
terraform {

}

provider "aws" {
  # Configuration options
  region = "TU_REGION"
}


module "apache" {
  source          = ".//terraform-aws_apache_example"
  vpc_id          = "VPC_ID"
  my_ip_with_cidr = "A.B.C.D/NN"
  instance_type   = "INSTANCE_TYPE"
  server_name     = "SERVER_NAME"

}

output "public_ip" {
  value = module.apache.public_ip
}
```
