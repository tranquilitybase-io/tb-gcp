output "applications_writer_identity" {
  value = google_folder_iam_member.applications_folder_loggingConfigWriter_to_bootstrap-sa
}
output "shared_services_writer_identity" {
  value = google_folder_iam_member.shared_services_folder_loggingConfigWriter_to_bootstrap-sa
}
