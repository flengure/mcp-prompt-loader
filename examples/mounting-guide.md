# MCP Prompt Loader - Mounting Options

## Option 1: Directory Mount (Recommended)

**Best for:** Multiple prompts, easy switching, development

```yaml
my-expert:
  type: server
  image: flengure/mcp-prompt-loader:latest
  environment:
    - name: PROMPT_FILE
      value: "hummingbot.txt"  # Just filename
  volumes:
    - "/path/to/prompt-directory:/data:ro"
```

**Benefits:**
- Switch experts by changing environment variable only
- Health checks work automatically  
- Simple configuration
- Access to multiple prompt files

## Option 2: Direct File Mount

**Best for:** Single prompt, maximum security, production deployments

```yaml
my-expert:
  type: server
  image: flengure/mcp-prompt-loader:latest
  environment:
    - name: PROMPT_FILE
      value: "/data/expert.txt"  # Must be absolute path
  volumes:
    - "/path/to/specific-prompt.txt:/data/expert.txt:ro"
```

**Benefits:**
- Only specific file exposed to container
- Slightly more secure
- Explicit file control

**Trade-offs:**
- More complex configuration
- Must specify absolute paths
- Less flexible for switching prompts

## Which Should I Use?

- **Development/Testing:** Use directory mount
- **Multiple Experts:** Use directory mount  
- **Production/Single Expert:** Either works, directory mount still easier
- **Maximum Security:** Use direct file mount

The tool supports both approaches automatically! 🎉
