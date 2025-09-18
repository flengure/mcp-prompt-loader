#!/bin/sh
# Enhanced MCP Prompt Loader - Supports both directory and file mounting

# Auto-detect mounting strategy
detect_mount_strategy() {
    if [ -f "$PROMPT_FILE" ]; then
        # PROMPT_FILE is an absolute path to an existing file
        echo "direct-file"
    elif [ -f "$PROMPT_BASE_DIR/$PROMPT_FILE" ]; then
        # PROMPT_FILE is relative to base directory
        echo "directory-mount"
    else
        echo "unknown"
    fi
}

# Resolve target file based on mount strategy
resolve_target_file() {
    local strategy=$(detect_mount_strategy)
    
    case "$strategy" in
        "direct-file")
            echo "$PROMPT_FILE"
            ;;
        "directory-mount")
            echo "$PROMPT_BASE_DIR/$PROMPT_FILE"
            ;;
        *)
            log_error "Cannot locate prompt file: $PROMPT_FILE"
            log_info "Checked:"
            log_info "  Direct file: $PROMPT_FILE"
            log_info "  Directory mount: $PROMPT_BASE_DIR/$PROMPT_FILE"
            exit 1
            ;;
    esac
}

# Usage examples in comments:
#
# Directory Mount (Recommended):
# docker run -v "/host/prompts:/data:ro" -e PROMPT_FILE="expert.txt" image
#
# Direct File Mount:
# docker run -v "/host/prompts/expert.txt:/data/expert.txt:ro" -e PROMPT_FILE="/data/expert.txt" image
#
