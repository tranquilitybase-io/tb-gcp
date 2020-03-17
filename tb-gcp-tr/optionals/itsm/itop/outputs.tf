# iTop deployment
output "itop_db_user_password" {
  value = module.itop.database_instance_connection_password
}