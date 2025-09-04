# Example: Converting Spark Recipe App to Azure

This example demonstrates how the **Spark to AZD** custom mode converts a GitHub Spark recipe finder application to a production-ready Azure deployment.

## Original Spark Application

The `spark-recipe-app/` folder contains a typical GitHub Spark generated application:

- **Frontend**: React TypeScript app with Vite
- **Features**: AI-powered recipe search (mocked)
- **Styling**: Tailwind CSS
- **Dependencies**: Standard React ecosystem

### Original Structure
```
spark-recipe-app/
├── package.json          # Dependencies and scripts
├── src/
│   └── App.tsx          # Main React component
├── index.html           # Entry point
└── vite.config.ts       # Build configuration
```

## Converted AZD Application

The **Spark to AZD** mode analyzes the application and creates:

### 1. Architecture Analysis

**Identified Components:**
- Single-page React application
- AI feature requiring external API integration
- Static asset serving needs
- Search functionality that could benefit from real AI services

**Recommended Azure Services:**
- **Azure Static Web Apps** - Frontend hosting with global CDN
- **Azure OpenAI** - Real AI-powered recipe recommendations
- **Azure AI Search** - Enhanced recipe search capabilities
- **Azure Cosmos DB** - Recipe database for persistence
- **Azure Key Vault** - Secure API key storage

### 2. Generated Files

The mode creates the complete azd structure:

```
azd-converted/
├── azure.yaml              # AZD configuration
├── package.json            # Updated with deployment scripts
├── infra/                  # Infrastructure as Code
│   ├── main.bicep         # Main template
│   ├── modules/           # Reusable components
│   │   ├── static-web-app.bicep
│   │   ├── openai.bicep
│   │   ├── cosmosdb.bicep
│   │   └── keyvault.bicep
│   └── main.parameters.json
├── .azure/                # Environment configs
│   └── config.json
├── src/                   # Enhanced application code
│   ├── App.tsx           # Updated with real Azure integration
│   ├── services/         # Azure service clients
│   │   ├── openai.ts
│   │   └── search.ts
│   └── types/            # TypeScript definitions
└── .github/workflows/    # CI/CD pipeline
    └── azure-deploy.yml
```

### 3. Key Enhancements

**Infrastructure as Code (Bicep):**
- Provisions all Azure resources automatically
- Implements security best practices
- Configures proper networking and access

**Application Updates:**
- Real Azure OpenAI integration
- Secure authentication with Managed Identity
- Environment-based configuration
- Enhanced error handling and logging

**Deployment Pipeline:**
- Automated CI/CD with GitHub Actions
- Environment promotion (dev → staging → prod)
- Automated testing and validation

### 4. Deployment Commands

After conversion, deploy with simple azd commands:

```bash
# Initialize and provision infrastructure
azd init
azd auth login
azd provision

# Deploy the application
azd deploy

# Or do both in one command
azd up
```

### 5. Cost Optimization

The mode includes cost-conscious recommendations:
- Static Web Apps free tier for small applications
- Serverless OpenAI consumption pricing
- Cosmos DB serverless for variable workloads
- Shared App Service plans for development

### 6. Security Features

All Azure best practices implemented:
- Managed Identity for service authentication
- HTTPS enforcement and security headers
- CORS configuration for SPA
- Key Vault for secrets management
- Network security groups and private endpoints

## Comparison

| Aspect | Original Spark App | Converted AZD App |
|--------|-------------------|-------------------|
| **Deployment** | Manual process | `azd up` |
| **Infrastructure** | Not defined | Infrastructure as Code |
| **AI Integration** | Mocked | Real Azure OpenAI |
| **Scalability** | Limited | Auto-scaling Azure services |
| **Security** | Basic | Enterprise-grade security |
| **Monitoring** | None | Application Insights integrated |
| **Cost** | Unknown | Optimized and predictable |
| **Environments** | Single | Dev/Staging/Prod support |

## Next Steps

After conversion, the application is ready for:

1. **Production deployment** with `azd up`
2. **Team collaboration** with shared infrastructure
3. **CI/CD integration** with automated pipelines
4. **Monitoring and analytics** with Azure Application Insights
5. **Scaling and optimization** based on usage patterns

This example shows how the **Spark to AZD** custom mode transforms a simple prototype into a production-ready, scalable Azure application while maintaining the original functionality and user experience.