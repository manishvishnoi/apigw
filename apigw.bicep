param containerAppName string
param location string
param existingContainerAppEnvironmentName string
param storageAccountName string
param dockerImage string

// Reference an existing storage account (ensure it exists)
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// Deploy the Container App
resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: resourceId('Microsoft.App/managedEnvironments', existingContainerAppEnvironmentName)

    configuration: {
      registries: []
      secrets: [
        {
          name: 'storageaccountkey'
          value: listKeys(storageAccount.id, '2023-01-01').keys[0].value
        }
      ]
    }

    template: {
      containers: [
        {
          name: containerAppName
          image: dockerImage
          env: [{ name: 'ACCEPT_GENERAL_CONDITIONS', value: 'yes' },
            { name: 'EMT_ANM_HOSTS', value: 'anm:8090' },
            { name: 'CASS_HOST', value: 'casshost1' },
            { name: 'EMT_TRACE_LEVEL', value: 'DEBUG' }
          ]
        }
      ]
    }
  }
}
