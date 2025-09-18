# Debug settings
DEBUG_MODE=true
LOG_LEVEL=debug
```

## Usage Patterns

### **1. Command Palette Integration**

Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS) and use:

```
> MCP: Switch to Hummingbot Expert
> MCP: Switch to n8n Expert  
> MCP: Switch to Development Expert
> MCP: Ask Current Expert
> MCP: Reload MCP Servers
```

### **2. Context Menu Integration**

Right-click in editor:
- **Ask Expert** → Query current expert about selection
- **Switch Expert** → Change to different domain expert
- **Explain Code** → Get expert explanation of selected code

### **3. Sidebar Integration**

MCP Extension adds a sidebar panel:
- **Active Expert**: Shows current expert status
- **Quick Switch**: Buttons to change experts
- **Expert Chat**: Direct conversation interface
- **Context Info**: Shows what context is being sent

## Advanced Features

### **Multi-Workspace Support**

```json
{
  "folders": [
    {
      "name": "Trading Project",
      "path": "./trading-bot"
    },
    {
      "name": "Automation Project", 
      "path": "./n8n-workflows"
    }
  ],
  "settings": {
    "mcp.workspaceExperts": {
      "trading-bot": "hummingbot-trading-expert",
      "n8n-workflows": "n8n-automation-expert"
    }
  }
}
```

### **Automatic Expert Selection**

```json
{
  "mcp.autoSelectExpert": {
    "*.py": "hummingbot-trading-expert",
    "*.ts": "n8n-automation-expert", 
    "*.js": "n8n-automation-expert",
    "*.json": "mcp-gateway-expert",
    "*.yaml": "mcp-gateway-expert"
  }
}
```

### **Context-Aware Prompting**

The extension automatically includes:
- Current file content
- Selected text
- Open file tabs
- Git branch info
- Project dependencies
- Workspace structure

## Snippets Integration

### **.vscode/snippets/expert-prompts.json**

```json
{
  "Ask Hummingbot Expert": {
    "prefix": "ask-hb",
    "body": [
      "// Switching to Hummingbot trading expert",
      "// Expert context: ${1:trading strategy}",
      "// Question: ${2:your question here}",
      "$0"
    ],
    "description": "Template for Hummingbot expert queries"
  },
  "Ask n8n Expert": {
    "prefix": "ask-n8n",
    "body": [
      "// Switching to n8n automation expert", 
      "// Workflow context: ${1:automation task}",
      "// Question: ${2:your question here}",
      "$0"
    ],
    "description": "Template for n8n expert queries"
  }
}
```

## Extension Development

### **Basic Extension Structure**

```typescript
// src/extension.ts
import * as vscode from 'vscode';
import { MCPClient } from './mcpClient';

export function activate(context: vscode.ExtensionContext) {
    const mcpClient = new MCPClient();
    
    // Switch expert command
    const switchExpert = vscode.commands.registerCommand(
        'promptLoader.switchExpert', 
        async (expertName: string) => {
            await mcpClient.switchExpert(expertName);
            vscode.window.showInformationMessage(`Switched to ${expertName}`);
        }
    );
    
    // Ask expert command
    const askExpert = vscode.commands.registerCommand(
        'promptLoader.askExpert',
        async () => {
            const editor = vscode.window.activeTextEditor;
            if (editor) {
                const selection = editor.document.getText(editor.selection);
                const response = await mcpClient.askExpert(selection);
                // Show response in new editor or panel
            }
        }
    );
    
    context.subscriptions.push(switchExpert, askExpert);
}
```

### **MCP Client Implementation**

```typescript
// src/mcpClient.ts
import { spawn } from 'child_process';

export class MCPClient {
    private currentExpert: string = '';
    
    async switchExpert(expertName: string): Promise<void> {
        this.currentExpert = expertName;
        
        const config = vscode.workspace.getConfiguration('mcp');
        const servers = config.get('servers') as any;
        
        if (servers[expertName]) {
            // Start new MCP server
            await this.startServer(servers[expertName]);
        }
    }
    
    private async startServer(serverConfig: any): Promise<void> {
        const process = spawn(serverConfig.command, serverConfig.args);
        
        process.stdout.on('data', (data) => {
            // Handle MCP protocol messages
            this.handleMCPMessage(data.toString());
        });
        
        process.stderr.on('data', (data) => {
            console.error('MCP Error:', data.toString());
        });
    }
    
    private handleMCPMessage(message: string): void {
        try {
            const mcpMessage = JSON.parse(message);
            // Process MCP protocol messages
        } catch (error) {
            console.error('Invalid MCP message:', error);
        }
    }
}
```

## Troubleshooting

### **Common Issues**

1. **Docker Permission Denied**
   ```bash
   # Add user to docker group (Linux)
   sudo usermod -aG docker $USER
   
   # Restart VS Code after change
   ```

2. **Volume Mount Issues**
   ```json
   // Use absolute paths
   "-v", "/full/path/to/prompts:/data:ro"
   
   // Windows paths
   "-v", "C:\\path\\to\\prompts:/data:ro"
   ```

3. **MCP Connection Timeouts**
   ```json
   {
     "mcp.timeout": 60000,
     "mcp.retryAttempts": 3,
     "mcp.retryDelay": 5000
   }
   ```

### **Debug Configuration**

```json
{
  "mcp.debug": true,
  "mcp.logLevel": "debug",
  "mcp.servers": {
    "debug-expert": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "-e", "DEBUG_MODE=true",
        "-e", "LOG_LEVEL=debug",
        "-e", "CLIENT_NAME=vscode-debug",
        "flengure/mcp-prompt-loader:latest"
      ]
    }
  }
}
```

### **Testing Commands**

```bash
# Test Docker image
docker run --rm -i \
  -v "/path/to/prompts:/data:ro" \
  -e "PROMPT_FILE=hummingbot.txt" \
  -e "CLIENT_NAME=vscode-test" \
  flengure/mcp-prompt-loader:latest

# Test VS Code configuration
code --list-extensions | grep mcp

# Validate settings
jq . ~/.config/Code/User/settings.json
```

## Performance Optimization

### **Image Caching**

```json
{
  "mcp.docker": {
    "pullPolicy": "IfNotPresent",
    "enableCache": true,
    "cacheSize": "1GB"
  }
}
```

### **Resource Limits**

```json
{
  "mcp.servers": {
    "optimized-expert": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--memory=256m",
        "--cpus=0.5",
        "--read-only",
        "flengure/mcp-prompt-loader:latest"
      ]
    }
  }
}
```

## Integration with Other Extensions

### **GitHub Copilot Integration**

```json
{
  "github.copilot.enable": {
    "*": true,
    "plaintext": false,
    "mcp": true
  },
  "mcp.enhanceCopilot": true
}
```

### **IntelliCode Integration**

```json
{
  "vsintellicode.mcp.enabled": true,
  "vsintellicode.mcp.defaultExpert": "zed-development-expert"
}
```
