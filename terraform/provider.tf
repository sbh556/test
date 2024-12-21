terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.30.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "2fa0e512-f70e-430f-9186-1b06543a848e"
  features {}
}

provider "tls" {}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.Orca-Cluster.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.Orca-Cluster.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.Orca-Cluster.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.Orca-Cluster.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.Orca-Cluster.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.Orca-Cluster.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.Orca-Cluster.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.Orca-Cluster.kube_config.0.cluster_ca_certificate)
}
