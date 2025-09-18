# Claude Desktop MCP Configuration

Configure Claude Desktop to use the prompt loader for specialized AI experts.

## Configuration Location

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

## Example Configuration

```json
{
  "mcpServers": {
    "hummingbot-expert": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull=always",
        "-v", "/path/to/prompts:/data:ro",
        "-e", "PROMPT_FILE=hummingbot.txt",
        "-e", "PROMPT_BASE_DIR=/data",
        "flengure/mcp-prompt-loader:latest"
      ]
    },
    "n8n-expert": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull=always", 
        "-v", "/path/to/prompts:/data:ro",
        "-e", "PROMPT_FILE=n8n.txt",
        "-e", "PROMPT_BASE_DIR=/data",
        "flengure/mcp-prompt-loader:latest"
      ]
    },
    "zed-expert": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull=always",
        "-v", "/path/to/prompts:/data:ro", 
        "-e", "PROMPT_FILE=zed.txt",
        "-e", "PROMPT_BASE_DIR=/data",
        "flengure/mcp-prompt-loader:latest"
      ]
    },
    "mcp-gateway-expert": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull=always",
        "-v", "/path/to/prompts:/data:ro",
        "-e", "PROMPT_FILE=mcp-gateway.txt", 
        "-e", "PROMPT_BASE_DIR=/data",
        "flengure/mcp-prompt-loader:latest"
      ]
    }
  }
}
```

## Windows Configuration

For Windows users, adjust the volume path:

```json
{
  "mcpServers": {
    "hummingbot-expert": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--pull=always",
        "-v", "C:\\path\\to\\your\\mcp-prompt-loader:/data:ro",
        "-e", "PROMPT_FILE=hummingbot.txt",
        "-e", "PROMPT_BASE_DIR=/data",
        "flengure/mcp-prompt-loader:latest"
      ]
    }
  }
}
```

## Testing

1. **Save configuration** to Claude Desktop config file
2. **Restart Claude Desktop** completely
3. **Test connection**: Start a new conversation and ask "What MCP tools are available?"
4. **Activate expert**: Use the relevant prompt context for your domain

## Security Notes

- Uses **read-only mounts** (`ro`) for security
- Always **pulls latest image** for updates
- **Container isolation** prevents system access
- **Non-root execution** inside container

## Troubleshooting

### Common Issues

1. **Docker not running**: Start Docker Desktop
2. **Path issues**: Use absolute paths for volume mounts
3. **Permissions**: Ensure Docker can access the mount directory
4. **Network issues**: Check Docker can pull from Hub

### Debug Mode

Add debug environment variable:

```json
"-e", "DEBUG_MODE=true"
```

### Logs

Check Claude Desktop logs:
- **macOS**: `~/Library/Logs/Claude/`
- **Windows**: `%LOCALAPPDATA%\Claude\logs\`
