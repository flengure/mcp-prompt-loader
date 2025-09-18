# MCP Prompt Loader Examples

Complete examples for using `flengure/mcp-prompt-loader:latest` with various MCP clients and advanced configuration patterns.

## 📁 Directory Structure

```
examples/
├── 📂 clients/                    # Client-specific configurations
│   ├── 📄 claude-desktop.md       # Claude Desktop setup
│   ├── 📄 gemini-code-assist.md   # Google Gemini integration 
│   ├── 📄 zed-editor.md          # Zed editor configuration
│   ├── 📄 vscode.md              # VS Code integration
│   └── 📄 README.md              # Client overview
├── 📄 *-catalog-working.yaml      # Docker MCP Gateway catalogs
├── 📄 mounting-guide.md           # Volume mounting strategies
├── 📄 mounting-strategies.yaml    # Alternative mounting examples
└── 📄 enhanced-run.sh            # Advanced container script
```

## 🎯 **Quick Start by Client**

| Client | Guide | Configuration |  
|--------|-------|---------------||
| **Claude Desktop** | [📖 Guide](clients/claude-desktop.md) | `claude_desktop_config.json` |
| **Gemini Code Assist** | [📖 Guide](clients/gemini-code-assist.md) | `.gemini-mcp-config.json` |
| **Zed Editor** | [📖 Guide](clients/zed-editor.md) | `~/.config/zed/settings.json` |
| **VS Code** | [📖 Guide](clients/vscode.md) | `.vscode/settings.json` |
| **Docker MCP Gateway** | [📖 Catalogs](#docker-mcp-gateway-catalogs) | `catalog.yaml` |

## 🐳 **Docker MCP Gateway Catalogs**

### Working Catalog Files

- `hummingbot-catalog-working.yaml` - Hummingbot trading expert configuration
- `n8n-catalog-working.yaml` - n8n workflow automation expert configuration  
- `personal-catalog-working.yaml` - MCP Gateway and Zed editor experts configuration

## Key Features Demonstrated

### ✅ **Docker Hub Integration**
```yaml
image: flengure/mcp-prompt-loader:latest
```

### ✅ **Configuration Schema with Validation**
```yaml
config:
  - name: tool-name
    description: "Configure the AI expert"
    type: object
    properties:
      prompt_file:
        type: string
        description: "The prompt file to load"
        default: "expert.txt"
    required:
      - prompt_file
```

### ✅ **Environment Variable Templating**
```yaml
env:
  - name: PROMPT_FILE
    value: '{{tool-name.prompt_file}}'
```

### ✅ **Rich Metadata**
```yaml
metadata:
  category: "ai-expert"
  tags: ["trading", "ai-expert"]
  license: "Apache License 2.0"
```

## Usage

These examples show how to create production-ready MCP catalog entries that:
- Use your Docker Hub image instead of local builds
- Support advanced configuration with validation
- Provide rich UI experiences in MCP Gateway
- Follow official Docker MCP catalog patterns

Copy and modify these patterns for your own expert prompts!
