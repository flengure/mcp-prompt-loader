FROM node:20-alpine

LABEL maintainer="flengure"
LABEL version="2.0.0-dev"
LABEL description="MCP Prompt Loader - folder-based prompt server"

WORKDIR /app
COPY prompt-server.mjs /app/

USER node
CMD ["node", "prompt-server.mjs"]
