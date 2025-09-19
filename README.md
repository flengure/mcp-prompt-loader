# MCP Prompt Loader

A lightweight [Model Context Protocol (MCP)](https://modelcontextprotocol.io) server that loads system prompts from text files and exposes them to LLM clients like Claude Desktop, Zed, Gemini CLI, Cursor, and Windsurf.

Supports two modes:

- **v1.0.0 (single file mode)**: mount a single `.txt` file as `/prompt.txt`
- **v2.0.0 (folder mode)**: mount a whole folder of `.txt` files as `/prompts`, and list/get them dynamically

---

## 🚀 Quick Start (Folder Mode)

Mount a folder of prompts:

```bash
docker run --rm -i \
  -v ~/Documents/prompts:/prompts:ro \
  flengure/mcp-prompt-loader:2.0.0
```

Example folder layout:

```
~/Documents/prompts/
  ├── writer.txt
  ├── researcher.txt
  └── teacher.txt
```

---

## 🔄 Dynamic folder mode

Drop new `.txt` files into your mounted `~/Documents/prompts` folder **while the container is running**:

```bash
echo "You are a math tutor." > ~/Documents/prompts/tutor.txt
```

Then, from your MCP client:

- Run **list_prompts** → `tutor` appears immediately
- Run **get_prompt_by_name** with `{ "name": "tutor" }` → you get the text inside `tutor.txt`

No restart, no reload, no SIGHUP required.

---

## 🖥️ Example Client Configs

<details>
<summary>Claude Desktop</summary>

```json
{
  "mcpServers": {
    "prompts: Folder": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run","--rm","-i",
        "-v","/Users/tg/Documents/prompts:/prompts:ro",
        "flengure/mcp-prompt-loader:2.0.0"
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
        "run","--rm","-i",
        "-v","/Users/tg/Documents/prompts:/prompts:ro",
        "flengure/mcp-prompt-loader:2.0.0"
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
        "run","--rm","-i",
        "-v","/Users/tg/Documents/prompts:/prompts:ro",
        "flengure/mcp-prompt-loader:2.0.0"
      ]
    }
  }
}
```
</details>

<details>
<summary>Cursor / Windsurf</summary>

```json
{
  "mcpServers": {
    "prompts: Folder": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run","--rm","-i",
        "-v","/Users/tg/Documents/prompts:/prompts:ro",
        "flengure/mcp-prompt-loader:2.0.0"
      ]
    }
  }
}
```
</details>

---

## 📦 Run from Docker Hub

Use the published image:

```bash
docker run --rm -i \
  -v ~/Documents/prompts:/prompts:ro \
  flengure/mcp-prompt-loader:latest
```

Or pin a specific version:

```bash
docker run --rm -i \
  -v ~/Documents/prompts:/prompts:ro \
  flengure/mcp-prompt-loader:2.0.0
```

---

## 🛠️ Development (local build)

```bash
git clone https://github.com/flengure/mcp-prompt-loader.git
cd mcp-prompt-loader
docker build -t mcp-prompt-loader:local .
```

Then run:

```bash
docker run --rm -i \
  -v ~/Documents/prompts:/prompts:ro \
  mcp-prompt-loader:local
```
