# Changelog

## v2.0.0
**Folder-mode release.**

- Added support for mounting an entire folder of `.txt` prompts instead of single file.
- Introduced two MCP tools:
  - **`prompts/list`** — returns the available prompt names (based on `.txt` files).
  - **`prompts/get`** — returns the contents of a prompt by name.
- Prompts are re-read from disk on each call, so no container restart is required when files change.
- Multi-arch Docker builds (`linux/amd64` + `linux/arm64`).
- Auto-publish workflow to Docker Hub (`:latest` on main, `:X.Y.Z` on tags).

---

## v1.0.0
**Initial release.**

- Single-file prompt loader (`PROMPT_FILE` env or mounted `/prompt.txt`).
- Worked with Claude Desktop, Zed, Gemini CLI, Cursor, Windsurf.
- Docker Hub image `flengure/mcp-prompt-loader:1.0.0`.
