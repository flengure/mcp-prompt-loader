# Adding GitHub Integration to Your MCP Setup

## Option 1: Official GitHub MCP Server (Recommended)

Add this to your MCP catalog to enable GitHub repository management:

```yaml
# Add to your catalog.yaml
github-integration:
  title: "GitHub Repository Management"
  description: "Official GitHub MCP server for repository operations"
  type: "server"
  image: mcp/github:latest
  
  secrets:
    - name: github.personal_access_token
      env: GITHUB_PERSONAL_ACCESS_TOKEN
      example: "ghp_your_token_here"
  
  env:
    - name: GITHUB_API_URL
      value: "https://api.github.com"
  
  config:
    - name: github
      description: "Configure GitHub integration"
      type: object
      properties:
        default_owner:
          type: string
          description: "Default GitHub username/organization"
        auto_initialize:
          type: boolean
          description: "Auto-initialize repositories with README"
          default: true
      required:
        - default_owner
  
  metadata:
    category: "development"
    tags:
      - "github"
      - "git" 
      - "repository"
    license: "Apache License 2.0"
```

## Available GitHub Operations

Once configured, you'll have access to:

### **Repository Operations**
- ✅ `create_repository` - Create new repositories
- ✅ `get_repository` - Get repository information  
- ✅ `update_repository` - Update repository settings
- ✅ `delete_repository` - Delete repositories
- ✅ `list_repositories` - List user/org repositories

### **File Operations**
- ✅ `create_file` - Create files
- ✅ `update_file` - Update existing files
- ✅ `delete_file` - Delete files
- ✅ `get_file_content` - Read file contents
- ✅ `list_files` - List repository files

### **Release Operations**
- ✅ `create_release` - Create releases with tags
- ✅ `update_release` - Update release information
- ✅ `list_releases` - List repository releases

## Setup Steps

1. **Get GitHub Token**:
   - Go to GitHub → Settings → Developer settings → Personal access tokens
   - Create token with `repo` permissions
   - Save as `github.personal_access_token` in MCP secrets

2. **Add to Catalog**:
   - Add the configuration above to your MCP catalog
   - Set your GitHub username in config

3. **Restart MCP Gateway**:
   - Restart to load the new GitHub integration

4. **Test Connection**:
   - Ask: "List my GitHub repositories"
   - Or: "Create a new repository called 'test-repo'"

## Creating Your MCP Prompt Loader Repository

Once GitHub integration is active, you can:

```
"Create a new GitHub repository called 'mcp-prompt-loader' with:
- Description: 'Generic prompt loader for MCP clients with Docker Hub deployment'
- Public visibility
- Initialize with README
- Add MIT license
- Include .gitignore for Docker/Node projects"
```

Then upload your project files:

```
"Upload all files from /path/to/prompts/ to the new repository, maintaining the directory structure"
```

## Alternative: Quick Manual Setup

If you prefer immediate action:

1. **Go to GitHub.com** → Create new repository
2. **Repository name**: `mcp-prompt-loader`  
3. **Description**: `Generic prompt loader for MCP clients with Docker Hub deployment`
4. **Public** repository
5. **Initialize with README**
6. **Add MIT license**
7. **Add .gitignore**: Choose "Node" or "Docker"

Then clone and upload:

```bash
git clone https://github.com/yourusername/mcp-prompt-loader.git
cd mcp-prompt-loader
cp -r /path/to/prompts/* .
git add .
git commit -m "Initial commit: MCP prompt loader with multi-client support"
git push origin main
```

## Benefits of GitHub Integration

✅ **Version Control** - Proper Git history and branching
✅ **Community Access** - Others can discover and use your tool  
✅ **Issue Tracking** - Users can report bugs and request features
✅ **Documentation** - GitHub renders your README beautifully
✅ **CI/CD Integration** - Automatic Docker Hub builds from GitHub
✅ **Collaboration** - Accept pull requests and contributions

Would you like me to help set up the GitHub MCP integration, or would you prefer to create the repository manually first?
