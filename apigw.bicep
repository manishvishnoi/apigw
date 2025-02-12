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
resource containerApp 'Microsoft.Web/containerApps@2023-01-01' = {
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
            storageAccountKey: 'storage-account-key'
          }
        }
      ]
    }
    containers: [
      {
        name: containerAppName
        image: dockerImage
        env: [{ name: 'ACCEPT_GENERAL_CONDITIONS', value: 'yes' },{ name: 'EMT_ANM_HOSTS', value: 'anm:8090' },{ name: 'CASS_HOST', value: 'casshost1' },{ name: 'EMT_TRACE_LEVEL', value: 'DEBUG' }
        ]
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
