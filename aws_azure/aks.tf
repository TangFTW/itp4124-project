data "azurerm_subscription" "current" {
}

resource "azurerm_role_definition" "ea2_aksrole_az" {
  name        = "forAKS"
  scope       = data.azurerm_subscription.current.id
  description = "This is a custom role create fo aks managed azure resource"

    permissions {
        actions = [
          "Microsoft.ContainerService/managedClusters/*",
          "Microsoft.Network/loadBalancers/delete",
          "Microsoft.Network/loadBalancers/read",
          "Microsoft.Network/loadBalancers/write",
          "Microsoft.Network/publicIPAddresses/delete",
          "Microsoft.Network/publicIPAddresses/read",
          "Microsoft.Network/publicIPAddresses/write",
          "Microsoft.Network/publicIPAddresses/join/action",
          "Microsoft.Network/networkSecurityGroups/read",
          "Microsoft.Network/networkSecurityGroups/write",
          "Microsoft.Compute/disks/delete",
          "Microsoft.Compute/disks/read",
          "Microsoft.Compute/disks/write",
          "Microsoft.Compute/locations/DiskOperations/read",
          "Microsoft.Storage/storageAccounts/delete",
          "Microsoft.Storage/storageAccounts/listKeys/action",
          "Microsoft.Storage/storageAccounts/read",
          "Microsoft.Storage/storageAccounts/write",
          "Microsoft.Storage/operations/read",
          "Microsoft.Network/routeTables/read",
          "Microsoft.Network/routeTables/routes/delete",
          "Microsoft.Network/routeTables/routes/read",
          "Microsoft.Network/routeTables/routes/write",
          "Microsoft.Network/routeTables/write",
          "Microsoft.Compute/virtualMachines/read",
          "Microsoft.Compute/virtualMachines/write",
          "Microsoft.Compute/virtualMachineScaleSets/read",
          "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/read",
          "Microsoft.Compute/virtualMachineScaleSets/virtualmachines/instanceView/read",
          "Microsoft.Network/networkInterfaces/write",
          "Microsoft.Compute/virtualMachineScaleSets/write",
          "Microsoft.Compute/virtualMachineScaleSets/delete",
          "Microsoft.Compute/virtualMachineScaleSets/virtualmachines/write",
          "Microsoft.Network/networkInterfaces/read",
          "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/networkInterfaces/read",
          "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/networkInterfaces/ipconfigurations/publicipaddresses/read",
          "Microsoft.Network/virtualNetworks/read",
          "Microsoft.Network/virtualNetworks/subnets/read",
          "Microsoft.Compute/snapshots/delete",
          "Microsoft.Compute/snapshots/read",
          "Microsoft.Compute/snapshots/write",
          "Microsoft.Compute/locations/vmSizes/read",
          "Microsoft.Compute/locations/operations/read",
          "Microsoft.Network/networkSecurityGroups/write",
          "Microsoft.Network/networkSecurityGroups/read",
          "Microsoft.Network/virtualNetworks/subnets/read",
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/routeTables/routes/read",
          "Microsoft.Network/routeTables/routes/write",
          "Microsoft.Network/virtualNetworks/subnets/read"
        ]
        not_actions = []
      }

  assignable_scopes = [
    data.azurerm_subscription.current.id, # /subscriptions/00000000-0000-0000-0000-000000000000
  ]
}

resource "azurerm_user_assigned_identity" "ea2_aks_identity" {
  location            = azurerm_resource_group.ea2_rg_az.location
  name                = "ea2_aks_identity"
  resource_group_name = azurerm_resource_group.ea2_rg_az.name
}

resource "azurerm_role_assignment" "ass_role_aksidentity" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = azurerm_role_definition.ea2_aksrole_az.name
  principal_id         = azurerm_user_assigned_identity.ea2_aks_identity.principal_id
}

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
        type = "UserAssigned"
        identity_ids = [azurerm_user_assigned_identity.ea2_aks_identity.id]
    }
    
    depends_on = [azurerm_role_assignment.ass_role_aksidentity]
}
