# Release Notes

## v2.0.0 (folder-mode; multiple prompts)

### 🚀 Features
- Introduced **folder-mode**: load multiple prompt files from a mounted directory instead of one file at a time.
- Added `list_prompts` tool:
  - Returns all available prompt files (by name and description).
  - Allows clients (Claude, Zed, Cursor, etc.) to browse and select prompts interactively.
- Updated server logging to show active folder (`/prompts`).

### 🔨 Breaking Changes
- Removed single-file mode (`/prompt.txt` with `PROMPT_DIR` env override).
- `PROMPT_DIR` environment variable no longer supported — the server now **always looks at `/prompts`** inside the container.

### 🧑‍💻 Migration
- Before:
  ```bash
  docker run --rm -i \
    -v ~/Documents/prompts/hummingbot-expert.txt:/prompt.txt:ro \
    flengure/mcp-prompt-loader:1.0.0
  ```

- After:
  ```bash
  docker run --rm -i \
    -v ~/Documents/prompts:/prompts:ro \
    flengure/mcp-prompt-loader:2.0.0
  ```

  Place all `.txt` prompts into `~/Documents/prompts/`, then load them by name inside your client.

### ✅ Compatibility
- Works with Claude Desktop, Zed, Cursor, Gemini CLI.
- Confirmed prompt listing and retrieval tested in **Claude** and **Zed**.

---

## v1.0.0 (single-file mode)

### 🚀 Features
- Initial release.
- Supported loading a single `.txt` prompt mounted as `/prompt.txt`.
- Provided simple integration with Claude Desktop, Zed, Cursor, and Gemini CLI.

### ⚠️ Limitations
- No folder-mode, no `list_prompts` tool.
- Required multiple containers if you wanted multiple prompt files.

---
