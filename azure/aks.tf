resource "azurerm_kubernetes_cluster" "ea2_aks" {
    name =  "ea2_aks"
    location = azurerm_resource_group.ea2_rg_az.location
    resource_group_name = azurerm_resource_group.ea2_rg_az.name
    dns_prefix = "ea2aks1"
    
    default_node_pool {
        name       = "ea2nodepool1"
        node_count = 1
        vm_size    = "Standard_D2_v2"
        vnet_subnet_id = azurerm_subnet.ea2_pvsubnet.id
    }
      
    identity {
        type = "SystemAssigned"
    }
}