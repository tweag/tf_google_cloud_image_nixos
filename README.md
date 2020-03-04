# google_cloud_image_nixos

**Deprecated. Replaced by https://github.com/tweag/terraform-nixos/**

This terraform module builds and publishes custom NixOS Google Cloud images.

## Runtime dependencies

Because this module uses the "external" provider it needs the following
executables to be in the path to work properly:

* bash
* nix
* `readlink -f` (busybox or coreutils)

## Known issues

When a new image is published, the old-one gets removed. This potentially
introduces a race-condition where other targets are trying to create new
instances with the old image.

To reduce the race window, `create_before_destroy` is being used. See
https://github.com/hashicorp/terraform/issues/15485 for related discussions.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bucket_name | Bucket where to store the image | string | - | yes |
| nixos_config | Path to a nixos configuration.nix file | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| self_link |  |

## LICENSE

Apache 2.0

## Thanks

Many thanks to [Digital Asset](https://www.digital-asset.com) for sponsoring
this work.

