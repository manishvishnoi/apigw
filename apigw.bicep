param storageAccountName string = 'mystorageaccount${uniqueString(resourceGroup().id)}'
param fileShareName string = 'myfileshare'
param containerAppName string = 'mycontainerapp'
param existingContainerAppEnvironmentName string = 'managedEnvironment-RGmavishnoi-91ac-21march'
param location string = 'northeurope'
param dockerImage string = 'manishvishnoi/gw22march:latest'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: fileShareName
  parent: fileService
  properties: { enabledProtocols: 'SMB' }
}

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: resourceId('Microsoft.App/managedEnvironments', existingContainerAppEnvironmentName)

    configuration: {
      registries: []
      secrets: [{ name: 'storageaccountkey', value: listKeys(storageAccount.id, '2023-01-01').keys[0].value }]
    }

    template: {
      containers: [
        {
          name: containerAppName
          image: dockerImage
          env: [{ name: 'ACCEPT_GENERAL_CONDITIONS', value: 'yes' }, { name: 'EMT_ANM_HOSTS', value: 'anm:8090' }, { name: 'CASS_HOST', value: 'casshost1' }, { name: 'EMT_TRACE_LEVEL', value: 'DEBUG' }]
          volumeMounts: [{ mountPath: '/mnt/storage', volumeName: fileShareName }]
        }
      ]
      scale: { minReplicas: 1, maxReplicas: 3 }
      storageMounts: [{ name: fileShareName, storageType: 'AzureFile', storageName: storageAccountName, shareName: fileShareName }]
    }
  }
}
