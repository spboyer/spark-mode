# Azure Architecture Selection Guide

This guide helps you understand which Azure architecture pattern to choose for your GitHub Spark application based on its characteristics and requirements.

## Architecture Decision Tree

```
GitHub Spark Application
         │
         ▼
   Does it have backend APIs
   or server-side processing?
         │
    ┌────┴────┐
    │ NO      │ YES
    ▼         ▼
Static Web    Does it need custom
Application   runtime environment
Stack         or complex processing?
              │
         ┌────┴────┐
         │ NO      │ YES
         ▼         ▼
    Serverless    Container-Based
    API Stack     Stack
         │
         ▼
    Is it primarily
    workflow/automation?
         │
    ┌────┴────┐
    │ NO      │ YES
    ▼         ▼
Serverless    Logic Apps
API Stack     Stack
```

## Detailed Pattern Analysis

### 1. Static Web Application Stack

**Choose this when your Spark app has:**
- ✅ React/TypeScript frontend only
- ✅ Client-side routing (React Router, etc.)
- ✅ External API consumption only
- ✅ No server-side processing requirements
- ✅ Simple AI features using client-side API calls

**Example Apps:**
- Portfolio websites
- Marketing sites
- Documentation sites
- Simple dashboards
- Client-side games

**Azure Services:**
- **Static Web Apps**: Hosts the built React application
- **AI Foundry Project**: Provides AI capabilities via client-side APIs
- **App Configuration**: Manages feature flags and settings
- **Key Vault**: Stores API keys and secrets
- **Application Insights**: Monitors performance and usage

**Deployment Command:**
```bash
azd up --template static-web-app
```

### 2. Container-Based Stack

**Choose this when your Spark app has:**
- ✅ Custom backend/API server
- ✅ Real-time features (WebSockets, SSE)
- ✅ Complex AI/ML processing
- ✅ Database requirements
- ✅ Custom runtime environments
- ✅ Microservices architecture

**Example Apps:**
- Chat applications
- Real-time collaboration tools
- Data processing applications
- Full-stack SaaS products
- AI-powered applications with custom models

**Azure Services:**
- **Container Apps**: Runs both frontend and backend containers
- **Container Registry**: Stores Docker images
- **Cosmos DB/PostgreSQL**: Data persistence
- **AI Foundry Project**: Advanced AI/ML capabilities
- **App Configuration**: Centralized configuration

**Deployment Command:**
```bash
azd up --template container-apps
```

### 3. Serverless API Stack

**Choose this when your Spark app has:**
- ✅ API-driven architecture
- ✅ Event-driven processing
- ✅ Moderate AI/ML workloads
- ✅ Cost optimization priority
- ✅ Variable/unpredictable traffic

**Example Apps:**
- API-first applications
- Event processing systems
- Moderate AI/ML workloads
- Cost-sensitive applications
- Webhook handlers

**Azure Services:**
- **Static Web Apps**: Hosts the frontend
- **Azure Functions**: Serverless API backend
- **Cosmos DB (Serverless)**: Pay-per-request database
- **Service Bus/Event Grid**: Event processing
- **AI Foundry Project**: AI capabilities

**Deployment Command:**
```bash
azd up --template serverless-api
```

### 4. Logic Apps Automation Stack

**Choose this when your Spark app has:**
- ✅ Workflow automation requirements
- ✅ Business process integration
- ✅ External system connections
- ✅ Low-code/no-code approach preference
- ✅ Complex integration scenarios

**Example Apps:**
- Business process automation
- Integration dashboards
- Workflow management systems
- Data synchronization tools
- Approval systems

**Azure Services:**
- **Static Web Apps**: Management dashboard/frontend
- **Logic Apps**: Workflow orchestration
- **Service Bus**: Message queuing
- **AI Foundry Project**: Intelligent automation
- **Integration Connectors**: External system connections

**Deployment Command:**
```bash
azd up --template logic-apps
```

## Usage with Custom Mode

### Basic Pattern Selection
```
@spark-to-azd Convert this Spark application to deploy on Azure with azd
```

### Specific Pattern Request
```
@spark-to-azd Use the Container-Based Stack for this Spark application
```

### Pattern Comparison
```
@spark-to-azd Compare Static Web App Stack vs Serverless API Stack for my recipe finder app
```

### Emergency Deployment
```
@spark-to-azd Break glass - I need this deployed to Azure ASAP using the fastest pattern
```

## Cost Considerations

| Pattern | Cost Profile | Best For |
|---------|-------------|----------|
| **Static Web** | Lowest | Predictable traffic, frontend-only |
| **Container-Based** | Highest | Complex applications, consistent traffic |
| **Serverless API** | Variable | Unpredictable traffic, cost optimization |
| **Logic Apps** | Pay-per-execution | Workflow automation, integrations |

## Performance Characteristics

| Pattern | Cold Start | Scalability | Complexity |
|---------|------------|-------------|------------|
| **Static Web** | None | Global CDN | Low |
| **Container-Based** | Fast | Auto-scale | High |
| **Serverless API** | 1-2 seconds | Instant | Medium |
| **Logic Apps** | Varies | Auto-scale | Low |

## Next Steps

1. **Analyze your Spark app** using the decision tree above
2. **Activate the custom mode** in VS Code Copilot Chat
3. **Request pattern analysis** or specify your preferred pattern
4. **Review generated architecture** and make adjustments
5. **Deploy using azd** with the generated configuration

For more detailed information, see the main [README.md](README.md) file.