param containerAppName string
param location string
param existingContainerAppEnvironmentName string
param storageAccountName string
param dockerImage string

// Reference an existing storage account
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
        { name: 'storageaccountkey', value: storageAccount.listKeys().keys[0].value }
      ]
      environmentVariables: [
        { name: 'ACCEPT_GENERAL_CONDITIONS', value: 'yes' }
        { name: 'EMT_ANM_HOSTS', value: 'anm:8090' }
        { name: 'CASS_HOST', value: 'casshost1' }
        { name: 'EMT_TRACE_LEVEL', value: 'DEBUG' }
      ]
    }

    template: {
      containers: [
        {
          name: containerAppName
          image: dockerImage
          volumeMounts: [
            {
              volumeName: 'myvolume'
              mountPath: '/mnt'
            }
          ]
        }
      ]
    }
  }
}
