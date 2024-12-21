resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private" {
  content  = trimspace(tls_private_key.ssh_key.private_key_pem)
  filename = "./private.pem"
}

resource "azurerm_virtual_network" "main-vnet" {
  name                = "daniel-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.Region
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "subnet" {
  name                 = "main-subnet"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.main-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "vm-nsg" {
  name                = "jenkins-nsg"
  location            = var.Region
  resource_group_name = var.resource_group

  dynamic "security_rule" {
    for_each = var.securityRules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_public_ip" "vm-pip" {
  name                = "jenkins-PublicIp"
  resource_group_name = var.resource_group
  location            = var.Region
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vm-nic" {
  name                = "Jenkins-nic"
  location            = var.Region
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "Jenkins-ip"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg-nic-connection" {
  network_interface_id      = azurerm_network_interface.vm-nic.id
  network_security_group_id = azurerm_network_security_group.vm-nsg.id
}

resource "azurerm_linux_virtual_machine" "jenking-server" {
  name                = "jenkins-server"
  resource_group_name = var.resource_group
  location            = var.Region
  size                = "Standard_D2s_v5"
  admin_username      = var.Vm_username
  network_interface_ids = [
    azurerm_network_interface.vm-nic.id
  ]


  admin_ssh_key {
    username   = var.Vm_username
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  admin_password = var.vm_password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.vm-nic,
    tls_private_key.ssh_key,
    azurerm_subnet.subnet,
    azurerm_virtual_network.main-vnet
  ]

  connection {
    type        = "ssh"
    user        = var.Vm_username
    private_key = tls_private_key.ssh_key.private_key_pem
    host        = self.public_ip_address
  }
  provisioner "remote-exec" {
    inline = [
      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
      "echo \"deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]\" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install ca-certificates curl -y",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt install fontconfig openjdk-17-jre -y",
      "sudo apt-get install jenkins git-all docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y"
    ]
  }
}

resource "azurerm_key_vault" "daniel-keyvault" {
  tenant_id           = data.azurerm_client_config.currentConfig.tenant_id
  location            = var.Region
  name                = "daniel-keyvault-121312"
  resource_group_name = var.resource_group
  sku_name            = "standard"
}

resource "azurerm_kubernetes_cluster" "Orca-Cluster" {
  name                = "Orca-Cluster"
  location            = var.Region
  resource_group_name = var.resource_group
  dns_prefix          = "orcacluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v5"
  }
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "AKStoKVAccess" {
  key_vault_id = azurerm_key_vault.daniel-keyvault.id
  tenant_id    = data.azurerm_client_config.currentConfig.tenant_id
  object_id    = azurerm_kubernetes_cluster.Orca-Cluster.key_vault_secrets_provider[0].secret_identity[0].object_id
  secret_permissions = [
    "Get", "List"
  ]
}

resource "azurerm_public_ip" "aks-pip" {
  name                = "aks-PublicIp"
  resource_group_name = azurerm_kubernetes_cluster.Orca-Cluster.node_resource_group
  location            = var.Region
  allocation_method   = "Static"
}

resource "azurerm_dns_zone" "ingress-domain-name" {
  name                = "danielDomain.local"
  resource_group_name = var.resource_group
}

resource "azurerm_dns_a_record" "ingrees-domain-record" {
  name                = "www"
  resource_group_name = var.resource_group
  zone_name           = azurerm_dns_zone.ingress-domain-name.name
  ttl                 = var.ttl
  records             = [azurerm_public_ip.aks-pip.ip_address]
}

resource "kubernetes_namespace" "nginix_ingress_namespace" {
  metadata {
    name = var.ngnix_namespace
  }
}

resource "helm_release" "nginix_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = var.ngnix_namespace
  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.aks-pip.ip_address
  }
  depends_on = [kubernetes_namespace.nginix_ingress_namespace, azurerm_public_ip.aks-pip]
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "example_hpa" {
  metadata {
    name      = "example-hpa"
    namespace = "default"
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = helm_release.nginix_ingress.name
    }

    min_replicas = 2
    max_replicas = 10

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 50
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = 70
        }
      }
    }
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "DanielAcrRegistry"
  location            = var.Region
  resource_group_name = var.resource_group
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_role_assignment" "example" {
  principal_id                     = azurerm_kubernetes_cluster.Orca-Cluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
