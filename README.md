# MCP Prompt Loader (Folder Mode)

A minimal Model Context Protocol (MCP) server that serves **multiple prompt files** from a **mounted folder**.
Version **2.0.0-dev**: folder-based only, single container, multiple prompts.

---

## Quick Start

1) Put your prompts in a folder (each prompt is a `.txt` file):

```
~/Documents/prompts/
├── writer.txt
├── researcher.txt
└── hummingbot-expert.txt
```

2) Run the server with Docker (no env var needed — path is hard-coded to `/prompts` inside the container):

```bash
docker build -t flengure/mcp-prompt-loader:2.0.0-dev .
docker run --rm -i \
  -v ~/Documents/prompts:/prompts:ro \
  flengure/mcp-prompt-loader:2.0.0-dev
```

> The client can now **list** and **load** prompts dynamically.

---

## MCP Clients (ready-to-paste)

### Claude Desktop — `claude_desktop_config.json`
```json
{
  "mcpServers": {
    "prompts: Folder": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run","--rm","-i",
        "-v","/Users/tg/Documents/prompts:/prompts:ro",
        "flengure/mcp-prompt-loader:2.0.0-dev"
      ]
    }
  }
}
```

### Zed — `settings.json`
```json
{
  "context_servers": {
    "prompts: Folder": {
      "source": "custom",
      "command": "docker",
      "args": [
        "run","--rm","-i",
        "-v","/Users/tg/Documents/prompts:/prompts:ro",
        "flengure/mcp-prompt-loader:2.0.0-dev"
      ]
    }
  }
}
```

### Gemini CLI / Cursor / Windsurf — same structure
```json
{
  "mcpServers": {
    "prompts: Folder": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run","--rm","-i",
        "-v","/Users/tg/Documents/prompts:/prompts:ro",
        "flengure/mcp-prompt-loader:2.0.0-dev"
      ]
    }
  }
}
```

> The object key (`"prompts: Folder"`) is just a **label**. Name it however you like (e.g., `"Experts: Writing"`).

---

## What the client can call

### Native MCP methods
- `prompts/list` → returns all prompt names (without `.txt`)
- `prompts/get` with `{ "name": "<promptName>" }` → returns a system message containing the file

### Tool interface (for UIs that prefer tools)
- `tools/list` → exposes two tools:
  - `list_prompts`
  - `get_prompt_by_name`
- `tools/call`:
  - `list_prompts` → returns JSON array of names
  - `get_prompt_by_name` with `{ "name": "<promptName>" }` → returns raw text

---

## Sample Exchange

List:
```json
{ "jsonrpc": "2.0", "id": 1, "method": "prompts/list" }
```

Response:
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "prompts": [
      { "name": "hummingbot-expert", "description": "Loaded from /prompts/hummingbot-expert.txt", "arguments": [] },
      { "name": "researcher", "description": "Loaded from /prompts/researcher.txt", "arguments": [] },
      { "name": "writer", "description": "Loaded from /prompts/writer.txt", "arguments": [] }
    ]
  }
}
```

Get:
```json
{ "jsonrpc": "2.0", "id": 2, "method": "prompts/get", "params": { "name": "writer" } }
```

---

## Development

Build and run locally:
```bash
docker build -t mcp-prompt-loader:dev .
docker run --rm -i \
  -v $(pwd)/prompts:/prompts:ro \
  mcp-prompt-loader:dev
```

Notes:
- Mount path inside container is **always** `/prompts` (hard-coded for safety).
- Filenames must match `[a-zA-Z0-9._-]+` and end with `.txt`.
- Max file size: **512 KB** (adjust in code if needed).
- SIGHUP is accepted (no-op; folder mode reads on demand).

---

## Changelog
- **2.0.0-dev** — Folder-mode only; adds `list_prompts` tool; no `PROMPT_DIR` env; safer filenames; unified workflows.
