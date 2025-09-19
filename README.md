# MCP Prompt Loader

[![Docker Pulls](https://img.shields.io/docker/pulls/flengure/mcp-prompt-loader)](https://hub.docker.com/r/flengure/mcp-prompt-loader)
[![Image Size](https://img.shields.io/docker/image-size/flengure/mcp-prompt-loader/latest)](https://hub.docker.com/r/flengure/mcp-prompt-loader)
[![GitHub Stars](https://img.shields.io/github/stars/flengure/mcp-prompt-loader?style=social)](https://github.com/flengure/mcp-prompt-loader)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A lightweight Model Context Protocol (MCP) server that loads system prompts from plain text files.
Works with Claude Desktop, Zed, Gemini CLI, Cursor, Windsurf, and via docker-mcp-gateway.

---

## Features

- **Folder mode** — mount a directory of `.txt` files, instantly exposed as prompts.
- **No rebuilds** — add or edit `.txt` files and they show up immediately.
- **Cross-client** — tested with Claude Desktop, Zed, Gemini CLI, Cursor, Windsurf.
- **Dockerized** — runs as a simple container, no Node/npm setup needed.
- **Multi-arch** — published for both `amd64` and `arm64`.

---

## Usage

### 1. Prepare a prompts folder

```bash
mkdir ~/Documents/prompts
echo "You are a helpful writing assistant." > ~/Documents/prompts/writer.txt
echo "You are a research copilot." > ~/Documents/prompts/researcher.txt
```

### 2. Run with Docker

```bash
docker run --rm -i   -v ~/Documents/prompts:/prompts:ro   flengure/mcp-prompt-loader:latest
```

---

## Tools

### `prompts/list`
Lists all `.txt` files in `/prompts` and exposes them by name (filename without `.txt`).

Example result:
- writer
- researcher
- teacher

### `prompts/get`
Returns the full text of a specific prompt by name (without `.txt`).

Input:
- `name` (string) — e.g. `writer`, not `writer.txt`

Behavior:
- Reads the file fresh on every call (no restart needed).

---

> 💡 **Tip:** First run `prompts/list` in your MCP client to see what’s available.
> Then call `prompts/get` with the name (without `.txt`) to load it.

---

## Example MCP Configurations

<details>
<summary>Claude Desktop</summary>

```json
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
        "/Users/you/Documents/prompts:/prompts:ro",
        "flengure/mcp-prompt-loader:latest"
      ]
    }
  }
}
```
</details>

<details>
<summary>Zed Editor</summary>

```json
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
        "/Users/you/Documents/prompts:/prompts:ro",
        "flengure/mcp-prompt-loader:latest"
      ]
    }
  }
}
```
</details>

<details>
<summary>Gemini CLI</summary>

```json
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
        "/Users/you/Documents/prompts:/prompts:ro",
        "flengure/mcp-prompt-loader:latest"
      ]
    }
  }
}
```
</details>

---

## Troubleshooting

- **I don’t see my new prompt file.**
  `prompts/list` rescans the folder each time, and `prompts/get` re-reads on demand.
  Make sure the file ends in `.txt` and is inside the mounted folder (default `/prompts`).

- **Permission denied or file not found.**
  Check your `-v` mount path is correct and readable. Example:
  `-v /Users/you/Documents/prompts:/prompts:ro`

- **Windows path mapping (Docker Desktop).**
  Use a path like: `-v //c/Users/you/Documents/prompts:/prompts:ro`
  Ensure Docker Desktop has access to that drive.

- **Client shows multiple tools but I can’t select a prompt.**
  Most clients list tools like commands. Run `prompts/list`, then choose a name and call `prompts/get`.

- **Container exits immediately.**
  Your MCP client controls the process lifecycle. It may spawn the container only while connected.
  That’s normal—no need to keep it running manually.

---

## License

MIT © flengure
---

<!--
Keywords: MCP, Model Context Protocol, Claude, Gemini, Zed, Cursor, AI, prompts,
prompt loader, multi-arch, Docker, amd64, arm64, dynamic prompts, zero-restart, LLM,
AI tools, developer tools, automation
-->
