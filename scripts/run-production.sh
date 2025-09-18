#!/bin/sh
# Production MCP Prompt Loader Script
# A robust script to display AI expert prompt content with comprehensive error handling

set -e  # Exit on any error

# Script metadata
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="MCP Prompt Loader"

# Configuration with defaults
PROMPT_BASE_DIR=${PROMPT_BASE_DIR:-/data}
DEBUG_MODE=${DEBUG_MODE:-false}
LOG_LEVEL=${LOG_LEVEL:-info}

# Logging functions
log_info() {
    if [ "$LOG_LEVEL" != "error" ]; then
        echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
    fi
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

log_debug() {
    if [ "$DEBUG_MODE" = "true" ]; then
        echo "[DEBUG] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
    fi
}

# Health check function
health_check() {
    log_debug "Performing health check"
    
    # Check if base directory exists and is readable
    if [ ! -d "$PROMPT_BASE_DIR" ]; then
        log_error "Health check failed: Base directory $PROMPT_BASE_DIR does not exist"
        exit 1
    fi
    
    if [ ! -r "$PROMPT_BASE_DIR" ]; then
        log_error "Health check failed: Base directory $PROMPT_BASE_DIR is not readable"
        exit 1
    fi
    
    # If PROMPT_FILE is set, check if it exists
    if [ -n "$PROMPT_FILE" ]; then
        TARGET_FILE="$PROMPT_FILE"
        if ! echo "$PROMPT_FILE" | grep -q "^/"; then
            TARGET_FILE="$PROMPT_BASE_DIR/$PROMPT_FILE"
        fi
        
        if [ ! -f "$TARGET_FILE" ]; then
            log_error "Health check failed: Prompt file $TARGET_FILE does not exist"
            exit 1
        fi
        
        if [ ! -r "$TARGET_FILE" ]; then
            log_error "Health check failed: Prompt file $TARGET_FILE is not readable"
            exit 1
        fi
        
        # Validate file content
        if [ ! -s "$TARGET_FILE" ]; then
            log_error "Health check failed: Prompt file $TARGET_FILE is empty"
            exit 1
        fi
    fi
    
    log_info "Health check passed"
    echo "healthy"
    exit 0
}

# Version information
show_version() {
    echo "$SCRIPT_NAME v$SCRIPT_VERSION"
    echo "A configurable prompt loader for MCP AI expert systems"
    exit 0
}

# Usage information
show_usage() {
    cat << EOF
$SCRIPT_NAME v$SCRIPT_VERSION

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --health        Perform health check and exit
    --version       Show version information and exit
    --help          Show this help message and exit

ENVIRONMENT VARIABLES:
    PROMPT_FILE     Path to the prompt file (required)
                    Can be absolute or relative to PROMPT_BASE_DIR
                    
    PROMPT_BASE_DIR Base directory for relative paths (default: /data)
    
    DEBUG_MODE      Enable debug logging (default: false)
                    Values: true, false
                    
    LOG_LEVEL       Logging verbosity (default: info)
                    Values: error, info, debug

EXAMPLES:
    # Load a prompt file
    PROMPT_FILE="hummingbot.txt" $0
    
    # Load with custom base directory
    PROMPT_BASE_DIR="/custom/path" PROMPT_FILE="expert.txt" $0
    
    # Enable debug mode
    DEBUG_MODE=true PROMPT_FILE="n8n.txt" $0

EOF
    exit 0
}

# Parse command line arguments
case "${1:-}" in
    --health)
        health_check
        ;;
    --version)
        show_version
        ;;
    --help)
        show_usage
        ;;
    "")
        # Normal operation - continue
        ;;
    *)
        log_error "Unknown option: $1"
        echo "Use --help for usage information" >&2
        exit 1
        ;;
esac

# Start main execution
log_info "Starting $SCRIPT_NAME v$SCRIPT_VERSION"
log_debug "Configuration: PROMPT_BASE_DIR=$PROMPT_BASE_DIR, DEBUG_MODE=$DEBUG_MODE"

# Validate required environment variables
if [ -z "$PROMPT_FILE" ]; then
    log_error "PROMPT_FILE environment variable is not set"
    echo "Error: Missing required environment variable PROMPT_FILE" >&2
    echo "Use --help for usage information" >&2
    exit 1
fi

log_debug "Prompt file requested: $PROMPT_FILE"

# Validate base directory
if [ ! -d "$PROMPT_BASE_DIR" ]; then
    log_error "Base directory does not exist: $PROMPT_BASE_DIR"
    exit 1
fi

if [ ! -r "$PROMPT_BASE_DIR" ]; then
    log_error "Base directory is not readable: $PROMPT_BASE_DIR"
    exit 1
fi

log_debug "Base directory validated: $PROMPT_BASE_DIR"

# Resolve target file path
TARGET_FILE="$PROMPT_FILE"
if ! echo "$PROMPT_FILE" | grep -q "^/"; then
    TARGET_FILE="$PROMPT_BASE_DIR/$PROMPT_FILE"
    log_debug "Resolved relative path to: $TARGET_FILE"
else
    log_debug "Using absolute path: $TARGET_FILE"
fi

# Validate prompt file
if [ ! -f "$TARGET_FILE" ]; then
    log_error "Prompt file not found: $TARGET_FILE"
    
    # Provide helpful suggestions
    log_info "Available files in $PROMPT_BASE_DIR:"
    if command -v ls >/dev/null 2>&1; then
        ls -la "$PROMPT_BASE_DIR"/*.txt 2>/dev/null | sed 's/^/  /' >&2 || log_info "  No .txt files found"
    fi
    
    exit 1
fi

if [ ! -r "$TARGET_FILE" ]; then
    log_error "Prompt file is not readable: $TARGET_FILE"
    exit 1
fi

# Validate file content
if [ ! -s "$TARGET_FILE" ]; then
    log_error "Prompt file is empty: $TARGET_FILE"
    exit 1
fi

# Optional: Validate file type
if command -v file >/dev/null 2>&1; then
    FILE_TYPE=$(file -b "$TARGET_FILE")
    log_debug "File type detected: $FILE_TYPE"
    
    # Check if it's a text file
    if ! echo "$FILE_TYPE" | grep -qi "text"; then
        log_error "Warning: File does not appear to be a text file: $FILE_TYPE"
    fi
fi

# Get file size for logging
if command -v wc >/dev/null 2>&1; then
    FILE_SIZE=$(wc -c < "$TARGET_FILE")
    FILE_LINES=$(wc -l < "$TARGET_FILE")
    log_info "Loading prompt file: $TARGET_FILE ($FILE_SIZE bytes, $FILE_LINES lines)"
else
    log_info "Loading prompt file: $TARGET_FILE"
fi

# Security check: Ensure file is within allowed base directory
REAL_BASE=$(cd "$PROMPT_BASE_DIR" && pwd)
REAL_TARGET=$(cd "$(dirname "$TARGET_FILE")" && pwd)/$(basename "$TARGET_FILE")

if ! echo "$REAL_TARGET" | grep -q "^$REAL_BASE"; then
    log_error "Security violation: Target file is outside base directory"
    log_error "Base: $REAL_BASE"
    log_error "Target: $REAL_TARGET"
    exit 1
fi

log_debug "Security check passed: File is within base directory"

# Load and output the prompt file
log_debug "Reading prompt file content"

if ! cat "$TARGET_FILE"; then
    log_error "Failed to read prompt file: $TARGET_FILE"
    exit 1
fi

log_debug "Prompt file loaded successfully"
log_info "$SCRIPT_NAME completed successfully"