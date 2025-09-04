# Enhanced Spark Template Example

This example demonstrates how the enhanced custom mode analyzes a real GitHub Spark application and selects the appropriate Azure architecture pattern.

## Example Spark Application: Recipe Finder with AI

Based on the actual GitHub Spark template structure, here's how the enhanced mode would analyze and convert a recipe finder application.

### Input: Spark Application Structure

```
recipe-finder/
├── .devcontainer/
│   └── devcontainer.json
├── src/
│   ├── components/
│   │   ├── ui/                    # shadcn/ui components
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   ├── input.tsx
│   │   │   └── ...
│   │   ├── recipe-card.tsx
│   │   ├── recipe-search.tsx
│   │   └── ai-suggestions.tsx
│   ├── lib/
│   │   └── utils.ts
│   ├── App.tsx
│   ├── main.tsx
│   └── index.css
├── components.json               # shadcn/ui config
├── spark.meta.json              # Spark metadata
├── package.json                 # Dependencies
├── vite.config.ts              # Vite configuration
├── tailwind.config.js          # Tailwind CSS config
└── tsconfig.json               # TypeScript config
```

### Mode Analysis Process

#### 1. Spark Template Detection
```
✅ Found spark.meta.json - confirmed Spark application
✅ Found components.json - shadcn/ui components detected
✅ Found vite.config.ts - Vite build system confirmed
✅ Package.json analysis:
   - React 18+ detected
   - TypeScript detected
   - Tailwind CSS detected
   - No backend dependencies found
```

#### 2. Feature Analysis
```
✅ Frontend Components:
   - Recipe search interface
   - AI-powered recipe suggestions
   - Modern UI with shadcn/ui components
   
✅ AI Integration:
   - Client-side API calls to external AI service
   - No server-side AI processing
   
✅ Data Flow:
   - No database requirements
   - External recipe API consumption
   - Client-side state management
```

#### 3. Architecture Pattern Selection

**Recommended Pattern: Static Web Application Stack**

**Reasoning:**
- ✅ Frontend-only React application
- ✅ Client-side AI API integration
- ✅ No backend processing requirements
- ✅ External API consumption only
- ✅ Optimal for cost and performance

### Generated Azure Configuration

#### azure.yaml
```yaml
name: recipe-finder
metadata:
  template: spark-to-azd-static-web-app
  
services:
  web:
    project: .
    language: js
    host: staticwebapp
    hooks:
      prebuild:
        shell: npm ci
        continueOnError: false
      build:
        shell: npm run build
        continueOnError: false

hooks:
  postprovision:
    shell: |
      echo "Setting up Static Web App configuration..."
      az staticwebapp appsettings set \
        --name $AZURE_STATIC_WEB_APP_NAME \
        --setting-names VITE_AI_API_URL=$AI_API_URL \
        --resource-group $AZURE_RESOURCE_GROUP_NAME
```

#### infra/main.bicep
```bicep
targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${environmentName}'
  location: location
}

// Deploy Static Web App stack
module staticWebApp 'modules/static-web-app.bicep' = {
  name: 'static-web-app'
  scope: rg
  params: {
    name: 'swa-${environmentName}'
    location: location
    aiFoundryProjectId: aiFoundry.outputs.projectId
  }
}

// Deploy AI Foundry Project
module aiFoundry 'modules/ai-foundry.bicep' = {
  name: 'ai-foundry'
  scope: rg
  params: {
    name: 'aif-${environmentName}'
    location: location
  }
}

// Deploy App Configuration
module appConfig 'modules/app-configuration.bicep' = {
  name: 'app-configuration'
  scope: rg
  params: {
    name: 'appconfig-${environmentName}'
    location: location
  }
}

// Deploy Key Vault
module keyVault 'modules/key-vault.bicep' = {
  name: 'key-vault'
  scope: rg
  params: {
    name: 'kv-${environmentName}'
    location: location
  }
}

outputs {
  AZURE_STATIC_WEB_APP_NAME: staticWebApp.outputs.name
  AZURE_STATIC_WEB_APP_URL: staticWebApp.outputs.url
  AI_FOUNDRY_ENDPOINT: aiFoundry.outputs.endpoint
  APP_CONFIG_ENDPOINT: appConfig.outputs.endpoint
}
```

#### infra/modules/static-web-app.bicep
```bicep
@description('The name of the Static Web App')
param name string

@description('The location for the Static Web App')
param location string

@description('AI Foundry Project ID for integration')
param aiFoundryProjectId string

resource staticWebApp 'Microsoft.Web/staticSites@2023-01-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    buildProperties: {
      skipGithubActionWorkflowGeneration: true
    }
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    enterpriseGradeCdnStatus: 'Enabled'
  }
  
  // App Settings for AI integration
  resource appSettings 'config@2023-01-01' = {
    name: 'appsettings'
    properties: {
      VITE_AI_FOUNDRY_PROJECT_ID: aiFoundryProjectId
      VITE_ENVIRONMENT: 'production'
    }
  }
}

output name string = staticWebApp.name
output url string = 'https://${staticWebApp.properties.defaultHostname}'
output id string = staticWebApp.id
```

### Deployment Process

#### 1. Initial Setup
```bash
# Install Azure Developer CLI
curl -fsSL https://aka.ms/install-azd.sh | bash

# Login to Azure
azd auth login

# Initialize the project
azd init --template static-web-app
```

#### 2. Environment Configuration
```bash
# Set environment variables
azd env set AZURE_LOCATION "East US 2"
azd env set AZURE_SUBSCRIPTION_ID "your-subscription-id"

# Configure AI API settings
azd env set AI_API_URL "https://api.openai.com/v1"
azd env set AI_API_KEY "your-api-key"
```

#### 3. Deploy to Azure
```bash
# Deploy infrastructure and application
azd up

# Output:
# ✅ Resource group created
# ✅ Static Web App provisioned  
# ✅ AI Foundry Project configured
# ✅ App Configuration deployed
# ✅ Key Vault created
# ✅ Application deployed and accessible at: https://recipe-finder-xyz.azurestaticapps.net
```

### Post-Deployment Features

#### Custom Domain Setup
```bash
# Add custom domain
az staticwebapp hostname set \
  --name $AZURE_STATIC_WEB_APP_NAME \
  --hostname recipes.yourdomain.com \
  --resource-group $AZURE_RESOURCE_GROUP_NAME
```

#### Environment Management
```bash
# Create staging environment
azd env new staging
azd deploy --environment staging

# Create production environment  
azd env new production
azd deploy --environment production
```

#### Monitoring Setup
```bash
# Enable Application Insights
az monitor app-insights component create \
  --app recipe-finder-insights \
  --location $AZURE_LOCATION \
  --resource-group $AZURE_RESOURCE_GROUP_NAME
```

### Cost Analysis

**Monthly Cost Estimate (Static Web Application Stack):**
- Static Web Apps (Standard): ~$9/month
- AI Foundry Project: Pay-per-use (varies)
- App Configuration: ~$1/month  
- Key Vault: ~$0.50/month
- Application Insights: ~$2/month

**Total: ~$12.50/month + AI usage**

### Performance Characteristics

- **Global CDN**: Sub-100ms response times worldwide
- **Auto-scaling**: Handles traffic spikes automatically
- **99.95% SLA**: Enterprise-grade availability
- **Cold Start**: None (static content)

## Alternative Pattern: Container-Based Stack

If the recipe finder had backend requirements (user accounts, recipe storage, etc.), the mode would recommend:

**Container-Based Stack with:**
- Container Apps for frontend and API
- Cosmos DB for recipe storage
- Container Registry for images
- Enhanced AI processing capabilities

**Generated command:**
```bash
azd up --template container-apps-full-stack
```

This demonstrates how the enhanced custom mode provides intelligent architecture selection based on actual application analysis rather than generic recommendations.