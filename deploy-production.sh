#!/bin/bash
# Production Deployment Script for MCP Prompt Loader
# Validates configuration, builds containers, and deploys with comprehensive checks

set -e

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="mcp-prompt-loader"
VERSION="1.0.0"
REGISTRY="${REGISTRY:-localhost}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Usage information
show_usage() {
    cat << EOF
MCP Prompt Loader - Production Deployment Script v${VERSION}

USAGE:
    $0 [COMMAND] [OPTIONS]

COMMANDS:
    validate        Validate configuration and prompt files
    build          Build production Docker image
    test           Run comprehensive tests
    deploy         Deploy to MCP Gateway
    clean          Clean up build artifacts
    all            Run validate, build, test sequence

OPTIONS:
    --registry REG  Docker registry (default: localhost)
    --tag TAG       Docker image tag (default: ${VERSION})
    --push          Push to registry after build
    --verbose       Enable verbose logging
    --help          Show this help message

EXAMPLES:
    $0 validate                    # Validate all configurations
    $0 build --tag latest         # Build with custom tag
    $0 test --verbose             # Run tests with verbose output
    $0 all --registry myregistry  # Full build and test cycle

EOF
}

# Validate prompt files
validate_prompts() {
    log_info "Validating prompt files..."
    
    local errors=0
    local prompts=(
        "hummingbot.txt"
        "n8n.txt" 
        "zed.txt"
        "mcp-gateway.txt"
        "prompt.txt"
    )
    
    for prompt in "${prompts[@]}"; do
        local file="${SCRIPT_DIR}/${prompt}"
        
        if [ ! -f "$file" ]; then
            log_error "Prompt file missing: $prompt"
            ((errors++))
            continue
        fi
        
        if [ ! -r "$file" ]; then
            log_error "Prompt file not readable: $prompt"
            ((errors++))
            continue
        fi
        
        if [ ! -s "$file" ]; then
            log_error "Prompt file is empty: $prompt"
            ((errors++))
            continue
        fi
        
        # Check for required sections
        if ! grep -q "System Prompt:" "$file"; then
            log_warning "Prompt file missing 'System Prompt:' header: $prompt"
        fi
        
        if ! grep -q "Core Identity:" "$file"; then
            log_warning "Prompt file missing 'Core Identity:' section: $prompt"
        fi
        
        # Check file size (reasonable limits)
        local size=$(wc -c < "$file")
        if [ "$size" -gt 50000 ]; then
            log_warning "Prompt file is very large (${size} bytes): $prompt"
        elif [ "$size" -lt 100 ]; then
            log_warning "Prompt file is very small (${size} bytes): $prompt"
        fi
        
        log_success "Validated prompt file: $prompt (${size} bytes)"
    done
    
    if [ $errors -gt 0 ]; then
        log_error "Validation failed with $errors errors"
        return 1
    fi
    
    log_success "All prompt files validated successfully"
    return 0
}

# Validate catalog files
validate_catalogs() {
    log_info "Validating catalog files..."
    
    local errors=0
    local catalogs=(
        "hummingbot-catalog-production.yaml"
        "n8n-catalog-production.yaml"
        "personal-catalog-production.yaml"
    )
    
    for catalog in "${catalogs[@]}"; do
        local file="${SCRIPT_DIR}/${catalog}"
        
        if [ ! -f "$file" ]; then
            log_error "Catalog file missing: $catalog"
            ((errors++))
            continue
        fi
        
        # Basic YAML syntax check
        if command -v yamllint >/dev/null 2>&1; then
            if ! yamllint -c "{extends: default, rules: {line-length: {max: 120}}}" "$file" >/dev/null 2>&1; then
                log_error "YAML syntax error in: $catalog"
                ((errors++))
                continue
            fi
        else
            log_warning "yamllint not available, skipping syntax validation"
        fi
        
        # Check required fields
        if ! grep -q "name:" "$file"; then
            log_error "Catalog missing 'name' field: $catalog"
            ((errors++))
        fi
        
        if ! grep -q "registry:" "$file"; then
            log_error "Catalog missing 'registry' field: $catalog"
            ((errors++))
        fi
        
        # Check for production features
        if ! grep -q "parameters:" "$file"; then
            log_warning "Catalog missing 'parameters' section: $catalog"
        fi
        
        if ! grep -q "healthcheck:" "$file"; then
            log_warning "Catalog missing 'healthcheck' section: $catalog"
        fi
        
        log_success "Validated catalog file: $catalog"
    done
    
    if [ $errors -gt 0 ]; then
        log_error "Catalog validation failed with $errors errors"
        return 1
    fi
    
    log_success "All catalog files validated successfully"
    return 0
}

# Validate Docker configuration
validate_docker() {
    log_info "Validating Docker configuration..."
    
    # Check Docker availability
    if ! command -v docker >/dev/null 2>&1; then
        log_error "Docker is not installed or not in PATH"
        return 1
    fi
    
    # Check Docker daemon
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running"
        return 1
    fi
    
    # Validate Dockerfile
    local dockerfile="${SCRIPT_DIR}/Dockerfile.production"
    if [ ! -f "$dockerfile" ]; then
        log_error "Production Dockerfile missing: $dockerfile"
        return 1
    fi
    
    # Check for security best practices
    if ! grep -q "USER" "$dockerfile"; then
        log_error "Dockerfile missing USER directive (security risk)"
        return 1
    fi
    
    if ! grep -q "HEALTHCHECK" "$dockerfile"; then
        log_warning "Dockerfile missing HEALTHCHECK directive"
    fi
    
    # Validate run script
    local runscript="${SCRIPT_DIR}/run-production.sh"
    if [ ! -f "$runscript" ]; then
        log_error "Production run script missing: $runscript"
        return 1
    fi
    
    if [ ! -x "$runscript" ]; then
        log_error "Run script is not executable: $runscript"
        return 1
    fi
    
    log_success "Docker configuration validated successfully"
    return 0
}

# Build Docker image
build_image() {
    local tag="${1:-${VERSION}}"
    local push_flag="${2:-false}"
    
    log_info "Building Docker image with tag: ${REGISTRY}/${PROJECT_NAME}:${tag}"
    
    # Build with production Dockerfile
    if ! docker build \
        -f "${SCRIPT_DIR}/Dockerfile.production" \
        -t "${REGISTRY}/${PROJECT_NAME}:${tag}" \
        --label "version=${VERSION}" \
        --label "build-date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
        --label "commit-hash=$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')" \
        "${SCRIPT_DIR}"; then
        log_error "Docker build failed"
        return 1
    fi
    
    # Tag as latest if building version tag
    if [ "$tag" = "$VERSION" ]; then
        docker tag "${REGISTRY}/${PROJECT_NAME}:${tag}" "${REGISTRY}/${PROJECT_NAME}:latest"
        log_success "Tagged as latest"
    fi
    
    # Push to registry if requested
    if [ "$push_flag" = "true" ]; then
        log_info "Pushing to registry..."
        docker push "${REGISTRY}/${PROJECT_NAME}:${tag}"
        if [ "$tag" = "$VERSION" ]; then
            docker push "${REGISTRY}/${PROJECT_NAME}:latest"
        fi
        log_success "Pushed to registry"
    fi
    
    log_success "Docker image built successfully: ${REGISTRY}/${PROJECT_NAME}:${tag}"
    return 0
}

# Run comprehensive tests
run_tests() {
    local tag="${1:-${VERSION}}"
    local verbose="${2:-false}"
    
    log_info "Running comprehensive tests..."
    
    local test_dir="${SCRIPT_DIR}/test_output"
    mkdir -p "$test_dir"
    
    local errors=0
    
    # Test 1: Basic functionality
    log_info "Test 1: Basic prompt loading"
    if [ "$verbose" = "true" ]; then
        if ! docker run --rm \
            -v "${SCRIPT_DIR}:/data:ro" \
            -e PROMPT_FILE="hummingbot.txt" \
            "${REGISTRY}/${PROJECT_NAME}:${tag}" > "${test_dir}/test1_output.txt" 2>&1; then
            log_error "Test 1 failed: Basic prompt loading"
            ((errors++))
        else
            log_success "Test 1 passed: Basic prompt loading"
        fi
    else
        if ! docker run --rm \
            -v "${SCRIPT_DIR}:/data:ro" \
            -e PROMPT_FILE="hummingbot.txt" \
            "${REGISTRY}/${PROJECT_NAME}:${tag}" >/dev/null 2>&1; then
            log_error "Test 1 failed: Basic prompt loading"
            ((errors++))
        else
            log_success "Test 1 passed: Basic prompt loading"
        fi
    fi
    
    # Test 2: Health check
    log_info "Test 2: Health check functionality"
    if ! docker run --rm \
        -v "${SCRIPT_DIR}:/data:ro" \
        -e PROMPT_FILE="hummingbot.txt" \
        "${REGISTRY}/${PROJECT_NAME}:${tag}" --health >/dev/null 2>&1; then
        log_error "Test 2 failed: Health check"
        ((errors++))
    else
        log_success "Test 2 passed: Health check"
    fi
    
    # Test 3: Error handling (missing file)
    log_info "Test 3: Error handling for missing file"
    if docker run --rm \
        -v "${SCRIPT_DIR}:/data:ro" \
        -e PROMPT_FILE="nonexistent.txt" \
        "${REGISTRY}/${PROJECT_NAME}:${tag}" >/dev/null 2>&1; then
        log_error "Test 3 failed: Should have failed for missing file"
        ((errors++))
    else
        log_success "Test 3 passed: Proper error handling for missing file"
    fi
    
    # Test 4: Security validation (path traversal)
    log_info "Test 4: Security validation (path traversal prevention)"
    if docker run --rm \
        -v "${SCRIPT_DIR}:/data:ro" \
        -e PROMPT_FILE="../../../etc/passwd" \
        "${REGISTRY}/${PROJECT_NAME}:${tag}" >/dev/null 2>&1; then
        log_error "Test 4 failed: Path traversal attack succeeded (security vulnerability!)"
        ((errors++))
    else
        log_success "Test 4 passed: Path traversal attack prevented"
    fi
    
    # Test 5: Multiple prompt files
    log_info "Test 5: Multiple prompt file loading"
    local prompts=("hummingbot.txt" "n8n.txt" "zed.txt")
    for prompt in "${prompts[@]}"; do
        if [ -f "${SCRIPT_DIR}/${prompt}" ]; then
            if ! docker run --rm \
                -v "${SCRIPT_DIR}:/data:ro" \
                -e PROMPT_FILE="$prompt" \
                "${REGISTRY}/${PROJECT_NAME}:${tag}" >/dev/null 2>&1; then
                log_error "Test 5 failed: Loading $prompt"
                ((errors++))
            fi
        fi
    done
    if [ $errors -eq 0 ]; then
        log_success "Test 5 passed: Multiple prompt files"
    fi
    
    # Test 6: Container security
    log_info "Test 6: Container security validation"
    
    # Check if running as non-root
    local user_info=$(docker run --rm "${REGISTRY}/${PROJECT_NAME}:${tag}" --version 2>/dev/null || echo "")
    if docker run --rm "${REGISTRY}/${PROJECT_NAME}:${tag}" sh -c "id" 2>/dev/null | grep -q "uid=0"; then
        log_error "Test 6 failed: Container running as root (security risk)"
        ((errors++))
    else
        log_success "Test 6 passed: Container running as non-root user"
    fi
    
    # Summary
    if [ $errors -eq 0 ]; then
        log_success "All tests passed successfully!"
        return 0
    else
        log_error "Tests failed with $errors errors"
        return 1
    fi
}

# Clean up build artifacts
clean_artifacts() {
    log_info "Cleaning up build artifacts..."
    
    # Remove test output directory
    if [ -d "${SCRIPT_DIR}/test_output" ]; then
        rm -rf "${SCRIPT_DIR}/test_output"
        log_success "Removed test output directory"
    fi
    
    # Remove dangling Docker images
    if docker images -f "dangling=true" -q | grep -q .; then
        docker rmi $(docker images -f "dangling=true" -q) 2>/dev/null || true
        log_success "Removed dangling Docker images"
    fi
    
    log_success "Cleanup completed"
}

# Check for required tools
check_prerequisites() {
    local missing_tools=()
    
    # Check for Docker
    if ! command -v docker >/dev/null 2>&1; then
        missing_tools+=("docker")
    fi
    
    # Check for Git (optional, for commit hash)
    if ! command -v git >/dev/null 2>&1; then
        log_warning "Git not available - commit hash will be 'unknown'"
    fi
    
    # Check for yamllint (optional)
    if ! command -v yamllint >/dev/null 2>&1; then
        log_warning "yamllint not available - YAML syntax checking disabled"
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_error "Please install the required tools and try again"
        exit 1
    fi
}

# Main script logic
main() {
    local command="${1:-}"
    local tag="$VERSION"
    local push_flag="false"
    local verbose="false"
    
    # Parse arguments
    shift || true
    while [[ $# -gt 0 ]]; do
        case $1 in
            --registry)
                REGISTRY="$2"
                shift 2
                ;;
            --tag)
                tag="$2"
                shift 2
                ;;
            --push)
                push_flag="true"
                shift
                ;;
            --verbose)
                verbose="true"
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Execute command
    case "$command" in
        validate)
            log_info "Starting validation process..."
            validate_prompts && validate_catalogs && validate_docker
            ;;
        build)
            log_info "Starting build process..."
            validate_docker && build_image "$tag" "$push_flag"
            ;;
        test)
            log_info "Starting test process..."
            run_tests "$tag" "$verbose"
            ;;
        deploy)
            log_info "Starting deployment process..."
            log_warning "Deploy command not yet implemented - use MCP Gateway UI"
            log_info "Production catalog files are ready for MCP Gateway deployment"
            ;;
        clean)
            clean_artifacts
            ;;
        all)
            log_info "Starting full build and test cycle..."
            if validate_prompts && validate_catalogs && validate_docker; then
                if build_image "$tag" "$push_flag"; then
                    run_tests "$tag" "$verbose"
                else
                    log_error "Build failed, skipping tests"
                    exit 1
                fi
            else
                log_error "Validation failed, skipping build and tests"
                exit 1
            fi
            ;;
        "")
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Script entry point
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Print banner
    echo "================================================"
    echo "MCP Prompt Loader - Production Deployment v${VERSION}"
    echo "================================================"
    echo
    
    # Check prerequisites
    check_prerequisites
    
    # Run main function with all arguments
    main "$@"
fi