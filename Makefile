# Makefile for MCP Prompt Loader

IMAGE_NAME = flengure/mcp-prompt-loader:latest
PROMPT_FILE = my-prompt.txt

.PHONY: build run clean

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run the container with the example prompt file
run:
	docker run --rm -i \
		-v $(PWD)/$(PROMPT_FILE):/prompt.txt:ro \
		$(IMAGE_NAME)

# Remove dangling images and containers
clean:
	docker system prune -f
