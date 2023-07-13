resource "random_id" "random_id" {
  byte_length = 8
}

# Create random integer, string, UID, pet, password
resource "random_integer" "random_integer" {
  min = 1000
  max = 9999
}

resource "random_string" "random_string" {
  length  = 8
  special = false
  upper   = false
  number  = false
}

resource "random_uuid" "random_uuid" {}

resource "random_pet" "random_pet" {
  length = 3
  prefix = "parth-tf"
}

resource "random_password" "random_password" {
  length           = 16
  special          = true
  override_special = "_%@!"
}
