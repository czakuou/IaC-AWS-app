output "vpc" {
  value = module.vpc
}

output "sg" {
  value = {
    pub = module.pub_sg.security_group.id
    db  = module.db_sg.security_group.id
    app = module.app_sg.security_group.vpc_id
  }
}
