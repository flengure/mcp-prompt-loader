# Maintainer & Developer Instructions

This file contains commands and notes for developing, testing, and publishing the MCP Prompt Loader Docker image.
These instructions are for maintainers and contributors—not for end users.

---

## Validate Everything

Checks prompt files, catalog YAMLs, and Docker configuration for errors and best practices.

```bash
./deploy-production.sh validate
```

## Build and Test

Runs the full cycle: validation, build, and tests.  
Specify your Docker registry if needed.

```bash
./deploy-production.sh all --registry your-registry
```

## Build Locally (No Registry)

Builds the Docker image for local use.

```bash
./deploy-production.sh build
```

## Push to Registry

Builds and pushes the Docker image to your registry.

```bash
./deploy-production.sh build --push --registry your-registry
```

## Run Tests

Runs comprehensive tests on the built image.

```bash
./deploy-production.sh test
```

## Clean Up Build Artifacts

Removes test output and dangling Docker images.

```bash
./deploy-production.sh clean
```

---

**Note:**  
These commands are for development and maintenance.  
End users should refer to the main README for simple usage instructions.