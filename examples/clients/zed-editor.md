# Zed Editor MCP Configuration

Configure Zed editor to use specialized AI experts through the Model Context Protocol.

## Configuration Location

**macOS**: `~/.config/zed/settings.json`
**Linux**: `~/.config/zed/settings.json`  
**Windows**: `%APPDATA%\Zed\settings.json`

## Basic Configuration

```json
{
  "assistant": {
    "version": "2",
    "provider": {
      "name": "mcp",
      "servers": {
        "hummingbot-expert": {
          "command": "docker",
          "args": [
            "run", "--rm", "-i",
            "--pull=always",
            "-v", "/path/to/prompts:/data:ro",
            "-e", "PROMPT_FILE=hummingbot.txt",
            "-e", "PROMPT_BASE_DIR=/data",
            "-e", "CLIENT_NAME=zed-editor",
            "flengure/mcp-prompt-loader:latest"
          ]
        },
        "n8n-expert": {
          "command": "docker",
          "args": [
            "run", "--rm", "-i",
            "--pull=always",
            "-v", "/path/to/prompts:/data:ro",
            "-e", "PROMPT_FILE=n8n.txt", 
            "-e", "PROMPT_BASE_DIR=/data",
            "-e", "CLIENT_NAME=zed-editor",
            "flengure/mcp-prompt-loader:latest"
          ]
        },
        "development-expert": {
          "command": "docker",
          "args": [
            "run", "--rm", "-i",
            "--pull=always",
            "-v", "/path/to/prompts:/data:ro",
            "-e", "PROMPT_FILE=zed.txt",
            "-e", "PROMPT_BASE_DIR=/data", 
            "-e", "CLIENT_NAME=zed-editor",
            "flengure/mcp-prompt-loader:latest"
          ]
        },
        "mcp-gateway-expert": {
          "command": "docker",
          "args": [
            "run", "--rm", "-i",
            "--pull=always", 
            "-v", "/path/to/prompts:/data:ro",
            "-e", "PROMPT_FILE=mcp-gateway.txt",
            "-e", "PROMPT_BASE_DIR=/data",
            "-e", "CLIENT_NAME=zed-editor", 
            "flengure/mcp-prompt-loader:latest"
          ]
        }
      }
    }
  }
}
```

## Advanced Configuration with Workspace Support

```json
{
  "assistant": {
    "version": "2",
    "provider": {
      "name": "mcp",
      "servers": {
        "context-aware-expert": {
          "command": "docker",
          "args": [
            "run", "--rm", "-i",
            "--pull=always",
            "-v", "${ZED_WORKTREE_ROOT}/prompts:/data:ro",
            "-v", "${ZED_WORKTREE_ROOT}:/workspace:ro",
            "-e", "PROMPT_FILE=${ZED_EXPERT_PROMPT:-zed.txt}",
            "-e", "PROMPT_BASE_DIR=/data",
            "-e", "WORKSPACE_DIR=/workspace",
            "-e", "CLIENT_NAME=zed-editor",
            "-e", "ZED_BUFFER_PATH=${ZED_BUFFER_PATH:-}",
            "-e", "ZED_LANGUAGE=${ZED_LANGUAGE:-}",
            "flengure/mcp-prompt-loader:latest"
          ],
          "env": {
            "ZED_EXPERT_PROMPT": "zed.txt"
          }
        }
      }
    }
  },
  "languages": {
    "Python": {
      "assistant": {
        "expert": "development-expert"
      }
    },
    "JavaScript": {
      "assistant": {
        "expert": "development-expert"
      }
    },
    "TypeScript": {
      "assistant": {
        "expert": "development-expert"
      }
    }
  }
}
```

## Project-Specific Configuration

Create a `.zed/settings.json` in your project root:

```json
{
  "assistant": {
    "provider": {
      "servers": {
        "project-expert": {
          "command": "docker",
          "args": [
            "run", "--rm", "-i",
            "--pull=always",
            "-v", "./prompts:/data:ro",
            "-e", "PROMPT_FILE=project-specific.txt",
            "-e", "PROMPT_BASE_DIR=/data",
            "-e", "CLIENT_NAME=zed-project",
            "flengure/mcp-prompt-loader:latest"
          ]
        }
      }
    }
  }
}
```

## Environment Variables

Zed-specific environment variables supported:

```bash
# Zed editor integration
CLIENT_NAME=zed-editor
ZED_BUFFER_PATH=/path/to/current/file
ZED_LANGUAGE=rust
ZED_WORKTREE_ROOT=/path/to/project

# Expert selection
ZED_EXPERT_PROMPT=zed.txt
EXPERT_DOMAIN=development

# Workspace context
WORKSPACE_DIR=/workspace
PROJECT_TYPE=rust

# Editor context
CURRENT_FILE_TYPE=rs
SELECTION_START=100
SELECTION_END=200
```

## Keybindings

Add custom keybindings in `~/.config/zed/keymap.json`:

```json
[
  {
    "context": "Editor",
    "bindings": {
      "cmd-shift-h": "assistant::ToggleExpert hummingbot-expert",
      "cmd-shift-n": "assistant::ToggleExpert n8n-expert", 
      "cmd-shift-d": "assistant::ToggleExpert development-expert",
      "cmd-shift-m": "assistant::ToggleExpert mcp-gateway-expert"
    }
  }
]
```

## Usage Patterns

### **1. Code Assistance**
- **Select code** → Ask for improvements
- **Right-click** → "Ask Expert" 
- **Cmd+Shift+A** → Open assistant panel

### **2. Expert Switching**
```bash
# Trading code assistance
Cmd+Shift+H → Switch to Hummingbot expert

# Workflow automation  
Cmd+Shift+N → Switch to n8n expert

# General development
Cmd+Shift+D → Switch to development expert
```

### **3. Context-Aware Help**
The expert automatically receives:
- Current file content
- Selected text
- Language context
- Project structure

## Integration with Zed Extensions

### **Custom Extension Configuration**

Create `~/.config/zed/extensions/prompt-loader/extension.toml`:

```toml
[extension]
id = "prompt-loader"
name = "AI Expert Prompt Loader"
description = "Specialized AI experts for different domains"
version = "1.0.0"
authors = ["Your Name"]

[mcp]
servers = [
  { name = "hummingbot-expert", command = "docker", args = ["run", "--rm", "-i", "..."] },
  { name = "n8n-expert", command = "docker", args = ["run", "--rm", "-i", "..."] }
]
```

## Docker Desktop Integration

For seamless Docker integration, ensure Docker Desktop is configured:

```json
{
  "docker": {
    "autoStart": true,
    "pullPolicy": "always",
    "securityOpts": ["no-new-privileges:true"],
    "readOnlyRootFilesystem": true
  }
}
```

## Troubleshooting

### **Common Issues**

1. **Docker not accessible**: Ensure Docker Desktop is running
2. **Volume mount failures**: Check file permissions and paths
3. **Slow startup**: Use local image caching
4. **Memory issues**: Increase Docker memory limits

### **Debug Configuration**

```json
{
  "assistant": {
    "debug": true,
    "logLevel": "debug",
    "provider": {
      "servers": {
        "debug-expert": {
          "command": "docker",
          "args": [
            "run", "--rm", "-i",
            "-e", "DEBUG_MODE=true",
            "-e", "LOG_LEVEL=debug",
            "flengure/mcp-prompt-loader:latest"
          ]
        }
      }
    }
  }
}
```

### **Performance Optimization**

```json
{
  "assistant": {
    "provider": {
      "servers": {
        "optimized-expert": {
          "command": "docker",
          "args": [
            "run", "--rm", "-i",
            "--memory=256m",
            "--cpus=0.5",
            "--read-only",
            "-v", "/path/to/prompts:/data:ro",
            "flengure/mcp-prompt-loader:latest"
          ]
        }
      }
    }
  }
}
```

## Testing

Test your configuration:

```bash
# Test Docker image directly
docker run --rm -i \
  -v "/path/to/prompts:/data:ro" \
  -e "PROMPT_FILE=zed.txt" \
  -e "CLIENT_NAME=zed-test" \
  flengure/mcp-prompt-loader:latest

# Validate Zed configuration
zed --validate-config ~/.config/zed/settings.json
```
