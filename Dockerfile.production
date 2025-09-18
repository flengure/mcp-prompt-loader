# Production-ready MCP Prompt Loader
# Minimal, secure container for loading text-based AI expert prompts

FROM alpine:3.19

# Metadata
LABEL maintainer="MCP Community" \
      version="1.0.0" \
      description="Universal prompt loader for MCP AI expert systems" \
      org.opencontainers.image.title="MCP Prompt Loader" \
      org.opencontainers.image.description="A configurable tool to load text files as AI expert system prompts" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.created="2024-01-15" \
      org.opencontainers.image.source="https://github.com/your-org/mcp-prompt-loader"

# Install required packages for better error handling and validation
RUN apk add --no-cache \
    ca-certificates \
    file \
    && rm -rf /var/cache/apk/*

# Create non-root user for security
RUN addgroup -g 1000 promptloader && \
    adduser -D -s /bin/sh -u 1000 -G promptloader promptloader

# Copy and configure the main script
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Create data directory with proper permissions
RUN mkdir -p /data && \
    chown promptloader:promptloader /data

# Switch to non-root user
USER promptloader

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD [ "/usr/local/bin/run.sh", "--health" ]

# Set the script as the entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]