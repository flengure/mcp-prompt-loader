# Gemini Code Assist MCP Configuration

Configure Google's Gemini Code Assist to use specialized AI experts via MCP.

## Configuration Location

Gemini Code Assist uses MCP through the Model Context Protocol specification.

**Configuration file**: `.gemini-mcp-config.json` in your project root or home directory

## Example Configuration

```json
{
  "mcpServers": {
    "hummingbot-trading-expert": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i", "--pull=always",
        "-v", "/path/to/mcp-prompt-loader:/data:ro",
        "-e", "PROMPT_FILE=hummingbot.txt",
        "-e", "PROMPT_BASE_DIR=/data",
        "-e", "CLIENT_NAME=gemini-code-assist",
        "flengure/mcp-prompt-loader:latest"
      ],
      "env": {
        "GEMINI_MODEL": "gemini-1.5-pro",
        "EXPERT_DOMAIN": "trading"
      }
    },
    "n8n-automation-expert": {
      "command": "docker", 
      "args": [
        "run", "--rm", "-i", "--pull=always",
        "-v", "/path/to/mcp-prompt-loader:/data:ro",
        "-e", "PROMPT_FILE=n8n.txt",
        "-e", "PROMPT_BASE_DIR=/data",
        "-e", "CLIENT_NAME=gemini-code-assist",
        "flengure/mcp-prompt-loader:latest"
      ],
      "env": {
        "GEMINI_MODEL": "gemini-1.5-pro",
        "EXPERT_DOMAIN": "automation"
      }
    },
    "code-editor-expert": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i", "--pull=always", 
        "-v", "/path/to/mcp-prompt-loader:/data:ro",
        "-e", "PROMPT_FILE=zed.txt",
        "-e", "PROMPT_BASE_DIR=/data", 
        "-e", "CLIENT_NAME=gemini-code-assist",
        "flengure/mcp-prompt-loader:latest"
      ],
      "env": {
        "GEMINI_MODEL": "gemini-1.5-pro",
        "EXPERT_DOMAIN": "development"
      }
    }
  }
}
```

## Google Cloud Integration

For enterprise setups with Google Cloud:

```json
{
  "mcpServers": {
    "trading-expert": {
      "command": "gcloud",
      "args": [
        "run", "execute", 
        "--image=flengure/mcp-prompt-loader:latest",
        "--env-vars=PROMPT_FILE=hummingbot.txt,PROMPT_BASE_DIR=/data",
        "--mount-path=/data",
        "--source=/path/to/prompts"
      ],
      "env": {
        "GOOGLE_CLOUD_PROJECT": "your-project-id",
        "GOOGLE_APPLICATION_CREDENTIALS": "/path/to/service-account.json"
      }
    }
  }
}
```

## VS Code Extension Integration

If using Gemini through VS Code extension:

### **settings.json**
```json
{
  "gemini.mcp.servers": {
    "hummingbot-expert": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i", "--pull=always",
        "-v", "${workspaceFolder}/prompts:/data:ro",
        "-e", "PROMPT_FILE=hummingbot.txt",
        "flengure/mcp-prompt-loader:latest"
      ]
    }
  },
  "gemini.mcp.autoStart": true,
  "gemini.mcp.timeout": 30000
}
```

## Environment Variables

The prompt loader supports Gemini-specific environment variables:

```bash
# Gemini client identification
CLIENT_NAME=gemini-code-assist

# Model specifications  
GEMINI_MODEL=gemini-1.5-pro
EXPERT_DOMAIN=trading

# Gemini API settings
GOOGLE_API_KEY=your-api-key
GOOGLE_CLOUD_PROJECT=your-project

# Debug settings
DEBUG_MODE=true
LOG_LEVEL=info
```

## Project-Specific Configuration

Create a `.gemini-mcp.json` in your project root:

```json
{
  "experts": {
    "trading": {
      "promptFile": "hummingbot.txt",
      "description": "Algorithmic trading and market making expert"
    },
    "automation": {
      "promptFile": "n8n.txt", 
      "description": "Workflow automation and integration expert"
    },
    "development": {
      "promptFile": "zed.txt",
      "description": "Code editor and development environment expert"
    }
  },
  "defaultExpert": "development",
  "promptDirectory": "./prompts"
}
```

## Usage in Gemini Code Assist

1. **Select Expert**: Choose appropriate expert for your task
2. **Context Switch**: Use `/expert trading` to switch to trading expert
3. **Specialized Help**: Ask domain-specific questions
4. **Code Generation**: Get expert-level code suggestions

### Example Commands

```bash
# Switch to trading expert
/expert trading

# Ask for trading strategy
"Create a market making strategy for BTC/USDT"

# Switch to automation expert  
/expert automation

# Ask for workflow help
"Design an n8n workflow for data processing"
```

## Troubleshooting

### Common Issues

1. **Authentication**: Ensure Google Cloud credentials are configured
2. **Docker permissions**: Verify Docker daemon is accessible
3. **Network access**: Check firewall settings for container communication
4. **Path resolution**: Use absolute paths for volume mounts

### Debug Mode

Enable verbose logging:

```json
{
  "env": {
    "DEBUG_MODE": "true",
    "LOG_LEVEL": "debug",
    "GEMINI_DEBUG": "true"
  }
}
```

### Testing Connection

```bash
# Test Docker image directly
docker run --rm -i \
  -v "/path/to/prompts:/data:ro" \
  -e "PROMPT_FILE=hummingbot.txt" \
  -e "CLIENT_NAME=gemini-test" \
  flengure/mcp-prompt-loader:latest

# Test with Gemini CLI (if available)
gemini-mcp test --server hummingbot-expert
```
