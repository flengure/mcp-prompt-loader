# Generic Prompt Loader MCP Tool

A flexible, reusable MCP Gateway tool for loading any local text file as a system prompt for an AI session. **Now available on Docker Hub!**

## 🚀 **Production Ready**

This tool is production-ready and deployed to Docker Hub as `flengure/mcp-prompt-loader:latest` with:
- ✅ **Security**: Non-root execution, read-only mounts, input validation
- ✅ **Rich Configuration**: Full MCP Gateway parameter support with validation
- ✅ **Health Monitoring**: Container health checks and comprehensive error handling
- ✅ **Documentation**: Complete examples and troubleshooting guides

## 🎯 **Quick Start**

### **Using the Docker Hub Image**

```yaml
# In your MCP catalog.yaml
my-expert:
  title: "My AI Expert"
  type: "server"
  image: flengure/mcp-prompt-loader:latest
  
  env:
    - name: PROMPT_FILE
      value: '{{my-expert.prompt_file}}'
  
  volumes:
    - "/path/to/your/prompts:/data:ro"
  
  config:
    - name: my-expert
      type: object
      properties:
        prompt_file:
          type: string
          default: "my-prompt.txt"
```

### **Local Development**

```bash
# Clone and build locally
git clone [this-repo]
cd mcp-prompt-loader

# Build production image
./deploy-production.sh build --tag latest

# Run comprehensive tests
./deploy-production.sh test
```

## 📁 **Project Structure**

```
├── 📄 Dockerfile.production        # Production container
├── 📄 run-production.sh           # Production script with validation
├── 📄 deploy-production.sh        # Automated deployment & testing
├── 📄 README-PRODUCTION.md        # Detailed production docs
├── 📄 PRODUCTION-OVERVIEW.md      # Feature overview
├── 📂 examples/                   # Working catalog examples
│   ├── 📄 README.md              # Example documentation
│   ├── 📄 *-catalog-working.yaml # Production catalog configs
│   └── 📄 mounting-*.yaml        # Volume mounting strategies
└── 📂 expert-prompts/
    ├── 📄 hummingbot.txt          # Trading automation expert
    ├── 📄 n8n.txt                 # Workflow automation expert
    ├── 📄 zed.txt                 # Code editor expert
    └── 📄 mcp-gateway.txt         # MCP development expert
```

## 🎯 **Core Concept**

The tool is a minimal, generic container that loads text-based AI expert prompts:

1. **Container**: Generic Docker image that reads environment variables
2. **Configuration**: MCP Gateway catalog defines which prompt to load
3. **Experts**: Text files containing specialized AI system prompts

### **How it Works**

1. **MCP Gateway** reads your catalog configuration
2. **Docker** pulls `flengure/mcp-prompt-loader:latest` 
3. **Environment** variables specify which prompt file to load
4. **Volume** mounts your prompt directory as `/data` (read-only)
5. **Script** validates and outputs the prompt content

## 🔧 **Configuration Features**

### **Rich Parameter Support**
```yaml
config:
  - name: tool-name
    description: "Configure the AI expert"
    type: object
    properties:
      prompt_file:
        type: string
        description: "Prompt file to load"
        default: "expert.txt"
      debug_mode:
        type: string
        description: "Enable debug logging"
        default: "false"
    required:
      - prompt_file
```

### **Environment Templating**
```yaml
env:
  - name: PROMPT_FILE
    value: '{{tool-name.prompt_file}}'
  - name: DEBUG_MODE
    value: '{{tool-name.debug_mode}}'
```

### **Rich Metadata**
```yaml
metadata:
  category: "ai-expert"
  tags: ["trading", "automation"]
  license: "Apache License 2.0"
```

## 📚 **Included Expert Prompts**

- **🤖 Hummingbot Expert**: Algorithmic trading strategy development
- **⚡ n8n Expert**: Workflow automation and integration
- **✏️ Zed Expert**: Code editor configuration and usage  
- **🔗 MCP Gateway Expert**: MCP tool development and deployment

## 🧪 **Examples**

See the `examples/` directory for comprehensive configuration examples:

### **🎯 By Client**
- **[Claude Desktop](examples/clients/claude-desktop.md)** - Anthropic's desktop app
- **[Gemini Code Assist](examples/clients/gemini-code-assist.md)** - Google's AI integration
- **[Zed Editor](examples/clients/zed-editor.md)** - Modern code editor
- **[VS Code](examples/clients/vscode.md)** - Visual Studio Code extension
- **[Docker MCP Gateway](examples/)** - Docker's official gateway

### **🔧 Advanced Patterns**
- **Working catalog configurations** for Docker MCP Gateway
- **Volume mounting strategies** (directory vs file mounting)
- **Multi-client setups** and expert switching
- **Performance optimization** and troubleshooting

## 🚀 **Production Deployment**

```bash
# Validate everything
./deploy-production.sh validate

# Build and test
./deploy-production.sh all --registry your-registry

# Push to registry
./deploy-production.sh build --push --registry your-registry
```

## 📖 **Documentation**

- **[Production Guide](README-PRODUCTION.md)**: Complete production deployment
- **[Feature Overview](PRODUCTION-OVERVIEW.md)**: All production features
- **[Examples](examples/README.md)**: Working configuration examples

## 🤝 **Usage**

Perfect for:
- **AI Expert Systems**: Specialized domain knowledge prompts
- **Development Workflows**: Different experts for different projects
- **Team Sharing**: Standardized expert prompts across teams
- **Multi-Modal AI**: Switch experts based on task context

## 📊 **Production Quality**

- ✅ **Security**: Non-root execution, path validation, read-only mounts
- ✅ **Reliability**: Health checks, comprehensive error handling
- ✅ **Performance**: Minimal resource usage, fast startup
- ✅ **Monitoring**: Structured logging, metrics endpoints
- ✅ **Documentation**: Complete guides and troubleshooting

## 🏷️ **Docker Hub**

Available at: **[flengure/mcp-prompt-loader](https://hub.docker.com/r/flengure/mcp-prompt-loader)**

```bash
docker pull flengure/mcp-prompt-loader:latest
```

---

**Built with ❤️ for the MCP community**
