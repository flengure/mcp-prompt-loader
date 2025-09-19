# Changelog

## [2.1.0] – Upcoming
### 🚀 Planned Features
- **Metadata index**: optional `index.json` in prompt folder to provide `title`, `description`, `category` per prompt.
- **Search tool**: new `search_prompts(query)` for fuzzy matching across names & metadata.
- **Markdown support**: allow `.md` prompts alongside `.txt`.
- **Config knobs**:
  - `PROMPT_GLOB` (default `*.txt,*.md`)
  - `LOG_LEVEL` (`info`, `debug`)
  - `ALLOW_WRITE` (default `false`)
- **Active prompt tracking**: optional `set_active_prompt` / `get_active_prompt`.

---

## [2.0.0] – 2025-09-19
### ✨ Added
- **Prompt folder mode**:
  - `list_prompts`: enumerate available prompt files.
  - `get_prompt_by_name`: return full text of prompt (dynamic re-read).
  - Auto-detects new prompt files without restart (hot reload).
- **Docker CI/CD**:
  - GitHub Actions workflow for auto-build + publish.
  - Multi-arch builds (`linux/amd64`, `linux/arm64`) via `buildx`.
  - Tags both `:latest` and versioned releases (e.g. `:2.0.0`).
  - Verified digest parity between tags.

---

## [1.0.0] – 2025-09-19
### 🎉 Initial Release
- Single-file mode (`PROMPT_FILE`).
- Basic prompt serving over MCP.
