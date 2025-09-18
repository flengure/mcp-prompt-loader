# MCP Prompt Loader - Production Ready

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/your-org/mcp-prompt-loader)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-ready-blue.svg)](Dockerfile.production)

A **production-ready**, **universal prompt loader** for MCP (Model Context Protocol) AI expert systems. This tool provides a secure, configurable way to load text-based AI expert prompts through the MCP Gateway with comprehensive UI integration.

## 🌟 Features

### **Production Quality**
- ✅ **Security First**: Non-root container, read-only mounts, path validation
- ✅ **Comprehensive Logging**: Structured logging with configurable levels
- ✅ **Health Checks**: Built-in health monitoring and validation
- ✅ **Error Handling**: Robust error handling with helpful diagnostics
- ✅ **Input Validation**: File type, content, and security validation

### **UI Integration**
- 🎛️ **Interactive Configuration**: Rich UI forms in MCP Gateway
- 📋 **Dropdown Selections**: Pre-configured expert types
- 🔧 **Advanced Options**: Collapsible advanced settings
- 💡 **Contextual Help**: Comprehensive help text and examples
- ✨ **Field Validation**: Real-time input validation

### **Expert Systems**
- 🤖 **Hummingbot Expert**: Algorithmic trading guidance and strategy development
- ⚡ **n8n Expert**: Workflow automation with 535+ nodes
- 🖥️ **Zed Expert**: Modern code editor configuration and usage
- 🛠️ **MCP Gateway Expert**: Service orchestration and tool integration
- 🎯 **Custom Experts**: Easy creation of domain-specific AI assistants

## 🚀 Quick Start

### **1. Deploy via MCP Gateway UI**

1. **Open MCP Gateway**: Navigate to your Docker Desktop MCP Toolkit
2. **Add Server**: Click "Add a server" 
3. **Select Catalog**: Choose from available catalogs (hummingbot, n8n, personal)
4. **Configure Expert**: Select prompt file and configure options
5. **Deploy**: Click "Add Server" to start your AI expert

### **2. Command Line Deployment**

```bash
# Clone the repository
git clone https://github.com/your-org/mcp-prompt-loader.git
cd mcp-prompt-loader

# Build production container
docker build -f Dockerfile.production -t mcp-prompt-loader:production .

# Run with Hummingbot expert
docker run --rm \
  -v "$(pwd):/data:ro" \
  -e PROMPT_FILE="hummingbot.txt" \
  mcp-prompt-loader:production

# Run with custom prompt
docker run --rm \
  -v "/path/to/your/prompts:/data:ro" \
  -e PROMPT_FILE="custom-expert.txt" \
  -e DEBUG_MODE="true" \
  mcp-prompt-loader:production
```

## 📁 Project Structure

```
mcp-prompt-loader/
├── 📄 README-PRODUCTION.md          # This file
├── 🐳 Dockerfile.production         # Production container
├── 🔧 run-production.sh            # Enhanced script with validation
├── 📂 docs/
│   ├── 📋 *-catalog-production.yaml    # Production-ready catalogs (now in docs/)
│   ├── PRODUCTION-OVERVIEW.md
│   └── MAINTAINERS.md
├── 📝 *.txt                        # Expert prompt files
├── 🏗️ Dockerfile                   # Original simple container
├── ⚙️ run.sh                       # Original simple script
└── 📋 *-catalog.yaml              # Original catalogs
```

## 🎛️ Configuration Options

### **UI Parameters**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `promptFile` | string | Expert prompt file to load | `{expert}.txt` |
| `workflowComplexity` | select | Target complexity level | `intermediate` |
| `enableDetailedHelp` | boolean | Comprehensive explanations | `true` |
| `baseDir` | string | Container mount directory | `/data` |

### **Environment Variables**

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `PROMPT_FILE` | Prompt file path (required) | - | `hummingbot.txt` |
| `PROMPT_BASE_DIR` | Base directory for files | `/data` | `/data` |
| `DEBUG_MODE` | Enable debug logging | `false` | `true` |
| `LOG_LEVEL` | Logging verbosity | `info` | `error` |

### **Volume Mounts**

```yaml
volumes:
  - source: "/path/to/prompts"    # Host directory
    target: "/data"               # Container directory  
    mode: "ro"                   # Read-only for security
```

## 🧠 Available Expert Prompts

### **Hummingbot Trading Expert**
```yaml
promptFile: "hummingbot.txt"        # General trading guidance
promptFile: "hummingbot-beginner.txt"  # Beginner-friendly
promptFile: "hummingbot-advanced.txt"  # Advanced strategies
promptFile: "risk-management.txt"      # Risk-focused expert
```

### **n8n Workflow Expert**
```yaml
promptFile: "n8n.txt"               # General automation
promptFile: "n8n-beginner.txt"      # Simple workflows
promptFile: "n8n-advanced.txt"      # Complex automation
promptFile: "n8n-ai-workflows.txt"  # AI integrations
promptFile: "n8n-enterprise.txt"    # Enterprise patterns
```

### **Development Experts**
```yaml
promptFile: "zed.txt"               # Zed editor expert
promptFile: "mcp-gateway.txt"       # MCP Gateway expert
```

## 🔧 Creating Custom Experts

### **1. Create Prompt File**

```bash
# Create new expert prompt
cat > custom-expert.txt << 'EOF'
### **System Prompt: The [Domain] Expert & Educator**

**Core Identity:**
You are the [Domain] Expert and Educator, specialized in [specific area].

**Primary Mission:**
Provide data-driven, real-time expertise while delivering personalized education.

**Your Tools:**
- Tool references and capabilities
- Integration points

**Guiding Principles:**
- Tool-first approach
- Connect to reality
- Adapt complexity
- Promote safety
- Interactive mentoring
EOF
```

### **2. Add to Catalog**

```yaml
your-custom-expert:
  title: "Custom Domain Expert"
  description: "Specialized expert for your domain"
  type: "server"
  build:
    context: /path/to/mcp-prompt-loader
    dockerfile: Dockerfile.production
  parameters:
    promptFile:
      type: string
      default: "custom-expert.txt"
      options:
        - value: "custom-expert.txt"
          label: "Standard Expert"
        - value: "custom-advanced.txt"
          label: "Advanced Expert"
  environment:
    - name: PROMPT_FILE
      value: "{{ .promptFile }}"
  volumes:
    - "/path/to/prompts:/data:ro"
```

### **3. Deploy Custom Expert**

1. Place prompt file in mounted directory
2. Update catalog configuration
3. Restart MCP Gateway
4. Select custom expert in UI

## 🔒 Security Features

### **Container Security**
- ✅ **Non-root execution**: Runs as user `promptloader` (UID 1000)
- ✅ **Read-only filesystem**: Prompt files mounted read-only
- ✅ **Minimal attack surface**: Alpine base with minimal packages
- ✅ **Path traversal protection**: Validates files are within base directory

### **Input Validation**
```bash
# File validation checks
✅ File exists and is readable
✅ File is not empty
✅ File is within allowed directory
✅ File type validation (text files only)
✅ Path traversal prevention
```

### **Runtime Security**
```yaml
# Security configurations
user: "1000:1000"                 # Non-root user
read_only: true                   # Read-only root filesystem
security_opt:
  - "no-new-privileges:true"      # Prevent privilege escalation
cap_drop:
  - "ALL"                         # Drop all capabilities
```

## 📊 Monitoring & Observability

### **Health Checks**
```yaml
healthcheck:
  test: ["CMD", "/usr/local/bin/run-production.sh", "--health"]
  interval: "30s"
  timeout: "10s" 
  retries: 3
  start_period: "5s"
```

### **Logging Levels**
```bash
# Error level (production default)
LOG_LEVEL=error    # Errors only

# Info level (development)
LOG_LEVEL=info     # Info + errors

# Debug level (troubleshooting)
DEBUG_MODE=true    # All logs + debug info
```

### **Log Format**
```
[LEVEL] YYYY-MM-DD HH:MM:SS - Message
[INFO] 2024-01-15 10:30:45 - Loading prompt file: hummingbot.txt (2547 bytes, 89 lines)
[DEBUG] 2024-01-15 10:30:45 - Security check passed: File is within base directory
```

## 🔧 Troubleshooting

### **Common Issues**

| Issue | Symptoms | Solution |
|-------|----------|----------|
| Prompt file not found | `Error: Prompt file not found` | Check file path and volume mount |
| Permission denied | `Error: not readable` | Verify file permissions and container user |
| Empty response | No output from container | Check file content and encoding |
| Security violation | `Security violation: outside base` | Ensure file is within mounted directory |

### **Debug Mode**
```bash
# Enable debug logging
docker run --rm \
  -v "$(pwd):/data:ro" \
  -e PROMPT_FILE="hummingbot.txt" \
  -e DEBUG_MODE="true" \
  mcp-prompt-loader:production
```

### **Health Check**
```bash
# Manual health check
docker run --rm \
  -v "$(pwd):/data:ro" \
  -e PROMPT_FILE="hummingbot.txt" \
  mcp-prompt-loader:production --health
```

### **File Listing**
```bash
# List available prompt files
docker run --rm \
  -v "$(pwd):/data:ro" \
  alpine:3.19 ls -la /data/*.txt
```

## 🚀 Production Deployment

### **Docker Compose**
```yaml
version: '3.8'
services:
  hummingbot-expert:
    build:
      context: .
      dockerfile: Dockerfile.production
    environment:
      - PROMPT_FILE=hummingbot.txt
      - LOG_LEVEL=error
    volumes:
      - ./prompts:/data:ro
    healthcheck:
      test: ["CMD", "/usr/local/bin/run-production.sh", "--health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    read_only: true
    user: "1000:1000"
```

### **Kubernetes Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mcp-prompt-loader
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mcp-prompt-loader
  template:
    metadata:
      labels:
        app: mcp-prompt-loader
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
      containers:
      - name: prompt-loader
        image: mcp-prompt-loader:production
        env:
        - name: PROMPT_FILE
          value: "hummingbot.txt"
        - name: LOG_LEVEL
          value: "error"
        volumeMounts:
        - name: prompts
          mountPath: /data
          readOnly: true
        livenessProbe:
          exec:
            command:
            - /usr/local/bin/run-production.sh
            - --health
          initialDelaySeconds: 10
          periodSeconds: 30
        readinessProbe:
          exec:
            command:
            - /usr/local/bin/run-production.sh
            - --health
          initialDelaySeconds: 5
          periodSeconds: 10
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
      volumes:
      - name: prompts
        configMap:
          name: expert-prompts
```

## 📚 API Reference

### **Script Commands**
```bash
run-production.sh [OPTIONS]

OPTIONS:
  --health      Perform health check and exit
  --version     Show version information
  --help        Show usage information
```

### **Exit Codes**
| Code | Meaning | Description |
|------|---------|-------------|
| 0 | Success | Prompt loaded successfully |
| 1 | Error | General error (file not found, permissions, etc.) |
| 2 | Invalid Input | Invalid command line arguments |

### **Environment Variables Reference**
```bash
# Required
PROMPT_FILE="filename.txt"          # Prompt file to load

# Optional  
PROMPT_BASE_DIR="/data"             # Base directory
DEBUG_MODE="false"                  # Debug logging
LOG_LEVEL="info"                    # Logging level
```

## 🤝 Contributing

### **Adding New Experts**
1. Create expert prompt file following the template
2. Add configuration to appropriate catalog
3. Test with both UI and CLI deployment
4. Update documentation

### **Template Structure**
```
### **System Prompt: The [Domain] Expert & Educator**

**Core Identity:**
[Define the expert's role and specialization]

**Primary Mission:**
[Describe the main purpose and goals]

**Your Tools:**
[List available tools and capabilities]

**Guiding Principles:**
- Tool-first approach
- Connect to reality  
- Adapt complexity
- Promote safety
- Interactive mentoring
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🔗 Related Projects

- [MCP Gateway](https://github.com/docker/mcp-gateway) - Container orchestration for MCP
- [Hummingbot](https://github.com/hummingbot/hummingbot) - Algorithmic trading platform
- [n8n](https://github.com/n8n-io/n8n) - Workflow automation platform
- [Zed](https://github.com/zed-industries/zed) - Modern code editor

## 📞 Support

- **Documentation**: [docs.example.com](https://docs.example.com)
- **Issues**: [GitHub Issues](https://github.com/your-org/mcp-prompt-loader/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/mcp-prompt-loader/discussions)
- **Community**: [Discord Server](https://discord.gg/mcp-community)

---

**Made with ❤️ for the MCP Community**