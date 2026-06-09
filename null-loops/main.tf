/* Alta3 Research - rzfeeser@alta3.com
Working with "for_each" within a null_resource */

/* Terraform block */
terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
  }
}

/* provider block */
provider "null" {
  # Configuration options
}

/* a list of local variables */
locals {
  alignment = {
    hero      = "good"
    villain   = "bad"
    anti-hero = "neutral"
  }

  avengers = {
    ironman           = "hero"
    "captain america" = "hero"
    thanos            = "villain"
    venom             = "anti-hero"
  }

  # Build a nested map (map → map)
  avengers_nested = {
    for name, align_key in local.avengers : name => {
      alignment_type = align_key
      moral_status   = local.alignment[align_key]
    }
  }
}


resource "null_resource" "avengers" {
  # Loop through all top‑level keys in the nested map
  for_each = local.avengers_nested

  triggers = {
    name           = each.key
    alignment_type = each.value.alignment_type
    moral_status   = each.value.moral_status
  }
}


/* We want these outputs */
output "avengers" {
  value = null_resource.avengers
}

