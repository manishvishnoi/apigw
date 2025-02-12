param containerAppName string
param location string
param existingContainerAppEnvironmentName string
param storageAccountName string
param dockerImage string
param fileShareName string
param storageAccountKey string


// Reference an existing storage account (ensure it exists)
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// Deploy the Container App
resource containerApp 'Microsoft.Web/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
  properties: {
    environmentId: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Web/managedEnvironments/{environmentName}'
    configuration: {
      secrets: [
        {
          name: 'storage-account-key'
          value: '$(storageAccountKey)'  // Use the key passed in parameters
        }
      ]
      volumes: [
        {
          name: 'myfileshare'
          azureFile: {
            shareName: fileShareName
            storageAccountName: storageAccountName
            storageAccountKey: secret('storage-account-key')
          }
        }
      ]
    }
    containers: [
      {
        name: containerAppName
        image: dockerImage
        volumeMounts: [
          {
            name: 'myfileshare'
            mountPath: '/opt/Axway/apigateway/conf/licenses'
          }
        ]
      }
    ]
  }
}
