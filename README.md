# MCP Prompt Loader

A simple, flexible tool for loading any local text file as a system prompt for an AI session.  
**Available on Docker Hub:** [`flengure/mcp-prompt-loader:latest`](https://hub.docker.com/r/flengure/mcp-prompt-loader)

## 🚀 Quick Start

### Using the Docker Image

```bash
./build.sh
docker run --rm -v "/path/to/your/prompts:/data:ro" -e PROMPT_FILE=my-prompt.txt mcp-prompt-loader:latest
```

### Docker MCP Gateway Catalog Entry

```yaml
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

## 📚 Examples

See the `examples/` directory for more configuration samples.

## 🤝 Usage

Perfect for:
- AI Expert Systems
- Development Workflows
- Team Sharing
- Multi-Modal AI

---

**Maintainers:**  
For build, test, and deployment instructions, see [docs/MAINTAINERS.md](docs/MAINTAINERS.md).