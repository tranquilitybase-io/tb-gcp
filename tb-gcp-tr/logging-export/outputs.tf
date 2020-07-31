output "bucket_name_ss" {
  value = module.logging_buckets.names_list[0]
}

output "bucket_name_apps" {
  value = module.logging_buckets.names_list[1]
}