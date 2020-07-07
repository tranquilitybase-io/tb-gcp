output "shared_services_writer_identity" {
  value = google_logging_folder_sink.sink.writer_identity
}

output "applications_writer_identity" {
  value = google_logging_folder_sink.sink.writer_identity
}