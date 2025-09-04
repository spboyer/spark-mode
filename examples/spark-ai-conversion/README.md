# Spark AI to Azure OpenAI Conversion Example

This example demonstrates how to convert a GitHub Spark application that uses built-in AI capabilities to Azure OpenAI when migrating to Azure.

## Original Spark Application with AI

### Spark Recipe Assistant App Structure

```
recipe-ai-assistant/
├── src/
│   ├── components/
│   │   ├── RecipeGenerator.tsx    # Uses spark.llmPrompt()
│   │   ├── RecipeAnalyzer.tsx     # Uses spark.analyzeContent()
│   │   ├── ChatInterface.tsx      # Uses spark.chat()
│   │   └── RecipeSearch.tsx       # Uses spark.embedding()
│   ├── hooks/
│   │   ├── useSparkAI.ts         # Spark AI integration
│   │   └── useRecipeChat.ts      # Conversation management
│   ├── utils/
│   │   └── sparkHelpers.ts       # Spark utility functions
│   └── App.tsx
├── spark.meta.json               # Spark metadata
├── package.json                 # @github/spark dependency
└── vite.config.ts
```

### Original Spark AI Implementation

#### 1. Recipe Generator Component (Spark)
```typescript
// src/components/RecipeGenerator.tsx (Original Spark)
import { spark } from '@github/spark';
import { useState } from 'react';

export function RecipeGenerator() {
  const [ingredients, setIngredients] = useState('');
  const [recipe, setRecipe] = useState('');
  const [loading, setLoading] = useState(false);

  const generateRecipe = async () => {
    setLoading(true);
    try {
      const response = await spark.llmPrompt({
        prompt: `Create a delicious recipe using these ingredients: ${ingredients}. 
                Include cooking time, difficulty level, and step-by-step instructions.`,
        model: 'gpt-4',
        temperature: 0.7,
        maxTokens: 500
      });
      
      setRecipe(response.text);
    } catch (error) {
      console.error('Recipe generation failed:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-4">
      <textarea
        value={ingredients}
        onChange={(e) => setIngredients(e.target.value)}
        placeholder="Enter your ingredients..."
        className="w-full p-3 border rounded-lg"
      />
      <button 
        onClick={generateRecipe} 
        disabled={loading}
        className="bg-blue-500 text-white px-4 py-2 rounded-lg"
      >
        {loading ? 'Generating...' : 'Generate Recipe'}
      </button>
      {recipe && (
        <div className="bg-gray-50 p-4 rounded-lg">
          <pre className="whitespace-pre-wrap">{recipe}</pre>
        </div>
      )}
    </div>
  );
}
```

#### 2. Chat Interface Component (Spark)
```typescript
// src/components/ChatInterface.tsx (Original Spark)
import { spark } from '@github/spark';
import { useState } from 'react';

interface Message {
  role: 'user' | 'assistant';
  content: string;
  timestamp: Date;
}

export function ChatInterface() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);

  const sendMessage = async () => {
    if (!input.trim()) return;

    const userMessage: Message = {
      role: 'user',
      content: input,
      timestamp: new Date()
    };

    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setLoading(true);

    try {
      const response = await spark.chat({
        message: input,
        context: messages,
        personality: 'helpful cooking assistant with expertise in international cuisine'
      });

      const assistantMessage: Message = {
        role: 'assistant',
        content: response.text,
        timestamp: new Date()
      };

      setMessages(prev => [...prev, assistantMessage]);
    } catch (error) {
      console.error('Chat failed:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col h-96 border rounded-lg">
      <div className="flex-1 overflow-y-auto p-4 space-y-3">
        {messages.map((message, index) => (
          <div key={index} className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}>
            <div className={`max-w-xs lg:max-w-md px-3 py-2 rounded-lg ${
              message.role === 'user' 
                ? 'bg-blue-500 text-white' 
                : 'bg-gray-200 text-gray-800'
            }`}>
              {message.content}
            </div>
          </div>
        ))}
      </div>
      <div className="border-t p-4 flex space-x-2">
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
          placeholder="Ask about recipes..."
          className="flex-1 border rounded-lg px-3 py-2"
        />
        <button
          onClick={sendMessage}
          disabled={loading}
          className="bg-blue-500 text-white px-4 py-2 rounded-lg"
        >
          Send
        </button>
      </div>
    </div>
  );
}
```

#### 3. Recipe Search with Embeddings (Spark)
```typescript
// src/components/RecipeSearch.tsx (Original Spark)
import { spark } from '@github/spark';
import { useState, useEffect } from 'react';

interface Recipe {
  id: string;
  title: string;
  description: string;
  embedding?: number[];
  similarity?: number;
}

export function RecipeSearch() {
  const [query, setQuery] = useState('');
  const [recipes, setRecipes] = useState<Recipe[]>([]);
  const [searchResults, setSearchResults] = useState<Recipe[]>([]);
  const [loading, setLoading] = useState(false);

  const searchRecipes = async () => {
    if (!query.trim()) return;
    
    setLoading(true);
    try {
      // Get embedding for search query
      const queryEmbedding = await spark.embedding({
        text: query,
        model: 'text-embedding-ada-002'
      });

      // Simulate vector search (in real app, this would be in a database)
      const results = recipes.map(recipe => ({
        ...recipe,
        similarity: cosineSimilarity(queryEmbedding.embedding, recipe.embedding || [])
      }))
      .sort((a, b) => (b.similarity || 0) - (a.similarity || 0))
      .slice(0, 5);

      setSearchResults(results);
    } catch (error) {
      console.error('Search failed:', error);
    } finally {
      setLoading(false);
    }
  };

  const cosineSimilarity = (a: number[], b: number[]): number => {
    const dotProduct = a.reduce((sum, val, i) => sum + val * b[i], 0);
    const magnitudeA = Math.sqrt(a.reduce((sum, val) => sum + val * val, 0));
    const magnitudeB = Math.sqrt(b.reduce((sum, val) => sum + val * val, 0));
    return dotProduct / (magnitudeA * magnitudeB);
  };

  return (
    <div className="space-y-4">
      <div className="flex space-x-2">
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search recipes..."
          className="flex-1 border rounded-lg px-3 py-2"
        />
        <button
          onClick={searchRecipes}
          disabled={loading}
          className="bg-green-500 text-white px-4 py-2 rounded-lg"
        >
          Search
        </button>
      </div>
      
      {searchResults.length > 0 && (
        <div className="space-y-2">
          {searchResults.map(recipe => (
            <div key={recipe.id} className="p-3 border rounded-lg">
              <h3 className="font-semibold">{recipe.title}</h3>
              <p className="text-gray-600">{recipe.description}</p>
              <span className="text-sm text-blue-500">
                Similarity: {((recipe.similarity || 0) * 100).toFixed(1)}%
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
```

## Converted Azure OpenAI Implementation

### Updated Package Dependencies
```json
{
  "dependencies": {
    "react": "^18.2.0",
    "typescript": "^5.0.0",
    "openai": "^4.20.0",
    "@azure/openai": "^1.0.0-beta.7"
  }
}
```

### Azure OpenAI Configuration
```typescript
// src/lib/azure-openai.ts
import { OpenAI } from 'openai';

export const openai = new OpenAI({
  apiKey: import.meta.env.VITE_AZURE_OPENAI_API_KEY,
  baseURL: `${import.meta.env.VITE_AZURE_OPENAI_ENDPOINT}/openai/deployments/${import.meta.env.VITE_AZURE_OPENAI_DEPLOYMENT}`,
  defaultQuery: { 'api-version': '2024-08-01-preview' },
  defaultHeaders: {
    'api-key': import.meta.env.VITE_AZURE_OPENAI_API_KEY,
  },
});

export const embeddingClient = new OpenAI({
  apiKey: import.meta.env.VITE_AZURE_OPENAI_API_KEY,
  baseURL: `${import.meta.env.VITE_AZURE_OPENAI_ENDPOINT}/openai/deployments/${import.meta.env.VITE_AZURE_OPENAI_EMBEDDING_DEPLOYMENT}`,
  defaultQuery: { 'api-version': '2024-08-01-preview' },
  defaultHeaders: {
    'api-key': import.meta.env.VITE_AZURE_OPENAI_API_KEY,
  },
});
```

### Converted Components

#### 1. Recipe Generator Component (Azure OpenAI)
```typescript
// src/components/RecipeGenerator.tsx (Converted to Azure OpenAI)
import { openai } from '../lib/azure-openai';
import { useState } from 'react';

export function RecipeGenerator() {
  const [ingredients, setIngredients] = useState('');
  const [recipe, setRecipe] = useState('');
  const [loading, setLoading] = useState(false);

  const generateRecipe = async () => {
    setLoading(true);
    try {
      const response = await openai.chat.completions.create({
        model: import.meta.env.VITE_AZURE_OPENAI_DEPLOYMENT,
        messages: [
          {
            role: 'system',
            content: 'You are a professional chef and recipe creator. Create detailed, practical recipes with clear instructions.'
          },
          {
            role: 'user',
            content: `Create a delicious recipe using these ingredients: ${ingredients}. Include cooking time, difficulty level, and step-by-step instructions.`
          }
        ],
        temperature: 0.7,
        max_tokens: 500,
        top_p: 0.95,
        frequency_penalty: 0,
        presence_penalty: 0
      });
      
      setRecipe(response.choices[0]?.message?.content || 'No recipe generated');
    } catch (error) {
      console.error('Recipe generation failed:', error);
      setRecipe('Failed to generate recipe. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-4">
      <textarea
        value={ingredients}
        onChange={(e) => setIngredients(e.target.value)}
        placeholder="Enter your ingredients..."
        className="w-full p-3 border rounded-lg"
      />
      <button 
        onClick={generateRecipe} 
        disabled={loading || !ingredients.trim()}
        className="bg-blue-500 text-white px-4 py-2 rounded-lg disabled:opacity-50"
      >
        {loading ? 'Generating...' : 'Generate Recipe'}
      </button>
      {recipe && (
        <div className="bg-gray-50 p-4 rounded-lg">
          <pre className="whitespace-pre-wrap">{recipe}</pre>
        </div>
      )}
    </div>
  );
}
```

#### 2. Chat Interface Component (Azure OpenAI)
```typescript
// src/components/ChatInterface.tsx (Converted to Azure OpenAI)
import { openai } from '../lib/azure-openai';
import { useState } from 'react';

interface Message {
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: Date;
}

export function ChatInterface() {
  const [messages, setMessages] = useState<Message[]>([
    {
      role: 'system',
      content: 'You are a helpful cooking assistant with expertise in international cuisine. Provide friendly, practical cooking advice and answer questions about recipes, techniques, and ingredients.',
      timestamp: new Date()
    }
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);

  const sendMessage = async () => {
    if (!input.trim()) return;

    const userMessage: Message = {
      role: 'user',
      content: input,
      timestamp: new Date()
    };

    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setLoading(true);

    try {
      // Prepare messages for Azure OpenAI (exclude timestamps and limit context)
      const conversationMessages = messages
        .concat(userMessage)
        .slice(-10) // Keep last 10 messages for context
        .map(msg => ({
          role: msg.role,
          content: msg.content
        }));

      const response = await openai.chat.completions.create({
        model: import.meta.env.VITE_AZURE_OPENAI_DEPLOYMENT,
        messages: conversationMessages,
        temperature: 0.8,
        max_tokens: 800,
        top_p: 0.95,
        frequency_penalty: 0.3,
        presence_penalty: 0.3
      });

      const assistantMessage: Message = {
        role: 'assistant',
        content: response.choices[0]?.message?.content || 'I apologize, but I could not generate a response.',
        timestamp: new Date()
      };

      setMessages(prev => [...prev, assistantMessage]);
    } catch (error) {
      console.error('Chat failed:', error);
      const errorMessage: Message = {
        role: 'assistant',
        content: 'I apologize, but I encountered an error. Please try again.',
        timestamp: new Date()
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setLoading(false);
    }
  };

  // Filter out system messages for display
  const displayMessages = messages.filter(msg => msg.role !== 'system');

  return (
    <div className="flex flex-col h-96 border rounded-lg">
      <div className="flex-1 overflow-y-auto p-4 space-y-3">
        {displayMessages.map((message, index) => (
          <div key={index} className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}>
            <div className={`max-w-xs lg:max-w-md px-3 py-2 rounded-lg ${
              message.role === 'user' 
                ? 'bg-blue-500 text-white' 
                : 'bg-gray-200 text-gray-800'
            }`}>
              {message.content}
            </div>
          </div>
        ))}
        {loading && (
          <div className="flex justify-start">
            <div className="bg-gray-200 text-gray-800 px-3 py-2 rounded-lg">
              <div className="flex space-x-1">
                <div className="w-2 h-2 bg-gray-500 rounded-full animate-bounce"></div>
                <div className="w-2 h-2 bg-gray-500 rounded-full animate-bounce delay-100"></div>
                <div className="w-2 h-2 bg-gray-500 rounded-full animate-bounce delay-200"></div>
              </div>
            </div>
          </div>
        )}
      </div>
      <div className="border-t p-4 flex space-x-2">
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && !loading && sendMessage()}
          placeholder="Ask about recipes..."
          className="flex-1 border rounded-lg px-3 py-2"
          disabled={loading}
        />
        <button
          onClick={sendMessage}
          disabled={loading || !input.trim()}
          className="bg-blue-500 text-white px-4 py-2 rounded-lg disabled:opacity-50"
        >
          Send
        </button>
      </div>
    </div>
  );
}
```

#### 3. Recipe Search with Embeddings (Azure OpenAI)
```typescript
// src/components/RecipeSearch.tsx (Converted to Azure OpenAI)
import { embeddingClient } from '../lib/azure-openai';
import { useState, useEffect } from 'react';

interface Recipe {
  id: string;
  title: string;
  description: string;
  embedding?: number[];
  similarity?: number;
}

export function RecipeSearch() {
  const [query, setQuery] = useState('');
  const [recipes, setRecipes] = useState<Recipe[]>([]);
  const [searchResults, setSearchResults] = useState<Recipe[]>([]);
  const [loading, setLoading] = useState(false);

  const searchRecipes = async () => {
    if (!query.trim()) return;
    
    setLoading(true);
    try {
      // Get embedding for search query using Azure OpenAI
      const queryEmbeddingResponse = await embeddingClient.embeddings.create({
        model: import.meta.env.VITE_AZURE_OPENAI_EMBEDDING_DEPLOYMENT,
        input: query
      });

      const queryEmbedding = queryEmbeddingResponse.data[0].embedding;

      // Perform vector search
      const results = recipes.map(recipe => ({
        ...recipe,
        similarity: cosineSimilarity(queryEmbedding, recipe.embedding || [])
      }))
      .filter(recipe => (recipe.similarity || 0) > 0.7) // Filter by similarity threshold
      .sort((a, b) => (b.similarity || 0) - (a.similarity || 0))
      .slice(0, 5);

      setSearchResults(results);
    } catch (error) {
      console.error('Search failed:', error);
      setSearchResults([]);
    } finally {
      setLoading(false);
    }
  };

  const generateRecipeEmbeddings = async () => {
    // This would typically be done server-side or during data ingestion
    const recipesWithEmbeddings = await Promise.all(
      recipes.map(async (recipe) => {
        try {
          const embeddingResponse = await embeddingClient.embeddings.create({
            model: import.meta.env.VITE_AZURE_OPENAI_EMBEDDING_DEPLOYMENT,
            input: `${recipe.title} ${recipe.description}`
          });
          
          return {
            ...recipe,
            embedding: embeddingResponse.data[0].embedding
          };
        } catch (error) {
          console.error(`Failed to generate embedding for recipe ${recipe.id}:`, error);
          return recipe;
        }
      })
    );
    
    setRecipes(recipesWithEmbeddings);
  };

  const cosineSimilarity = (a: number[], b: number[]): number => {
    if (a.length === 0 || b.length === 0) return 0;
    
    const dotProduct = a.reduce((sum, val, i) => sum + val * b[i], 0);
    const magnitudeA = Math.sqrt(a.reduce((sum, val) => sum + val * val, 0));
    const magnitudeB = Math.sqrt(b.reduce((sum, val) => sum + val * val, 0));
    
    if (magnitudeA === 0 || magnitudeB === 0) return 0;
    
    return dotProduct / (magnitudeA * magnitudeB);
  };

  return (
    <div className="space-y-4">
      <div className="flex space-x-2">
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && !loading && searchRecipes()}
          placeholder="Search recipes..."
          className="flex-1 border rounded-lg px-3 py-2"
          disabled={loading}
        />
        <button
          onClick={searchRecipes}
          disabled={loading || !query.trim()}
          className="bg-green-500 text-white px-4 py-2 rounded-lg disabled:opacity-50"
        >
          {loading ? 'Searching...' : 'Search'}
        </button>
      </div>
      
      {searchResults.length > 0 && (
        <div className="space-y-2">
          <h3 className="font-semibold text-lg">Search Results</h3>
          {searchResults.map(recipe => (
            <div key={recipe.id} className="p-3 border rounded-lg">
              <h4 className="font-semibold">{recipe.title}</h4>
              <p className="text-gray-600">{recipe.description}</p>
              <span className="text-sm text-blue-500">
                Similarity: {((recipe.similarity || 0) * 100).toFixed(1)}%
              </span>
            </div>
          ))}
        </div>
      )}
      
      {searchResults.length === 0 && query && !loading && (
        <div className="text-gray-500 text-center py-4">
          No recipes found matching your search.
        </div>
      )}
    </div>
  );
}
```

### Environment Configuration

#### .env.example
```bash
# Azure OpenAI Configuration
VITE_AZURE_OPENAI_ENDPOINT=https://your-openai-resource.openai.azure.com
VITE_AZURE_OPENAI_API_KEY=your-api-key-here
VITE_AZURE_OPENAI_DEPLOYMENT=gpt-4
VITE_AZURE_OPENAI_EMBEDDING_DEPLOYMENT=text-embedding-ada-002
VITE_AZURE_OPENAI_API_VERSION=2024-08-01-preview

# Alternative: Use Azure Key Vault references for production
# AZURE_OPENAI_API_KEY=@Microsoft.KeyVault(VaultName=your-keyvault;SecretName=openai-api-key)
```

### Key Conversion Points

1. **API Structure Change**: Spark's simple function calls → Azure OpenAI's more structured API
2. **Authentication**: Built-in auth → Azure API key management
3. **Message Format**: Spark's context → OpenAI's messages array
4. **Error Handling**: More robust error handling needed for Azure OpenAI
5. **Cost Optimization**: Token usage tracking and limits
6. **Security**: API keys in environment variables/Key Vault

### Benefits of Azure OpenAI Migration

- **Enterprise Security**: Integration with Azure Key Vault and managed identities
- **Cost Control**: Better monitoring and budgeting capabilities
- **Compliance**: Meets enterprise compliance requirements
- **Scalability**: Auto-scaling and regional deployment options
- **Integration**: Native integration with other Azure services

This conversion maintains the same user experience while providing enterprise-grade AI capabilities through Azure OpenAI.