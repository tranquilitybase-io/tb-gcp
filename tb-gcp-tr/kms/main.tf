#CREATE-KEY-RING-FOR-USE-WITH-BUCKETS
resource "google_kms_key_ring" "bucket_key_ring" {
  project  = var.kms_key_ring_project_id
  name     = var.kms_key_ring_name
  location = var.kms_key_ring_location
}

#CREATE-CRYPTO-KEY-FOR-USE-WITH-BUCKETS
resource "google_kms_crypto_key" "bucket_key" {
  name = var.kms_key_name
  key_ring = google_kms_key_ring.bucket_key_ring.self_link
  rotation_period = var.kms_key_rotation_period
  purpose = var.kms_key_purpose

  version_template {
    algorithm = var.kms_key_algorithm
    protection_level = var.kms_key_protection_level
  }
}