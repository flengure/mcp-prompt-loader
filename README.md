# MCP Prompt Loadern
n
[![CI](https://github.com/flengure/mcp-prompt-loader/actions/workflows/release-docker.yml/badge.svg)](https://github.com/flengure/mcp-prompt-loader/actions/workflows/release-docker.yml)
 [![Docker Pulls](https://img.shields.io/docker/pulls/flengure/mcp-prompt-loader.svg)](https://hub.docker.com/r/flengure/mcp-prompt-loader)
 [![Image Size](https://img.shields.io/docker/image-size/flengure/mcp-prompt-loader/latest)](https://hub.docker.com/r/flengure/mcp-prompt-loader)
 [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
 [![Stars](https://img.shields.io/github/stars/flengure/mcp-prompt-loader?style=social)](https://github.com/flengure/mcp-prompt-loader/stargazers)n
# MCP Prompt Loadern
n
[![CI](https://github.com/flengure/mcp-prompt-loader/actions/workflows/release-docker.yml/badge.svg)](https://github.com/flengure/mcp-prompt-loader/actions/workflows/release-docker.yml)
 [![Docker Pulls](https://img.shields.io/docker/pulls/flengure/mcp-prompt-loader.svg)](https://hub.docker.com/r/flengure/mcp-prompt-loader)
 [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
 [![Stars](https://img.shields.io/github/stars/flengure/mcp-prompt-loader?style=social)](https://github.com/flengure/mcp-prompt-loader/stargazers)n
# MCP Prompt Loadern
n
[![CI](https://github.com/flengure/mcp-prompt-loader/actions/workflows/release-docker.yml/badge.svg)](https://github.com/flengure/mcp-prompt-loader/actions/workflows/release-docker.yml)
 [![Docker Pulls](https://img.shields.io/docker/pulls/flengure/mcp-prompt-loader.svg)](https://hub.docker.com/r/flengure/mcp-prompt-loader)
 [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)n
# MCP Prompt Loader
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A lightweight Model Context Protocol (MCP) server that loads prompts from `.txt` files and serves them to any MCP-compatible client (Claude Desktop, Zed, Gemini CLI, Cursor, Windsurf, etc.).

## Features
- 🔹 **Folder Mode**: mount a folder with multiple `.txt` files and they are all available instantly
- 🔹 **Tooling**: list prompts and fetch content via JSON-RPC
- 🔹 **Clients Supported**: Claude Desktop, Zed, Gemini CLI, Cursor, Windsurf
- 🔹 **No Restarts**: drop in new files and they show up automatically on `list_prompts`

---

## Installation / Usage

Mount a folder containing your `.txt` prompt files:

```bash
docker run --rm -i \
  -v ~/Documents/prompts:/prompts:ro \
  flengure/mcp-prompt-loader:latest
```

Your client config (Claude Desktop, Zed, etc.) will call this container and use prompts by name.

---

## Docker Tags

This project publishes Docker images to [Docker Hub](https://hub.docker.com/r/flengure/mcp-prompt-loader).

- **`latest`**
  Always points to the newest stable release (currently `v2.0.0`).
  Recommended if you just want the most up-to-date features.

- **Versioned tags (e.g. `2.0.0`)**
  Point to a specific release.
  Recommended if you need reproducible builds and don’t want unexpected updates.

Example usage:

```bash
# Always up to date
docker run --rm -i -v ~/Documents/prompts:/prompts:ro flengure/mcp-prompt-loader:latest

# Reproducible build
docker run --rm -i -v ~/Documents/prompts:/prompts:ro flengure/mcp-prompt-loader:2.0.0
```

---

## Tools

### `list_prompts`
Lists all `.txt` files in `/prompts` and exposes them by name.

### `get_prompt`
Fetches the contents of a specific prompt by name (without `.txt` extension).

---

## Example Prompts

Put files like these into `~/Documents/prompts`:

- `writer.txt`
- `researcher.txt`
- `teacher.txt`

They will be accessible immediately without restarting.

---

## Client Configs

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

<details>
<summary>Cursor & Windsurf</summary>

Same as above — use `"mcpServers"` with the same docker run arguments.
</details>

---

## License

MIT

---

## License

This project is licensed under the [MIT License](LICENSE).
