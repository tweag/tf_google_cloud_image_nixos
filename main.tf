variable "bucket_name" {
  description = "Bucket where to store the image"
}

variable "nixos_config" {
  description = "Path to a nixos configuration.nix file"
}

# ----------------------------------------------------

data "external" "nix_build" {
  program = ["${path.module}/nixos-build.sh", "${var.nixos_config}"]
}

locals {
  out_path   = "${data.external.nix_build.result.out_path}"
  image_path = "${data.external.nix_build.result.image_path}"

  # 3x2d4rdm9kjzk9d9sz87rmhzvcphs23v
  out_hash = "${element(split("-", basename(local.out_path)), 0)}"

  # Example: 3x2d4rdm9kjzk9d9sz87rmhzvcphs23v-19-03pre-git-x86-64-linux
  #
  # Remove a few things so that it matches the required regexp for image names
  #   (?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)
  image_name = "x${substr(local.out_hash, 0, 12)}-${replace(replace(basename(local.image_path), "/\\.raw\\.tar\\.gz|nixos-image-/", ""), "/[._]+/", "-")}"

  # 3x2d4rdm9kjzk9d9sz87rmhzvcphs23v-nixos-image-19.03pre-git-x86_64-linux.raw.tar.gz
  image_filename = "${local.out_hash}-${basename(local.image_path)}"
}

resource "google_storage_bucket_object" "nixos" {
  name         = "images/${local.image_filename}"
  source       = "${local.image_path}"
  bucket       = "${var.bucket_name}"
  content_type = "application/tar+gzip"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_image" "nixos" {
  name   = "${local.image_name}"
  family = "nixos"

  raw_disk {
    source = "https://${var.bucket_name}.storage.googleapis.com/${google_storage_bucket_object.nixos.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "self_link" {
  value = "${google_compute_image.nixos.self_link}"
}
