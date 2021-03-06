provider "azurerm" {
  version = "=2.5.0"
  features {}

  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  #version = "=1.36.0"
}

resource "azurerm_resource_group" "test" {
  name     = "my-resources"
  location = "West Europe"
}

module "network" {
  source  = "app.terraform.io/JoeStack/network/azurerm"
  version = "3.0.1"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]

  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}

module "compute" {
  source  = "app.terraform.io/JoeStack/compute/azurerm"
  version = "3.0.0"
  resource_group_name = azurerm_resource_group.test.name
  is_windows_image    = true
  vm_hostname         = "mywinvm" // line can be removed if only one VM module per resource group
  admin_password      = "ComplxP@ssw0rd!"
  vm_os_simple        = "WindowsServer"
  public_ip_dns       = ["joexxsipsfoobar"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.network.vnet_subnets[0]
  
  tags = {
    environment = "dev"
    costcenter  = "it"
    department  = "devops"
  }
}

output "windows_vm_public_name" {
  value = module.compute.public_ip_dns_name
}

