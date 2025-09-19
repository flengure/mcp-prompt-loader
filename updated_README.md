# MCP Prompt Loader

[![Docker Pulls](https://img.shields.io/docker/pulls/flengure/mcp-prompt-loader)](https://hub.docker.com/r/flengure/mcp-prompt-loader)
[![Image Size](https://img.shields.io/docker/image-size/flengure/mcp-prompt-loader/latest)](https://hub.docker.com/r/flengure/mcp-prompt-loader/tags)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Stars](https://img.shields.io/github/stars/flengure/mcp-prompt-loader?style=social)](https://github.com/flengure/mcp-prompt-loader)

A lightweight Model Context Protocol (MCP) server that loads prompts from `.txt` files.

## Features

- 🔹 **Folder Mode**: mount a folder with multiple `.txt` files and they are served as prompts  
- 🔹 **Tooling**: list prompts and fetch content via JSON-RPC  
- 🔹 **Clients Supported**: Claude Desktop, Zed, Gemini CLI, Cursor, Windsurf, docker-mcp-gateway  
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

This project publishes Docker images to [Docker Hub](https://hub.docker.com/r/flengure/mcp-prompt-loader)

- **latest**  
  Always points to the newest stable release (currently v2.0.0).  
  Recommended if you just want the most up-to-date features.

- **Versioned tags (e.g. 2.0.0)**  
  Use if you want reproducible builds tied to a specific release.

---

## Example Prompts

Here are some example `.txt` prompts you can drop into your mounted folder:

### 📄 `writer.txt`
```
You are a helpful writing assistant. Help me brainstorm, outline, and edit text clearly and concisely.
```

### 📄 `researcher.txt`
```
You are a research assistant. Summarize academic papers, compare viewpoints, and surface reliable references.
```

### 📄 `teacher.txt`
```
You are a patient teacher. Explain concepts step by step with simple examples until the learner understands.
```

### 📄 `code-reviewer.txt`
```
You are a senior software engineer. Review code for clarity, maintainability, and performance issues.
```

### 📄 `explainer.txt`
```
You are an explainer. Break down complex topics into analogies and plain language for beginners.
```

---

## License

MIT © 2025 [flengure](https://github.com/flengure/mcp-prompt-loader)
