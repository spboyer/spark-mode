# Complete Spark AI + useKV to Azure Conversion Example

This example demonstrates converting a full GitHub Spark application that uses both AI capabilities (`spark.llmPrompt()`, `spark.chat()`) and data storage (`useKV`) to Azure services.

## Original Spark Application: Recipe Management with AI

### Spark App Structure with AI + Data Storage

```
recipe-manager-ai/
├── src/
│   ├── components/
│   │   ├── RecipeGenerator.tsx      # Uses spark.llmPrompt() + useKV
│   │   ├── RecipeLibrary.tsx        # Uses useKV for recipe storage
│   │   ├── AIChatAssistant.tsx      # Uses spark.chat() + useKV for history
│   │   ├── RecipeSearch.tsx         # Uses spark.embedding() + useKV
│   │   └── UserPreferences.tsx      # Uses useKV for settings
│   ├── hooks/
│   │   ├── useSparkAI.ts           # Spark AI integration
│   │   ├── useRecipeData.ts        # useKV data management
│   │   └── useUserSettings.ts      # useKV user preferences
│   └── App.tsx
├── spark.meta.json
├── package.json                    # @github/spark dependency
└── vite.config.ts
```

### Original Spark Implementation

#### 1. Recipe Generator with AI + Storage
```typescript
// src/components/RecipeGenerator.tsx (Original Spark)
import { spark } from '@github/spark';
import { useKV } from '@github/spark/hooks';
import { useState } from 'react';

interface Recipe {
  id: string;
  title: string;
  ingredients: string[];
  instructions: string[];
  aiGenerated: boolean;
  createdAt: string;
}

export function RecipeGenerator() {
  const [ingredients, setIngredients] = useState('');
  const [generatedRecipe, setGeneratedRecipe] = useState<Recipe | null>(null);
  const [loading, setLoading] = useState(false);
  
  // Spark useKV for storing generated recipes
  const [savedRecipes, setSavedRecipes] = useKV<Recipe[]>('user-recipes', []);
  const [userPrefs, setUserPrefs] = useKV('user-preferences', {
    dietaryRestrictions: [],
    preferredCuisine: 'any',
    skillLevel: 'beginner'
  });

  const generateRecipe = async () => {
    setLoading(true);
    try {
      const prompt = `Create a ${userPrefs.skillLevel} level ${userPrefs.preferredCuisine} recipe using: ${ingredients}.
                     Dietary restrictions: ${userPrefs.dietaryRestrictions.join(', ') || 'none'}.
                     Format as JSON with title, ingredients array, and instructions array.`;

      const response = await spark.llmPrompt({
        prompt,
        model: 'gpt-4',
        temperature: 0.7,
        maxTokens: 800
      });

      const recipe: Recipe = {
        id: `recipe-${Date.now()}`,
        ...JSON.parse(response.text),
        aiGenerated: true,
        createdAt: new Date().toISOString()
      };

      setGeneratedRecipe(recipe);
    } catch (error) {
      console.error('Recipe generation failed:', error);
    } finally {
      setLoading(false);
    }
  };

  const saveRecipe = () => {
    if (generatedRecipe) {
      setSavedRecipes(prev => [generatedRecipe, ...prev]);
      setGeneratedRecipe(null);
    }
  };

  return (
    <div className="space-y-6">
      <div className="space-y-4">
        <textarea
          value={ingredients}
          onChange={(e) => setIngredients(e.target.value)}
          placeholder="Enter ingredients you have..."
          className="w-full p-3 border rounded-lg h-24"
        />
        
        <div className="flex space-x-4">
          <select 
            value={userPrefs.skillLevel}
            onChange={(e) => setUserPrefs({...userPrefs, skillLevel: e.target.value})}
            className="border rounded-lg px-3 py-2"
          >
            <option value="beginner">Beginner</option>
            <option value="intermediate">Intermediate</option>
            <option value="advanced">Advanced</option>
          </select>
          
          <select
            value={userPrefs.preferredCuisine}
            onChange={(e) => setUserPrefs({...userPrefs, preferredCuisine: e.target.value})}
            className="border rounded-lg px-3 py-2"
          >
            <option value="any">Any Cuisine</option>
            <option value="italian">Italian</option>
            <option value="asian">Asian</option>
            <option value="mexican">Mexican</option>
          </select>
        </div>

        <button 
          onClick={generateRecipe}
          disabled={loading || !ingredients.trim()}
          className="bg-blue-500 text-white px-6 py-2 rounded-lg disabled:opacity-50"
        >
          {loading ? 'Generating Recipe...' : 'Generate Recipe'}
        </button>
      </div>

      {generatedRecipe && (
        <div className="bg-green-50 p-6 rounded-lg border">
          <h3 className="text-xl font-bold mb-4">{generatedRecipe.title}</h3>
          
          <div className="mb-4">
            <h4 className="font-semibold mb-2">Ingredients:</h4>
            <ul className="list-disc list-inside space-y-1">
              {generatedRecipe.ingredients.map((ingredient, index) => (
                <li key={index}>{ingredient}</li>
              ))}
            </ul>
          </div>

          <div className="mb-4">
            <h4 className="font-semibold mb-2">Instructions:</h4>
            <ol className="list-decimal list-inside space-y-2">
              {generatedRecipe.instructions.map((instruction, index) => (
                <li key={index}>{instruction}</li>
              ))}
            </ol>
          </div>

          <button
            onClick={saveRecipe}
            className="bg-green-500 text-white px-4 py-2 rounded-lg"
          >
            Save Recipe
          </button>
        </div>
      )}

      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="font-semibold mb-2">Saved Recipes ({savedRecipes.length})</h3>
        {savedRecipes.slice(0, 3).map(recipe => (
          <div key={recipe.id} className="mb-2 p-2 bg-white rounded border">
            <span className="font-medium">{recipe.title}</span>
            {recipe.aiGenerated && (
              <span className="ml-2 text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">
                AI Generated
              </span>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
```

#### 2. AI Chat Assistant with Conversation History
```typescript
// src/components/AIChatAssistant.tsx (Original Spark)
import { spark } from '@github/spark';
import { useKV } from '@github/spark/hooks';
import { useState } from 'react';

interface ChatMessage {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: string;
}

export function AIChatAssistant() {
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  
  // Store chat history with useKV
  const [chatHistory, setChatHistory] = useKV<ChatMessage[]>('chat-history', []);
  
  const sendMessage = async () => {
    if (!input.trim()) return;

    const userMessage: ChatMessage = {
      id: `msg-${Date.now()}`,
      role: 'user',
      content: input,
      timestamp: new Date().toISOString()
    };

    setChatHistory(prev => [...prev, userMessage]);
    setInput('');
    setLoading(true);

    try {
      const response = await spark.chat({
        message: input,
        context: chatHistory.slice(-10), // Last 10 messages for context
        personality: 'expert cooking assistant with knowledge of international cuisine and dietary needs'
      });

      const assistantMessage: ChatMessage = {
        id: `msg-${Date.now() + 1}`,
        role: 'assistant',
        content: response.text,
        timestamp: new Date().toISOString()
      };

      setChatHistory(prev => [...prev, assistantMessage]);
    } catch (error) {
      console.error('Chat failed:', error);
    } finally {
      setLoading(false);
    }
  };

  const clearHistory = () => {
    setChatHistory([]);
  };

  return (
    <div className="flex flex-col h-96 border rounded-lg">
      <div className="flex justify-between items-center p-3 border-b">
        <h3 className="font-semibold">AI Cooking Assistant</h3>
        <button
          onClick={clearHistory}
          className="text-sm text-gray-500 hover:text-gray-700"
        >
          Clear History
        </button>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-3">
        {chatHistory.map((message) => (
          <div key={message.id} className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}>
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
            <div className="bg-gray-200 px-3 py-2 rounded-lg">
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
          placeholder="Ask about cooking techniques, ingredients, recipes..."
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

#### 3. Recipe Search with Vector Storage
```typescript
// src/components/RecipeSearch.tsx (Original Spark)
import { spark } from '@github/spark';
import { useKV } from '@github/spark/hooks';
import { useState, useEffect } from 'react';

interface Recipe {
  id: string;
  title: string;
  description: string;
  ingredients: string[];
  embedding?: number[];
}

interface SearchResult extends Recipe {
  similarity: number;
}

export function RecipeSearch() {
  const [query, setQuery] = useState('');
  const [searchResults, setSearchResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);
  
  // Store recipes and their embeddings with useKV
  const [recipes, setRecipes] = useKV<Recipe[]>('all-recipes', []);
  const [searchCache, setSearchCache] = useKV<Record<string, SearchResult[]>>('search-cache', {});

  const searchRecipes = async () => {
    if (!query.trim()) return;

    // Check cache first
    if (searchCache[query]) {
      setSearchResults(searchCache[query]);
      return;
    }

    setLoading(true);
    try {
      // Generate embedding for search query
      const queryEmbedding = await spark.embedding({
        text: query,
        model: 'text-embedding-ada-002'
      });

      // Calculate similarities
      const results = recipes
        .filter(recipe => recipe.embedding)
        .map(recipe => ({
          ...recipe,
          similarity: cosineSimilarity(queryEmbedding.embedding, recipe.embedding!)
        }))
        .filter(result => result.similarity > 0.75)
        .sort((a, b) => b.similarity - a.similarity)
        .slice(0, 10);

      setSearchResults(results);
      
      // Cache results
      setSearchCache(prev => ({
        ...prev,
        [query]: results
      }));
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
          onKeyPress={(e) => e.key === 'Enter' && searchRecipes()}
          placeholder="Search recipes by description, ingredients, or cuisine..."
          className="flex-1 border rounded-lg px-3 py-2"
        />
        <button
          onClick={searchRecipes}
          disabled={loading}
          className="bg-green-500 text-white px-4 py-2 rounded-lg"
        >
          {loading ? 'Searching...' : 'Search'}
        </button>
      </div>

      {searchResults.length > 0 && (
        <div className="space-y-3">
          <h3 className="font-semibold">Search Results</h3>
          {searchResults.map(recipe => (
            <div key={recipe.id} className="p-4 border rounded-lg">
              <h4 className="font-semibold">{recipe.title}</h4>
              <p className="text-gray-600 mb-2">{recipe.description}</p>
              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-500">
                  {recipe.ingredients.length} ingredients
                </span>
                <span className="text-sm text-blue-500">
                  {(recipe.similarity * 100).toFixed(1)}% match
                </span>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
```

## Converted Azure Implementation

### Architecture Decision: Container-Based Stack

**Why Container-Based Stack?**
- Complex AI processing with conversation memory
- Multiple database requirements (recipes, chat history, user preferences)
- Need for server-side AI orchestration
- Vector search capabilities for recipe embeddings

### Azure Services Selected
- **Container Apps**: Frontend and backend APIs
- **Azure Cosmos DB**: Document storage for recipes and chat history
- **Azure OpenAI**: AI capabilities
- **Azure Redis Cache**: Search result caching
- **Azure Key Vault**: Secrets management

### Updated Dependencies
```json
{
  "dependencies": {
    "react": "^18.2.0",
    "typescript": "^5.0.0",
    "openai": "^4.20.0",
    "@azure/cosmos": "^4.0.0",
    "ioredis": "^5.3.0",
    "@azure/keyvault-secrets": "^4.7.0"
  }
}
```

### Backend API Implementation

#### Database Configuration
```typescript
// src/lib/database.ts
import { CosmosClient } from '@azure/cosmos';
import Redis from 'ioredis';

// Cosmos DB client
export const cosmosClient = new CosmosClient({
  endpoint: process.env.COSMOS_DB_ENDPOINT!,
  key: process.env.COSMOS_DB_KEY!
});

export const database = cosmosClient.database('recipeapp');
export const recipesContainer = database.container('recipes');
export const chatContainer = database.container('chats');
export const preferencesContainer = database.container('preferences');

// Redis client for caching
export const redis = new Redis({
  host: process.env.REDIS_HOST!,
  port: parseInt(process.env.REDIS_PORT || '6380'),
  password: process.env.REDIS_PASSWORD!,
  tls: process.env.NODE_ENV === 'production' ? {} : undefined
});
```

#### Recipe Service with AI Integration
```typescript
// src/services/recipeService.ts
import { openai } from '../lib/azure-openai';
import { recipesContainer, redis } from '../lib/database';

interface Recipe {
  id: string;
  title: string;
  description: string;
  ingredients: string[];
  instructions: string[];
  aiGenerated: boolean;
  embedding?: number[];
  userId: string;
  createdAt: string;
}

export class RecipeService {
  async generateRecipe(
    ingredients: string,
    userPreferences: any,
    userId: string
  ): Promise<Recipe> {
    const prompt = `Create a ${userPreferences.skillLevel} level ${userPreferences.preferredCuisine} recipe using: ${ingredients}.
                   Dietary restrictions: ${userPreferences.dietaryRestrictions?.join(', ') || 'none'}.
                   Return a JSON object with title, description, ingredients (array), and instructions (array).`;

    const response = await openai.chat.completions.create({
      model: process.env.AZURE_OPENAI_DEPLOYMENT!,
      messages: [
        {
          role: 'system',
          content: 'You are a professional chef. Create detailed, practical recipes. Always respond with valid JSON.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      temperature: 0.7,
      max_tokens: 1000
    });

    const recipeData = JSON.parse(response.choices[0]?.message?.content || '{}');
    
    // Generate embedding for search
    const embeddingResponse = await openai.embeddings.create({
      model: process.env.AZURE_OPENAI_EMBEDDING_DEPLOYMENT!,
      input: `${recipeData.title} ${recipeData.description} ${recipeData.ingredients?.join(' ')}`
    });

    const recipe: Recipe = {
      id: `recipe-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      ...recipeData,
      aiGenerated: true,
      embedding: embeddingResponse.data[0].embedding,
      userId,
      createdAt: new Date().toISOString()
    };

    return recipe;
  }

  async saveRecipe(recipe: Recipe): Promise<Recipe> {
    const { resource } = await recipesContainer.items.create(recipe);
    return resource;
  }

  async getUserRecipes(userId: string): Promise<Recipe[]> {
    const cacheKey = `user-recipes:${userId}`;
    
    // Check cache first
    const cached = await redis.get(cacheKey);
    if (cached) {
      return JSON.parse(cached);
    }

    const { resources } = await recipesContainer.items
      .query({
        query: 'SELECT * FROM c WHERE c.userId = @userId ORDER BY c.createdAt DESC',
        parameters: [{ name: '@userId', value: userId }]
      })
      .fetchAll();

    // Cache for 5 minutes
    await redis.setex(cacheKey, 300, JSON.stringify(resources));
    
    return resources;
  }

  async searchRecipes(query: string, userId?: string): Promise<Recipe[]> {
    const cacheKey = `search:${query}:${userId || 'all'}`;
    
    // Check cache
    const cached = await redis.get(cacheKey);
    if (cached) {
      return JSON.parse(cached);
    }

    // Generate query embedding
    const embeddingResponse = await openai.embeddings.create({
      model: process.env.AZURE_OPENAI_EMBEDDING_DEPLOYMENT!,
      input: query
    });

    const queryEmbedding = embeddingResponse.data[0].embedding;

    // Get all recipes (in production, use vector search)
    const { resources: allRecipes } = await recipesContainer.items
      .query({
        query: userId ? 
          'SELECT * FROM c WHERE c.userId = @userId' :
          'SELECT * FROM c',
        parameters: userId ? [{ name: '@userId', value: userId }] : []
      })
      .fetchAll();

    // Calculate similarities
    const results = allRecipes
      .filter(recipe => recipe.embedding)
      .map(recipe => ({
        ...recipe,
        similarity: this.cosineSimilarity(queryEmbedding, recipe.embedding)
      }))
      .filter(result => result.similarity > 0.75)
      .sort((a, b) => b.similarity - a.similarity)
      .slice(0, 10);

    // Cache for 10 minutes
    await redis.setex(cacheKey, 600, JSON.stringify(results));

    return results;
  }

  private cosineSimilarity(a: number[], b: number[]): number {
    const dotProduct = a.reduce((sum, val, i) => sum + val * (b[i] || 0), 0);
    const magnitudeA = Math.sqrt(a.reduce((sum, val) => sum + val * val, 0));
    const magnitudeB = Math.sqrt(b.reduce((sum, val) => sum + val * val, 0));
    return magnitudeA && magnitudeB ? dotProduct / (magnitudeA * magnitudeB) : 0;
  }
}
```

#### Chat Service with History Management
```typescript
// src/services/chatService.ts
import { openai } from '../lib/azure-openai';
import { chatContainer } from '../lib/database';

interface ChatMessage {
  id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: string;
  userId: string;
}

export class ChatService {
  async sendMessage(message: string, userId: string): Promise<ChatMessage> {
    // Save user message
    const userMessage: ChatMessage = {
      id: `msg-${Date.now()}`,
      role: 'user',
      content: message,
      timestamp: new Date().toISOString(),
      userId
    };

    await chatContainer.items.create(userMessage);

    // Get conversation history
    const history = await this.getChatHistory(userId, 10);

    // Prepare messages for OpenAI
    const messages = [
      {
        role: 'system' as const,
        content: 'You are an expert cooking assistant with knowledge of international cuisine, dietary needs, and cooking techniques. Provide helpful, practical advice.'
      },
      ...history.slice(-9).map(msg => ({
        role: msg.role as 'user' | 'assistant',
        content: msg.content
      })),
      {
        role: 'user' as const,
        content: message
      }
    ];

    // Get AI response
    const response = await openai.chat.completions.create({
      model: process.env.AZURE_OPENAI_DEPLOYMENT!,
      messages,
      temperature: 0.8,
      max_tokens: 800
    });

    // Save assistant message
    const assistantMessage: ChatMessage = {
      id: `msg-${Date.now() + 1}`,
      role: 'assistant',
      content: response.choices[0]?.message?.content || 'I apologize, but I could not generate a response.',
      timestamp: new Date().toISOString(),
      userId
    };

    await chatContainer.items.create(assistantMessage);

    return assistantMessage;
  }

  async getChatHistory(userId: string, limit: number = 50): Promise<ChatMessage[]> {
    const { resources } = await chatContainer.items
      .query({
        query: 'SELECT * FROM c WHERE c.userId = @userId ORDER BY c.timestamp DESC OFFSET 0 LIMIT @limit',
        parameters: [
          { name: '@userId', value: userId },
          { name: '@limit', value: limit }
        ]
      })
      .fetchAll();

    return resources.reverse(); // Return in chronological order
  }

  async clearChatHistory(userId: string): Promise<void> {
    const { resources } = await chatContainer.items
      .query({
        query: 'SELECT c.id FROM c WHERE c.userId = @userId',
        parameters: [{ name: '@userId', value: userId }]
      })
      .fetchAll();

    // Delete all messages for user
    await Promise.all(
      resources.map(item => 
        chatContainer.item(item.id, userId).delete()
      )
    );
  }
}
```

### Frontend React Hooks (Converted from useKV)

#### Custom Cosmos DB Hook
```typescript
// src/hooks/useCosmosData.ts
import { useState, useEffect } from 'react';

export function useCosmosData<T>(
  endpoint: string,
  defaultValue: T,
  dependencies: any[] = []
) {
  const [data, setData] = useState<T>(defaultValue);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadData();
  }, dependencies);

  const loadData = async () => {
    try {
      setLoading(true);
      const response = await fetch(`/api${endpoint}`);
      if (!response.ok) throw new Error('Failed to load data');
      
      const result = await response.json();
      setData(result);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  const updateData = async (newData: Partial<T>) => {
    try {
      const response = await fetch(`/api${endpoint}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newData)
      });
      
      if (!response.ok) throw new Error('Failed to update data');
      
      const result = await response.json();
      setData(result);
      return result;
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Update failed');
      throw err;
    }
  };

  return {
    data,
    loading,
    error,
    refresh: loadData,
    update: updateData
  };
}
```

#### Updated Recipe Generator Component
```typescript
// src/components/RecipeGenerator.tsx (Converted to Azure)
import { useState } from 'react';
import { useCosmosData } from '../hooks/useCosmosData';

interface Recipe {
  id: string;
  title: string;
  ingredients: string[];
  instructions: string[];
  aiGenerated: boolean;
  createdAt: string;
}

export function RecipeGenerator() {
  const [ingredients, setIngredients] = useState('');
  const [generatedRecipe, setGeneratedRecipe] = useState<Recipe | null>(null);
  const [loading, setLoading] = useState(false);
  
  // Replace useKV with Cosmos DB API calls
  const {
    data: savedRecipes,
    refresh: refreshRecipes
  } = useCosmosData<Recipe[]>('/recipes', []);

  const {
    data: userPrefs,
    update: updatePrefs
  } = useCosmosData('/user/preferences', {
    dietaryRestrictions: [],
    preferredCuisine: 'any',
    skillLevel: 'beginner'
  });

  const generateRecipe = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/recipes/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ingredients,
          userPreferences: userPrefs
        })
      });

      if (!response.ok) throw new Error('Failed to generate recipe');
      
      const recipe = await response.json();
      setGeneratedRecipe(recipe);
    } catch (error) {
      console.error('Recipe generation failed:', error);
    } finally {
      setLoading(false);
    }
  };

  const saveRecipe = async () => {
    if (!generatedRecipe) return;
    
    try {
      await fetch('/api/recipes', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(generatedRecipe)
      });
      
      await refreshRecipes();
      setGeneratedRecipe(null);
    } catch (error) {
      console.error('Failed to save recipe:', error);
    }
  };

  return (
    <div className="space-y-6">
      <div className="space-y-4">
        <textarea
          value={ingredients}
          onChange={(e) => setIngredients(e.target.value)}
          placeholder="Enter ingredients you have..."
          className="w-full p-3 border rounded-lg h-24"
        />
        
        <div className="flex space-x-4">
          <select 
            value={userPrefs.skillLevel}
            onChange={(e) => updatePrefs({skillLevel: e.target.value})}
            className="border rounded-lg px-3 py-2"
          >
            <option value="beginner">Beginner</option>
            <option value="intermediate">Intermediate</option>
            <option value="advanced">Advanced</option>
          </select>
          
          <select
            value={userPrefs.preferredCuisine}
            onChange={(e) => updatePrefs({preferredCuisine: e.target.value})}
            className="border rounded-lg px-3 py-2"
          >
            <option value="any">Any Cuisine</option>
            <option value="italian">Italian</option>
            <option value="asian">Asian</option>
            <option value="mexican">Mexican</option>
          </select>
        </div>

        <button 
          onClick={generateRecipe}
          disabled={loading || !ingredients.trim()}
          className="bg-blue-500 text-white px-6 py-2 rounded-lg disabled:opacity-50"
        >
          {loading ? 'Generating Recipe...' : 'Generate Recipe'}
        </button>
      </div>

      {generatedRecipe && (
        <div className="bg-green-50 p-6 rounded-lg border">
          <h3 className="text-xl font-bold mb-4">{generatedRecipe.title}</h3>
          
          <div className="mb-4">
            <h4 className="font-semibold mb-2">Ingredients:</h4>
            <ul className="list-disc list-inside space-y-1">
              {generatedRecipe.ingredients.map((ingredient, index) => (
                <li key={index}>{ingredient}</li>
              ))}
            </ul>
          </div>

          <div className="mb-4">
            <h4 className="font-semibold mb-2">Instructions:</h4>
            <ol className="list-decimal list-inside space-y-2">
              {generatedRecipe.instructions.map((instruction, index) => (
                <li key={index}>{instruction}</li>
              ))}
            </ol>
          </div>

          <button
            onClick={saveRecipe}
            className="bg-green-500 text-white px-4 py-2 rounded-lg"
          >
            Save Recipe
          </button>
        </div>
      )}

      <div className="bg-gray-50 p-4 rounded-lg">
        <h3 className="font-semibold mb-2">Saved Recipes ({savedRecipes.length})</h3>
        {savedRecipes.slice(0, 3).map(recipe => (
          <div key={recipe.id} className="mb-2 p-2 bg-white rounded border">
            <span className="font-medium">{recipe.title}</span>
            {recipe.aiGenerated && (
              <span className="ml-2 text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">
                AI Generated
              </span>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
```

### Infrastructure Configuration (Bicep)

```bicep
// Complete infrastructure for Spark AI + useKV conversion
targetScope = 'subscription'

param environmentName string
param location string = 'East US 2'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${environmentName}'
  location: location
}

module containerApps 'modules/container-apps.bicep' = {
  name: 'container-apps'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
  }
}

module cosmosDb 'modules/cosmos-db.bicep' = {
  name: 'cosmos-db'
  scope: rg
  params: {
    accountName: 'cosmos-${environmentName}'
    location: location
  }
}

module openAI 'modules/openai.bicep' = {
  name: 'openai'
  scope: rg
  params: {
    name: 'openai-${environmentName}'
    location: location
  }
}

module redis 'modules/redis.bicep' = {
  name: 'redis'
  scope: rg
  params: {
    name: 'redis-${environmentName}'
    location: location
  }
}

module keyVault 'modules/key-vault.bicep' = {
  name: 'key-vault'
  scope: rg
  params: {
    name: 'kv-${environmentName}'
    location: location
  }
}
```

### Migration Summary

**Before (Spark):**
- `useKV('user-recipes', [])` → **Azure Cosmos DB with REST API**
- `useKV('chat-history', [])` → **Azure Cosmos DB with conversation management**
- `useKV('user-preferences', {})` → **Azure Cosmos DB user preferences**
- `useKV('search-cache', {})` → **Azure Redis Cache for performance**
- `spark.llmPrompt()` → **Azure OpenAI Chat Completions**
- `spark.chat()` → **Azure OpenAI with conversation context**
- `spark.embedding()` → **Azure OpenAI Embeddings API**

**After (Azure):**
- **Database**: Scalable, globally distributed Azure Cosmos DB
- **Caching**: High-performance Azure Redis Cache
- **AI**: Enterprise-grade Azure OpenAI with security and compliance
- **Deployment**: Container Apps with auto-scaling
- **Security**: Key Vault for secrets management
- **Monitoring**: Application Insights for observability

**Benefits:**
- **Performance**: Redis caching + Cosmos DB global distribution
- **Scalability**: Auto-scaling container apps and serverless databases
- **Security**: Enterprise security with Key Vault and managed identities
- **Cost Optimization**: Serverless Cosmos DB and optimized AI usage
- **Reliability**: 99.99% SLA and automated backups