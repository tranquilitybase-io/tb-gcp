/**
* # gcp-org-policies
*
* ## Pre-Requisites
* IAM role Organization Policy Administrator is required at the Organization level.
*
* ## Usage
*
* 1. Apply policies at organization, folder or project level.
*
* 1. Create a policies.yaml file with the policy definitions.
*
* 1. Policy examples can be found in the [example](example) folder
*
* 1. Create terraform.tfvars file and add values for `org_id`, `folder_id` and `project_id`.
*
*
* ## Issues
* Line 138: main.tf
* for_each   = (local.project_list_policies && var.project_id != null) ? local.policies.project_list_policies : null
*
* If a value for project_list_policies is NOT provided in the policies.yaml then null needs changing to {}
*
* Otherwise the error below is returned:
* The true and false result expressions must have consistent types. The given expressions are object and object, respectively.
*
*/

locals {
  org_boolean_constraints     = contains(keys(local.policies), "org_boolean_constraints")
  org_list_policies           = contains(keys(local.policies), "org_list_policies")
  folder_boolean_constraints  = contains(keys(local.policies), "folder_boolean_constraints")
  folder_list_policies        = contains(keys(local.policies), "folder_list_policies")
  project_boolean_constraints = contains(keys(local.policies), "project_boolean_constraints")
  project_list_policies       = contains(keys(local.policies), "project_list_policies")
}

###
#  Apply Organization Policies defined in yaml file
###
locals {
  policies = yamldecode(file(var.policy_file_name))
}

resource "google_organization_policy" "org_boolean_constraints" {
  for_each   = (local.org_boolean_constraints && var.org_id != null) ? toset(local.policies.org_boolean_constraints) : toset([])
  org_id     = var.org_id
  constraint = each.value

  boolean_policy {
    enforced = true
  }
}

data "external" "org_list_policies" {
  program = ["bash", "${path.module}/get_policy.sh", local.org_list_policies]
}

resource "google_organization_policy" "org_list_policies" {
  //for_each   = (local.org_list_policies && var.org_id != null) ? local.policies.org_list_policies : {} or null
  for_each   = (local.org_list_policies && var.project_id != null) ? local.policies.org_list_policies : jsondecode(data.external.org_list_policies.result["policy"])
  org_id     = var.org_id
  constraint = each.key

  list_policy {
    dynamic "allow" {
      for_each = contains(keys(lookup(each.value.list_policy, "allow", {})), "all") ? { a : each.value.list_policy.allow.all } : {}
      content {
        all = allow.value
      }
    }
    dynamic "allow" {
      for_each = contains(keys(lookup(each.value.list_policy, "allow", {})), "values") ? { a : each.value.list_policy.allow.values } : {}
      content {
        values = allow.value
      }
    }
    dynamic "deny" {
      for_each = contains(keys(lookup(each.value.list_policy, "deny", {})), "all") ? { a : each.value.list_policy.deny.all } : {}
      content {
        all = deny.value
      }
    }
    dynamic "deny" {
      for_each = contains(keys(lookup(each.value.list_policy, "deny", {})), "values") ? { a : each.value.list_policy.deny.values } : {}
      content {
        values = deny.value
      }
    }
  }
}

###
#  Apply Folder Policies defined in yaml file
###
resource "google_folder_organization_policy" "folder_boolean_constraints" {
  for_each   = (local.folder_boolean_constraints && var.folder_id != null) ? toset(local.policies.folder_boolean_constraints) : toset([])
  folder     = var.folder_id
  constraint = each.value

  boolean_policy {
    enforced = true
  }
}

data "external" "folder_list_policies" {
  program = ["bash", "${path.module}/get_policy.sh", local.folder_list_policies]
}

resource "google_folder_organization_policy" "folder_list_policies" {
  //for_each   = (local.folder_list_policies && var.folder_id != null) ? local.policies.folder_list_policies : {} or null
  for_each   = (local.folder_list_policies && var.project_id != null) ? local.policies.folder_list_policies : jsondecode(data.external.folder_list_policies.result["policy"])
  folder     = var.folder_id
  constraint = each.key

  list_policy {
    dynamic "allow" {
      for_each = contains(keys(lookup(each.value.list_policy, "allow", {})), "all") ? { a : each.value.list_policy.allow.all } : {}
      content {
        all = allow.value
      }
    }
    dynamic "allow" {
      for_each = contains(keys(lookup(each.value.list_policy, "allow", {})), "values") ? { a : each.value.list_policy.allow.values } : {}
      content {
        values = allow.value
      }
    }
    dynamic "deny" {
      for_each = contains(keys(lookup(each.value.list_policy, "deny", {})), "all") ? { a : each.value.list_policy.deny.all } : {}
      content {
        all = deny.value
      }
    }
    dynamic "deny" {
      for_each = contains(keys(lookup(each.value.list_policy, "deny", {})), "values") ? { a : each.value.list_policy.deny.values } : {}
      content {
        values = deny.value
      }
    }
  }
}

###
#  Apply Project Policies defined in yaml file
####
resource "google_project_organization_policy" "project_boolean_constraints" {
  for_each   = (local.project_boolean_constraints && var.project_id != null) ? toset(local.policies.project_boolean_constraints) : toset([])
  project    = var.project_id
  constraint = each.value

  boolean_policy {
    enforced = true
  }
}

data "external" "project_list_policies" {
  program = ["bash", "${path.module}/get_policy.sh", local.project_list_policies]
}

resource "google_project_organization_policy" "project_list_policies" {
  //for_each   = (local.project_list_policies && var.project_id != null) ? local.policies.project_list_policies : {} or null
  for_each   = (local.project_list_policies && var.project_id != null) ? local.policies.project_list_policies : jsondecode(data.external.project_list_policies.result["policy"])
  project    = var.project_id
  constraint = each.key

  list_policy {
    dynamic "allow" {
      for_each = contains(keys(lookup(each.value.list_policy, "allow", {})), "all") ? { a : each.value.list_policy.allow.all } : {}
      content {
        all = allow.value
      }
    }
    dynamic "allow" {
      for_each = contains(keys(lookup(each.value.list_policy, "allow", {})), "values") ? { a : each.value.list_policy.allow.values } : {}
      content {
        values = allow.value
      }
    }
    dynamic "deny" {
      for_each = contains(keys(lookup(each.value.list_policy, "deny", {})), "all") ? { a : each.value.list_policy.deny.all } : {}
      content {
        all = deny.value
      }
    }
    dynamic "deny" {
      for_each = contains(keys(lookup(each.value.list_policy, "deny", {})), "values") ? { a : each.value.list_policy.deny.values } : {}
      content {
        values = deny.value
      }
    }
  }
}
