resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: resourceId('Microsoft.App/managedEnvironments', existingContainerAppEnvironmentName)

    configuration: {
      registries: []
      secrets: [
        { name: 'storageaccountkey', value: listKeys(storageAccount.id, '2023-01-01').keys[0].value }
      ]
    }

    storageMounts: [ // Ensure storageMounts is placed correctly
      {
        name: fileShareName
        storageType: 'AzureFile'
        storageName: storageAccountName
        shareName: fileShareName
      }
    ]

    template: {
      containers: [
        {
          name: containerAppName
          image: dockerImage
          env: [ // Environment variables must be inside containers[]
            { name: 'ACCEPT_GENERAL_CONDITIONS', value: 'yes' },
            { name: 'EMT_ANM_HOSTS', value: 'anm:8090' },
            { name: 'CASS_HOST', value: 'casshost1' },
            { name: 'EMT_TRACE_LEVEL', value: 'DEBUG' }
          ]
        }
      ]
    }
  }
}
