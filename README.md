# GitHub Spark to Azure Dev CLI Custom Mode

This repository contains a custom VS Code Copilot chat mode that specializes in converting GitHub Spark generated applications to Azure Developer CLI (azd) compatible projects.

## Overview

GitHub Spark is an AI-powered platform that helps developers quickly create functional web applications using natural language. However, these applications need to be deployed and scaled for production use with enterprise-grade security. This custom mode bridges that gap by providing expert guidance on converting Spark apps to production-ready Azure deployments using the Azure Developer CLI.

**🚨 ENTERPRISE SECURITY FOCUS 🚨**
This mode is specifically designed for enterprise environments that enforce Azure policies requiring:
- **Managed Identity authentication** for ALL Azure services (no API keys in client code)
- **Azure Functions API layer** for security compliance (client-side code cannot access Azure services directly)
- **Complete Spark dependency removal** with validated builds
- **FC1 Flex Consumption plans** for Azure Functions (enterprise compliance requirement)

## What This Mode Does

The **Spark to AZD** custom mode:

- 📋 **Enforces** enterprise security requirements (managed identity mandatory)
- � **Clones** GitHub repositories automatically for complete codebase analysis
- �🔍 **Analyzes** GitHub Spark template structure (`spark.meta.json`, Vite config, React components)
- 🔧 **Converts** complete frontend code (removes ALL Spark dependencies, replaces `spark.llmPrompt()` and `useKV()` calls)
- ✅ **Validates** build process (`npm run build` MUST pass without errors - conversion incomplete until validated)
- 🛡️ **Implements** Azure Functions API layer (MANDATORY for enterprise policy compliance)
- 🎯 **Selects** optimal Azure architecture from 4 proven patterns:
  - **Static Web Application Stack** (Frontend-only apps with Azure Functions API)
  - **Container-Based Stack** (Full-stack applications)
  - **Serverless API Stack** (API-driven applications)  
  - **Logic Apps Automation Stack** (Workflow automation)
- 🏗️ **Designs** production-ready Azure architecture with managed identity security
- 📁 **Creates** complete azd template files and Bicep infrastructure
- ⚡ **Implements** Azure Functions with Flex Consumption plan (FC1) - NEVER Y1 dynamic
- 🔒 **Ensures** enterprise security with Key Vault and Entra ID
- 🚀 **Provides** complete CI/CD pipeline setup
- 🔍 **Uses** Azure Verified Module templates for infrastructure reliability

## Installation

### Prerequisites

- VS Code with GitHub Copilot Pro+
- Azure Developer CLI installed
- GitHub Spark application (existing or new)

### Setup

1. Clone or download this repository to your local machine
2. Copy the `.github/chatmodes/` folder to your workspace or user profile directory
3. Restart VS Code
4. The mode will appear in your Copilot chat mode dropdown

### Alternative Setup

You can also manually create the chat mode:

1. Open VS Code
2. Open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`)
3. Run "Chat: New Mode File"
4. Choose workspace or user profile location
5. Copy the contents from `spark-to-azd.chatmode.md`

## Usage

### Activating the Mode

1. Open the Chat view in VS Code (`Ctrl+Alt+I` / `Cmd+Alt+I`)
2. Click the mode dropdown at the top of the chat
3. Select "spark-to-azd" from the list

### Common Use Cases

#### Repository Analysis and Conversion

```
I have a Spark app at https://github.com/user/recipe-finder - can you convert it to azd?
```

*The mode will automatically clone the repository and analyze the complete codebase before conversion*

#### Workspace Conversion

```
Convert this Spark application to deploy on Azure with azd
```

#### Architecture Guidance

```
What's the best Azure architecture for my Spark chat app with real-time features?
```

#### Emergency Deployment

```
Break glass - I need this Spark app deployed to Azure ASAP for tomorrow's demo
```

#### Custom Architecture Selection

```
Use the Container-Based Stack for this Spark application with custom backend
```

### Example Workflow

1. **Provide Repository URL**: Share your GitHub Spark application URL
2. **Automatic Cloning**: The mode clones and analyzes your complete codebase
3. **Activate the Mode**: Switch to the "spark-to-azd" chat mode
4. **Complete Code Conversion**: All Spark dependencies removed, frontend code converted to Azure APIs
5. **Build Validation**: Ensures `npm run build` passes without errors
6. **Review Recommendations**: Get Azure service recommendations and architecture design
7. **Generate Infrastructure**: Complete azd files with Azure Functions (FC1) and managed identity
8. **Deploy**: Use `azd up` to deploy to Azure

## Features

## Azure Architecture Patterns

The mode intelligently selects from four proven Azure architecture patterns:

### 🌐 Static Web Application Stack
**Best for**: Frontend-only applications, portfolios, marketing sites
**Security**: Managed identity for all Azure service connections (no API keys in client code)

```
Spark App (React/TypeScript) → Azure Static Web Apps
                             ↓
                    Azure Functions (FC1) ← Managed Identity
                             ↓                    ↓
                    Azure OpenAI + Cosmos DB → Key Vault
```

**Services**: Static Web Apps, Azure Functions (Flex Consumption FC1), Azure OpenAI, Cosmos DB, Key Vault

**🚨 MANDATORY ENTERPRISE REQUIREMENTS 🚨**:
- **Azure Functions API layer REQUIRED** for `spark.llmPrompt()` and `useKV()` conversions (enterprise policy)
- **Complete Spark dependency removal** including problematic packages like `@phosphor-icons/react`
- **Build validation MANDATORY**: `npm run build` must pass without errors
- **FC1 Flex Consumption plan**: NEVER use Y1 dynamic plan (deployment failures)
- **functionAppConfig required**: Must include deployment.storage configuration for FC1
- **Azure Verified Module templates**: Infrastructure must follow reference samples
- **Managed identity for ALL services**: Cosmos DB, Azure OpenAI, Storage with `disableLocalAuth: true`

### 🐳 Container-Based Stack
**Best for**: Full-stack applications, microservices, custom backends

```
Spark Frontend → Container Apps (Frontend)
      ↓                    ↓
Spark Backend → Container Apps (API) → Database (Cosmos DB/PostgreSQL)
      ↓                    ↓                    ↓
Container Registry → AI Foundry Project → App Configuration
```

**Services**: Container Apps, Container Registry, Cosmos DB/PostgreSQL, AI Foundry Project

### ⚡ Serverless API Stack
**Best for**: API-heavy applications, event-driven architecture

```
Spark Frontend → Static Web Apps
      ↓                ↓
API Endpoints → Azure Functions → Cosmos DB (Serverless)
      ↓                ↓              ↓
AI Features → AI Foundry Project → Service Bus/Event Grid
```

**Services**: Static Web Apps, Azure Functions, Cosmos DB, Service Bus, AI Foundry Project

### 🔄 Logic Apps Automation Stack
**Best for**: Workflow automation, business process integration

```
Spark Dashboard → Static Web Apps
      ↓                ↓
Workflows → Logic Apps → External Connectors
      ↓          ↓            ↓
AI Processing → AI Foundry → Service Bus
```

**Services**: Static Web Apps, Logic Apps, Service Bus, AI Foundry Project, Integration Connectors

### Azure Functions Configuration

**🚨 CRITICAL: FC1 Flex Consumption Plan Requirements 🚨**:
- ✅ **Always FC1**: Uses Flex Consumption plan, NEVER Y1 dynamic (causes deployment failures)
- ✅ **functionAppConfig MANDATORY**: Must include deployment.storage configuration for FC1
- ✅ **Managed Identity**: Secure authentication to Azure services
- ✅ **Reference Templates REQUIRED**: Must follow Azure Verified Module samples
  - JavaScript: https://github.com/Azure-Samples/functions-quickstart-javascript-azd/tree/main/infra
  - .NET: https://github.com/Azure-Samples/functions-quickstart-dotnet-azd-eventgrid-blob/tree/main/infra

**Why Azure Functions API Layer is MANDATORY for Spark Conversions**:
- **Enterprise Policy Enforcement**: `disableLocalAuth: true` on Cosmos DB and Azure OpenAI
- **Security Compliance**: Client-side code CANNOT contain API keys or connection strings
- **Managed Identity**: Enterprise-grade authentication to Azure OpenAI and Cosmos DB
- **API Layer**: Secure backend for `spark.llmPrompt()` and `useKV()` replacements
- **Storage Account Policy**: `allowSharedKeyAccess: false` requires managed identity

**Common FC1 Infrastructure Pattern** (from Azure samples):
```bicep
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  properties: {
    serverFarmId: flexConsumptionPlan.id
    functionAppConfig: {                    // CRITICAL for FC1
      deployment: {
        storage: {
          type: 'blobContainer'
          authentication: {
            type: 'SystemAssignedIdentity'  // REQUIRED
          }
        }
      }
    }
  }
}
```

### Generated Files

The mode creates all necessary files for azd deployment:

```
your-app/
├── azure.yaml              # Main azd configuration
├── infra/                  # Infrastructure as Code
│   ├── main.bicep         # Main infrastructure template
│   ├── resources/         # Individual resource templates
│   └── modules/           # Reusable Bicep modules
├── .azure/                # Azure environment configs
├── .github/workflows/     # CI/CD pipelines (optional)
└── .env.example          # Environment variables template
```

### Best Practices Implemented

- ✅ **Repository Analysis**: Automatic cloning and complete codebase analysis
- ✅ **Complete Code Conversion**: All Spark dependencies removed, frontend fully converted
- ✅ **Build Validation**: `npm run build` must pass before deployment
- ✅ **Azure Functions FC1**: Flex Consumption plan with proper functionAppConfig
- ✅ **Managed Identity**: No API keys or connection strings in client code
- ✅ **Infrastructure as Code**: Bicep templates with main.parameters.json
- ✅ **Environment separation**: dev/staging/prod configurations
- ✅ **Security headers**: HTTPS enforcement and proper authentication
- ✅ **Cost optimization**: Right-sized resources and consumption-based pricing
- ✅ **Monitoring**: Application Insights with comprehensive telemetry
- ✅ **Resource naming**: Proper Azure naming conventions

## Conversion Validation Checklist

**🚨 CONVERSION IS ONLY COMPLETE WHEN ALL ITEMS ARE VERIFIED 🚨**

### ✅ Pre-Conversion Analysis
- [ ] Repository successfully cloned and analyzed (if GitHub URL provided)
- [ ] Complete codebase structure documented
- [ ] All Spark dependencies identified (`@github/spark`, `@github/github-spark`)
- [ ] All `spark.llmPrompt()` usage patterns documented
- [ ] All `useKV()` usage patterns and data types documented
- [ ] Problematic dependencies identified (`@phosphor-icons/react`)

### ✅ Code Transformation
- [ ] ALL `spark.llmPrompt()` calls replaced with Functions API calls
- [ ] ALL `useKV()` calls replaced with Azure data API calls  
- [ ] ALL Spark dependencies removed from package.json
- [ ] ALL Spark configuration files deleted (`spark.config.js`, `spark.meta.json`)
- [ ] ALL problematic icon imports resolved
- [ ] useKV wrapper handles React functional state updates correctly
- [ ] Comprehensive defensive coding for undefined/null values

### ✅ Build Validation
- [ ] `npm install` completes successfully
- [ ] `npm run build` passes WITHOUT ERRORS
- [ ] `npx tsc --noEmit` passes WITHOUT ERRORS
- [ ] No TypeScript compilation errors
- [ ] No missing dependency issues
- [ ] `npm run preview` works locally

### ✅ Azure Infrastructure
- [ ] Azure Functions uses Flex Consumption plan (FC1) - NEVER Y1
- [ ] functionAppConfig with deployment.storage configuration included
- [ ] Infrastructure follows Azure Verified Module reference templates
- [ ] Managed identity configured for ALL Azure services
- [ ] RBAC role assignments configured
- [ ] All Azure services have `disableLocalAuth: true`
- [ ] main.parameters.json exists and matches main.bicep parameters
- [ ] `azd provision --preview` passes validation

### ✅ Security Compliance
- [ ] NO API keys or connection strings in client-side code
- [ ] Azure Functions API layer implemented for all Azure service access
- [ ] Managed identity authentication implemented
- [ ] Key Vault configured for any necessary secrets
- [ ] HTTPS enforcement configured
- [ ] Proper CORS settings implemented

### ✅ Deployment Validation
- [ ] Static Web Apps and Functions deployed separately (not linked)
- [ ] Environment variable injection configured in azd hooks
- [ ] Azure OpenAI model versions verified as current
- [ ] All API endpoints tested with correct payload formats
- [ ] Managed identity authentication verified working
- [ ] Complete user workflows tested end-to-end
- [ ] No infinite request loops or runtime errors
- [ ] Data persistence works across user sessions
- [ ] Clearing/deleting data works without errors

## Examples

### Frontend-Only React App

**Input**: A GitHub Spark React app with client-side AI features

**Output**: 
- Azure Static Web Apps configuration
- Azure OpenAI integration
- Custom domain setup
- Global CDN configuration

### Full-Stack Application

**Input**: A Spark app with both frontend and custom API endpoints

**Output**:
- Container Apps for frontend and backend
- Azure Database for data persistence
- Key Vault for secrets management
- Application Gateway for routing

### AI-Powered Application

**Input**: A Spark app using AI for content generation or analysis

**Output**:
- Integration with Azure OpenAI or AI Services
- Proper API key management
- Rate limiting and cost controls
- Vector database for AI context

## Azure Services by Architecture Pattern

| Architecture Pattern | Primary Services | Use Cases |
|---------------------|------------------|----------|
| **Static Web Application** | Static Web Apps, AI Foundry, Key Vault | Frontend-only, portfolios, marketing sites |
| **Container-Based** | Container Apps, Container Registry, Database | Full-stack apps, microservices, custom backends |
| **Serverless API** | Static Web Apps, Functions, Cosmos DB | API-driven apps, event processing |
| **Logic Apps Automation** | Logic Apps, Service Bus, Connectors | Workflow automation, integrations |

### Common Supporting Services

- **AI Foundry Project**: AI/ML capabilities across all patterns
- **App Configuration**: Centralized configuration management
- **Key Vault**: Secrets and certificate management
- **Application Insights**: Monitoring and observability
- **Log Analytics Workspace**: Centralized logging
- **Storage Account**: File storage and static assets

## Troubleshooting

### Critical Production Issues (from Enterprise Deployments)

#### 1. **Azure Policy Violations: Local Authentication Not Allowed**
**Error**: `RequestDisallowedByPolicy: Local authentication methods are not allowed`
**Cause**: Enterprise environments enforce managed identity-only policies
**Solution**: 
- Add `disableLocalAuth: true` to Cosmos DB
- Add `disableLocalAuth: true` to Azure OpenAI
- Add `allowSharedKeyAccess: false` to Storage Account
- Configure RBAC role assignments for Function App managed identity
- Remove ALL API keys from app settings

#### 2. **Azure Functions Y1 Plan Deployment Failures**
**Error**: Azure Functions deployment fails with Y1 dynamic plan
**Cause**: Enterprise environments require FC1 Flex Consumption plan
**Solution**:
- ALWAYS use FC1 Flex Consumption plan, NEVER Y1
- Include `functionAppConfig` with `deployment.storage` configuration
- Follow Azure Verified Module reference templates exactly
- Verify Bicep template matches proven samples

#### 3. **Build Validation Failures**
**Error**: `npm run build` fails after Spark conversion
**Cause**: Incomplete Spark dependency removal or missing packages
**Solution**:
- Remove ALL Spark packages: `@github/spark`, `@github/github-spark`
- Remove problematic dependencies: `@phosphor-icons/react` (if only used for Sparkles icon)
- Clean up ALL Spark imports and configuration files
- Run `npx tsc --noEmit` to validate TypeScript compilation
- Ensure all replaced API calls are properly implemented

#### 4. **Missing main.parameters.json**
**Error**: `InvalidTemplateDeployment: missing parameters`
**Cause**: Common azd requirement that's often missed
**Solution**:
- Generate main.parameters.json that matches main.bicep parameters
- Verify all parameter types and default values
- Use azd samples as reference for parameter structure

#### 5. **Outdated Azure OpenAI Model Versions**
**Error**: `Model version '0613' for model 'gpt-4' is not supported or has been deprecated`
**Cause**: Using deprecated model versions in Bicep templates
**Solution**:
- Research current model versions using documentation tools
- Update to latest supported models (e.g., gpt-4o, gpt-4o-mini)
- Check regional availability for selected models
- Verify model capabilities meet application requirements

#### 6. **Infinite Request Loops in Frontend**
**Error**: useAzureData hook causing infinite re-renders
**Cause**: Improper React dependency arrays or state management
**Solution**:
- Add `hasTriedApi` state to prevent multiple calls
- Implement proper useEffect dependency arrays
- Handle React functional state updates correctly in useKV wrapper

#### 7. **Runtime Errors from Undefined Values**
**Error**: `.toLowerCase()` on undefined after clearing data
**Cause**: Missing defensive coding for data operations
**Solution**:
- Add comprehensive null/undefined checks
- Implement defensive filtering patterns
- Handle edge cases in data operations

### Common Issues

1. **Mode Not Appearing**: Ensure the `.chatmode.md` file is in the correct location
2. **Tools Not Working**: Verify VS Code has the latest Copilot extension
3. **Repository Cloning Fails**: Check GitHub access permissions and repository URL
4. **Managed Identity Token Issues**: Implement proper token caching with expiry validation
5. **API Payload Format Mismatches**: Ensure frontend-backend payload format consistency
6. **Azure Commands Failing**: Check Azure CLI and azd installation

### Support

For issues related to:
- **Custom Mode**: Check VS Code Copilot documentation
- **Azure deployment**: Refer to Azure Developer CLI docs
- **GitHub Spark**: Contact GitHub Spark support

## Contributing

To improve this custom mode:

1. Fork this repository
2. Make your changes to the `.chatmode.md` file
3. Test with various Spark applications
4. Submit a pull request

### Enhancement Ideas

- Support for additional Azure services
- More sophisticated cost optimization
- Integration with Azure DevOps
- Support for multi-region deployments
- Advanced monitoring and alerting setup

## Enterprise Deployment Notes

### Azure Policy Compliance
This mode is specifically designed for enterprise Azure environments that enforce:
- **Safe Secrets Standard**: No local authentication methods allowed
- **Managed Identity Requirements**: All service-to-service authentication via managed identity
- **Resource Naming Standards**: Consistent naming conventions across environments
- **Security Compliance**: HTTPS enforcement, proper RBAC, Key Vault integration

### Infrastructure Templates
The mode uses proven Azure Verified Module templates:
- **JavaScript Functions**: Azure-Samples/functions-quickstart-javascript-azd
- **.NET Functions**: Azure-Samples/functions-quickstart-dotnet-azd-eventgrid-blob
- **Container Apps**: Official Microsoft azd templates
- **Static Web Apps**: Enterprise-compliant configurations

### Cost Optimization
- **Serverless First**: Uses consumption-based pricing where possible
- **Right-Sizing**: Recommendations for appropriate resource SKUs
- **Auto-Scaling**: Configures scaling rules based on application patterns
- **Monitoring**: Application Insights for cost and performance tracking

## Related Resources

### Core Documentation
- [VS Code Custom Chat Modes Documentation](https://code.visualstudio.com/docs/copilot/customization/custom-chat-modes)
- [Azure Developer CLI Documentation](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)
- [GitHub Spark Documentation](https://github.com/features/spark)

### Azure Services
- [Azure Static Web Apps](https://docs.microsoft.com/en-us/azure/static-web-apps/)
- [Azure Functions Flex Consumption](https://docs.microsoft.com/en-us/azure/azure-functions/flex-consumption-plan)
- [Azure Container Apps](https://docs.microsoft.com/en-us/azure/container-apps/)
- [Azure OpenAI Service](https://docs.microsoft.com/en-us/azure/cognitive-services/openai/)
- [Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/)

### Security & Compliance
- [Azure Managed Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/)
- [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/)
- [Azure Safe Secrets Standard](https://aka.ms/safesecretsstandard)
- [Azure RBAC Documentation](https://docs.microsoft.com/en-us/azure/role-based-access-control/)

### Infrastructure Templates
- [Azure Functions JavaScript azd Template](https://github.com/Azure-Samples/functions-quickstart-javascript-azd)
- [Azure Functions .NET azd Template](https://github.com/Azure-Samples/functions-quickstart-dotnet-azd-eventgrid-blob)
- [Azure Verified Modules](https://aka.ms/avm)
- [Azure Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Ready to convert your GitHub Spark app to Azure?** Activate the mode and start your cloud journey! 🚀