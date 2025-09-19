# syntax=docker/dockerfile:1
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy only the server file
COPY prompt-server.mjs .

# Run as non-root user (provided by node:20-alpine)
USER node

# Command: start the MCP server
CMD ["node", "prompt-server.mjs"]
