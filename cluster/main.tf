terraform {
  required_providers {
    azureopenshift = {
      source  = "rh-mobb/azureopenshift"
      version = "~> 0.0.16"
    }
  }
}

provider azureopenshift {
}

resource "azureopenshift_redhatopenshift_cluster" "tf-cluster" {
  name                = "tf-example"
  location            = var.location
  resource_group_name = var.resource_group_name

  master_profile {
    subnet_id = var.master_subnet_id
  }

  worker_profile {
    subnet_id = var.worker_subnet_id
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
}
