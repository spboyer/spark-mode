// Static Web App module for hosting the React frontend
@description('Name of the Static Web App')
param name string

@description('Location for the Static Web App')
param location string = 'West US 2'

@description('SKU name for the Static Web App')
param skuName string = 'Free'

@description('Environment name')
param environment string

@description('Application Insights connection string')
param applicationInsightsConnectionString string

@description('Tags to apply to resources')
param tags object = {}

// Static Web App resource
resource staticWebApp 'Microsoft.Web/staticSites@2023-01-01' = {
  name: name
  location: location
  tags: union(tags, {
    Environment: environment
    ResourceType: 'StaticWebApp'
  })
  sku: {
    name: skuName
    tier: skuName == 'Free' ? 'Free' : 'Standard'
  }
  properties: {
    buildProperties: {
      appLocation: '/'
      outputLocation: 'dist'
      appBuildCommand: 'npm run build'
    }
    repositoryToken: '' // This will be set during deployment
    // Enterprise-grade configuration for production
    enterpriseGradeCdnStatus: skuName != 'Free' ? 'Enabled' : 'Disabled'
  }
}

// Application settings for the Static Web App
resource staticWebAppSettings 'Microsoft.Web/staticSites/config@2023-01-01' = {
  parent: staticWebApp
  name: 'appsettings'
  properties: {
    // Connection to Application Insights for monitoring
    APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsightsConnectionString
    
    // Environment-specific settings
    NODE_ENV: environment == 'prod' ? 'production' : 'development'
    
    // React app environment variables
    REACT_APP_ENVIRONMENT: environment
    REACT_APP_VERSION: '1.0.0'
    
    // API endpoints (will be populated by other services)
    REACT_APP_API_BASE_URL: ''
    REACT_APP_FUNCTIONS_URL: ''
  }
}

// Custom domain configuration (for production environments)
resource customDomain 'Microsoft.Web/staticSites/customDomains@2023-01-01' = if (environment == 'prod') {
  parent: staticWebApp
  name: 'recipes.yourdomain.com'
  properties: {
    validationMethod: 'cname-delegation'
  }
}

// Outputs
output id string = staticWebApp.id
output name string = staticWebApp.name
output defaultHostname string = staticWebApp.properties.defaultHostname
output customDomainUrl string = environment == 'prod' ? 'https://recipes.yourdomain.com' : 'https://${staticWebApp.properties.defaultHostname}'
output repositoryToken string = staticWebApp.listSecrets().properties.apiKey
