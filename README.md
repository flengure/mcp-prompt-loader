# MCP Prompt Loader

A simple Model Context Protocol (MCP) server that serves prompt files from a mounted folder.
Version 2.0.0-dev introduces folder-based loading only.

---

## Quick Start

1. Put your prompt files (.txt) in a folder, e.g.:

~/Documents/prompts/
├── hummingbot-expert.txt
├── binance-expert.txt
└── dydx-expert.txt

2. Run the server with Docker:

docker run --rm -i \
  -v ~/Documents/prompts:/prompts:ro \
  -e PROMPT_DIR=/prompts \
  flengure/mcp-prompt-loader:2.0.0-dev

The server exposes MCP stdio. Clients can call `prompts/list` then `prompts/get` (or `tools/call` with `get_prompt_by_name`).

---

## Example Client Configs

### Claude Desktop (claude_desktop_config.json)

{
  "mcpServers": {
    "prompts: Folder": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-v",
        "/Users/tg/Documents/prompts:/prompts:ro",
        "-e",
        "PROMPT_DIR=/prompts",
        "flengure/mcp-prompt-loader:2.0.0-dev"
      ]
    }
  }
}

### Zed (settings.json)

{
  "context_servers": {
    "prompts: Folder": {
      "source": "custom",
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-v",
        "/Users/tg/Documents/prompts:/prompts:ro",
        "-e",
        "PROMPT_DIR=/prompts",
        "flengure/mcp-prompt-loader:2.0.0-dev"
      ]
    }
  }
}

---

## Supported Methods

- initialize → MCP handshake
- prompts/list → returns names of .txt in PROMPT_DIR
- prompts/get → returns a system message block with the selected file
- tools/list / tools/call(get_prompt_by_name) → optional text fetch path

---

## Dev / Test

docker build -t mcp-prompt-loader:dev .
docker run --rm -i \
  -v $(pwd)/prompts:/prompts:ro \
  -e PROMPT_DIR=/prompts \
  mcp-prompt-loader:dev
