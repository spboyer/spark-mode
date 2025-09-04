// Main infrastructure template for Recipe Finder AI application
targetScope = 'resourceGroup'

// Parameters
@description('Name of the application')
param appName string

@description('Environment name (dev, staging, prod)')
param environment string

@description('Primary Azure region for resources')
param location string = resourceGroup().location

@description('OpenAI service location')
param openAiLocation string = 'eastus'

@description('OpenAI service SKU')
param openAiSkuName string = 'S0'

@description('Cosmos DB account name')
param cosmosDbAccountName string

@description('Cosmos DB database name')
param cosmosDbDatabaseName string = 'recipes'

@description('Static Web App name')
param staticWebAppName string

@description('Static Web App SKU')
param staticWebAppSku string = 'Free'

@description('Unique suffix for resource names')
param resourceSuffix string = uniqueString(resourceGroup().id)

// Variables
var keyVaultName = '${appName}-kv-${resourceSuffix}'
var applicationInsightsName = '${appName}-ai-${environment}'
var logAnalyticsName = '${appName}-logs-${environment}'

// Key Vault for secure secrets management
module keyVault 'modules/keyvault.bicep' = {
  name: 'keyVault'
  params: {
    name: keyVaultName
    location: location
    environment: environment
  }
}

// Application Insights for monitoring and analytics
module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    applicationInsightsName: applicationInsightsName
    logAnalyticsName: logAnalyticsName
    location: location
    environment: environment
  }
}

// Azure OpenAI for AI-powered recipe recommendations
module openAI 'modules/openai.bicep' = {
  name: 'openAI'
  params: {
    name: '${appName}-openai-${resourceSuffix}'
    location: openAiLocation
    skuName: openAiSkuName
    keyVaultName: keyVaultName
    environment: environment
  }
  dependsOn: [
    keyVault
  ]
}

// Cosmos DB for recipe data persistence
module cosmosDb 'modules/cosmosdb.bicep' = {
  name: 'cosmosDb'
  params: {
    accountName: cosmosDbAccountName
    databaseName: cosmosDbDatabaseName
    location: location
    keyVaultName: keyVaultName
    environment: environment
  }
  dependsOn: [
    keyVault
  ]
}

// Static Web App for frontend hosting
module staticWebApp 'modules/static-web-app.bicep' = {
  name: 'staticWebApp'
  params: {
    name: staticWebAppName
    location: location
    skuName: staticWebAppSku
    environment: environment
    applicationInsightsConnectionString: monitoring.outputs.applicationInsightsConnectionString
  }
  dependsOn: [
    monitoring
  ]
}

// Azure Functions for backend API (optional)
module functionApp 'modules/function-app.bicep' = {
  name: 'functionApp'
  params: {
    name: '${appName}-func-${resourceSuffix}'
    location: location
    environment: environment
    applicationInsightsConnectionString: monitoring.outputs.applicationInsightsConnectionString
    keyVaultName: keyVaultName
  }
  dependsOn: [
    monitoring
    keyVault
  ]
}

// Outputs for use in application configuration
output staticWebAppUrl string = staticWebApp.outputs.defaultHostname
output staticWebAppName string = staticWebApp.outputs.name
output openAiEndpoint string = openAI.outputs.endpoint
output cosmosDbEndpoint string = cosmosDb.outputs.endpoint
output keyVaultName string = keyVaultName
output applicationInsightsConnectionString string = monitoring.outputs.applicationInsightsConnectionString
output functionAppUrl string = functionApp.outputs.functionAppUrl
output resourceGroupName string = resourceGroup().name

// Tag all resources for cost management and organization
var commonTags = {
  Application: appName
  Environment: environment
  DeployedBy: 'AzureDeveloperCLI'
  CreatedDate: utcNow('yyyy-MM-dd')
}
