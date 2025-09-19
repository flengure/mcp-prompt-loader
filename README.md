# MCP Prompt Loader

A lightweight [Model Context Protocol (MCP)](https://modelcontextprotocol.io) server that loads a single prompt file and exposes it over stdio to clients like Claude Desktop, Zed, Gemini CLI, Cursor, Windsurf, or via `docker-mcp-gateway`.

---

## Features

- Minimal design: two files (`prompt-server.mjs` + `Dockerfile`)
- Mount any `.txt` prompt file and serve it to an MCP client
- Works with Claude Desktop, Zed, Gemini CLI, Cursor, Windsurf
- Runs in Docker for portability
- Optional version pinning with Docker Hub (`:1.0.0`, `:latest`)

---

## Quick Start

You can run `mcp-prompt-loader` in two ways:

### Option 1 — Run directly from Docker Hub (no build needed)

```bash
docker run --rm -i \
  -v /absolute/path/to/my-prompt.txt:/prompt.txt:ro \
  flengure/mcp-prompt-loader:latest
```

Prefer a fixed version:

```bash
docker run --rm -i \
  -v /absolute/path/to/my-prompt.txt:/prompt.txt:ro \
  flengure/mcp-prompt-loader:1.0.0
```

### Option 2 — Build and run locally

```bash
# Clone the repo
git clone https://github.com/flengure/mcp-prompt-loader.git
cd mcp-prompt-loader

# Build the image
docker build -t mcp-prompt-loader:local .

# Run with your prompt
docker run --rm -i \
  -v /absolute/path/to/my-prompt.txt:/prompt.txt:ro \
  mcp-prompt-loader:local
```

> The container always expects the prompt mounted as `/prompt.txt`.

---

## Example Client Configurations

### Claude Desktop (`claude_desktop_config.json`)

```json
{
  "mcpServers": {
    "hummingbot: Expert": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-v",
        "/Users/tg/Documents/prompts/hummingbot-expert.txt:/prompt.txt:ro",
        "flengure/mcp-prompt-loader:latest"
      ]
    }
  }
}
```

### Zed (`settings.json`)

```json
{
  "context_servers": {
    "hummingbot: Expert": {
      "source": "custom",
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-v",
        "/Users/tg/Documents/prompts/hummingbot-expert.txt:/prompt.txt:ro",
        "flengure/mcp-prompt-loader:latest"
      ]
    }
  }
}
```

### Gemini CLI (`config.json`)

```json
{
  "mcpServers": {
    "hummingbot: Expert": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-v",
        "/Users/tg/Documents/prompts/hummingbot-expert.txt:/prompt.txt:ro",
        "flengure/mcp-prompt-loader:latest"
      ]
    }
  }
}
```

### Cursor (`settings.json`)

```json
{
  "mcpServers": {
    "hummingbot: Expert": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-v",
        "/Users/tg/Documents/prompts/hummingbot-expert.txt:/prompt.txt:ro",
        "flengure/mcp-prompt-loader:latest"
      ]
    }
  }
}
```

### Windsurf (`settings.json`)

```json
{
  "mcpServers": {
    "hummingbot: Expert": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-v",
        "/Users/tg/Documents/prompts/hummingbot-expert.txt:/prompt.txt:ro",
        "flengure/mcp-prompt-loader:latest"
      ]
    }
  }
}
```

---

## License

Apache License 2.0
