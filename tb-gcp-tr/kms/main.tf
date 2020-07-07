resource "random_id" "rannum" {
  byte_length = var.random_num_len
}

#CREATE-KEY-RING-FOR-USE-WITH-BUCKETS
resource "google_kms_key_ring" "bucketkeyring" {
  name     = "terraform-key-ring-${random_id.rannum.hex}"
  location = var.kms_ring_location
}

#CREATE-CRYPTO-KEY-FOR-USE-WITH-BUCKETS
resource "google_kms_crypto_key" "key" {
  name = "terraform-key-ring-${random_id.rannum.hex}"
  key_ring = google_kms_key_ring.bucketkeyring.self_link
  rotation_period = var.kms_key_rotation_period
  purpose = var.kms_key_purpose

  version_template {
    algorithm = var.kms_key_algorithm
    protection_level = var.kms_key_protection_level
  }
}