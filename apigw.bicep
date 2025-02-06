// Parameters
param location string = resourceGroup().location
param storageAccountName string
param fileShareName string
param containerAppName string
param existingContainerAppEnvironmentName string
param dockerImage string
param containerPort int = 80

// Variables
var fileShareMountPath = '/opt/Axway/apigateway/conf/licenses'

// Create Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

// Create File Share
resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: '${storageAccount.name}/default/${fileShareName}'
  properties: {
    accessTier: 'TransactionOptimized'
  }
}

// Reference the existing Container App Environment
resource existingContainerAppEnvironment 'Microsoft.App/managedEnvironments@2023-01-01' existing = {
  name: existingContainerAppEnvironmentName
}

// Create Container App
resource containerApp 'Microsoft.App/containerApps@2023-01-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: existingContainerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: containerPort
      }
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: dockerImage
          volumeMounts: [
            {
              volumeName: 'fileshare-volume'
              mountPath: fileShareMountPath
            }
          ]
        }
      ]
      volumes: [
        {
          name: 'fileshare-volume'
          storageType: 'AzureFile'
          storageName: fileShareName
          azureFile: {
            accountName: storageAccountName
            shareName: fileShareName
            accessMode: 'ReadWrite'
          }
        }
      ]
    }
  }
}
