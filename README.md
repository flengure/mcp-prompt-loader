# MCP Prompt Loader

A minimal, generic **MCP server** that loads a system prompt from a mounted file and makes it available to LLM clients (Claude Desktop, Zed, Gemini-CLI, Cursor, Windsurf, Docker MCP Gateway, etc.).

## Features
- Tiny 2-file project: `prompt-server.mjs` + `Dockerfile`.
- Works with any plain text prompt.
- Delivered over **MCP stdio** via JSON-RPC 2.0.
- Supports:
  - `initialize` (handshake)
  - `getPrompt` (return current system prompt)
  - `reload` (re-read file)
- Supports `SIGHUP` inside container for live reload.
- Secure: runs as non-root (`node` user in Alpine).

---

<details>
<summary><strong>🚀 Quickstart</strong></summary>

```sh
# Clone the repo
git clone https://github.com/flengure/mcp-prompt-loader.git
cd mcp-prompt-loader

# Build the image
make build

# Run with example prompt
make run PROMPT_FILE=prompts/my-prompt.txt
```

Then connect it to Claude, Zed, Gemini, Cursor, or Windsurf by adding the configs shown below.
</details>

---

## Repository Layout

```
mcp-prompt-loader/
├── Dockerfile
├── Makefile
├── prompt-server.mjs
├── README.md
└── prompts/
    ├── hummingbot-expert.txt
    ├── binance-expert.txt
    └── my-prompt.txt
```

---

## Example Prompt File (`prompts/hummingbot-expert.txt`)

```txt
### Hummingbot Expert Prompt

You are a trading expert specializing in Hummingbot.
Always explain clearly, step by step, and prefer live tool output over general knowledge.
Emphasize risk management and paper trading when teaching new strategies.
```

---

## Client Configs

<details>
<summary>Claude Desktop</summary>

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
</details>

---

<details>
<summary>Zed Editor</summary>

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
</details>

---

<details>
<summary>Gemini-CLI</summary>

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
</details>

---

<details>
<summary>Cursor</summary>

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
</details>

---

<details>
<summary>Windsurf</summary>

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
</details>

---

## Reloading Prompt

- Edit the file you mounted (`hummingbot-expert.txt`).
- Send `reload` over MCP, or `docker kill -s HUP <container-id>`.

---

<details>
<summary>⚠️ Troubleshooting</summary>

### Container exits immediately
- Make sure you mounted a prompt file:
  ```sh
  -v /abs/path/prompts/hummingbot-expert.txt:/prompt.txt:ro
  ```
- The server requires `PROMPT_FILE` (defaults to `/prompt.txt`).
- If not mounted, you’ll see:
  ```
  [ERROR] PROMPT_FILE environment variable is required
  ```

### MCP client says "Server disconnected"
- Run interactively to see logs:
  ```sh
  docker run -it \
    -v /abs/path/prompts/hummingbot-expert.txt:/prompt.txt:ro \
    flengure/mcp-prompt-loader:latest
  ```

### Debugging
- Add `console.error()` to `prompt-server.mjs` for extra logs.
- Or build a debug image:
  ```sh
  docker build -t mcp-prompt-loader:debug .
  ```

### Multiple prompts
- Use different containers per prompt file.
- Example:
  ```sh
  docker run --rm -i -v prompts/binance.txt:/prompt.txt:ro flengure/mcp-prompt-loader:latest
  docker run --rm -i -v prompts/hummingbot.txt:/prompt.txt:ro flengure/mcp-prompt-loader:latest
  ```
</details>

---

## License

Apache 2.0 – © flengure
