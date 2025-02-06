param storageAccountName string
param fileShareName string
param containerAppName string
param location string = 'northeurope'
param existingContainerAppEnvironmentName string
param dockerImage string

// Create Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// Create File Share
resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  parent: storageAccount
  name: fileShareName
  properties: {
    accessTier: 'TransactionOptimized'
  }
}

// Retrieve Storage Account Key
output storageKey string = listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value

// Deploy Container App
resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: resourceId('Microsoft.App/managedEnvironments', existingContainerAppEnvironmentName)
    configuration: {
      ingress: {
        external: true
        targetPort: 80
      }
      secrets: [
        {
          name: 'storage-key'
          value: storageKey
        }
      ]
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: dockerImage
          env: [
            {
              name: 'AZURE_STORAGE_ACCOUNT'
              value: storageAccountName
            }
            {
              name: 'AZURE_STORAGE_KEY'
              secretRef: 'storage-key'
            }
            {
              name: 'ACCEPT_GENERAL_CONDITIONS'
              value: 'yes'
            }
            {
              name: 'EMT_ANM_HOSTS'
              value: 'anm:8090'
            }
            {
              name: 'CASS_HOST'
              value: 'casshost1'
            }
            {
              name: 'EMT_TRACE_LEVEL'
              value: 'DEBUG'
            }
          ]
          volumeMounts: [
            {
              mountPath: '/mnt/storage'
              volumeName: 'fileshare-volume'
            }
          ]
        }
      ]
      volumes: [
        {
          name: 'fileshare-volume'
          storageType: 'AzureFile'
          storageName: fileShareName
        }
      ]
    }
  }
}
