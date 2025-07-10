#!/bin/bash

# Deployment Script with Prerequisite Checking
# Description: Deploys application with comprehensive prerequisite validation

set -e  # Exit on any error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/deploy.config"

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

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check for essential tools
    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi
    
    if ! command -v curl &> /dev/null; then
        missing_tools+=("curl")
    fi
    
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi
    
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi
    
    # Check if any tools are missing
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install the missing tools and try again."
        log_info "On Ubuntu/Debian: sudo apt update && sudo apt install -y ${missing_tools[*]}"
        exit 1
    fi
    
    log_success "All prerequisites are satisfied!"
}

# Function to validate configuration
validate_config() {
    log_info "Validating configuration..."
    
    if [ -f "$CONFIG_FILE" ]; then
        # Parse configuration with jq
        if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
            log_error "Invalid JSON in configuration file: $CONFIG_FILE"
            exit 1
        fi
        
        # Extract configuration values
        APP_NAME=$(jq -r '.app_name // "default-app"' "$CONFIG_FILE")
        ENVIRONMENT=$(jq -r '.environment // "development"' "$CONFIG_FILE")
        VERSION=$(jq -r '.version // "latest"' "$CONFIG_FILE")
        
        log_info "Configuration loaded: $APP_NAME v$VERSION ($ENVIRONMENT)"
    else
        log_warning "No configuration file found. Using defaults."
        APP_NAME="default-app"
        ENVIRONMENT="development"
        VERSION="latest"
    fi
}

# Function to build application
build_application() {
    log_info "Building application..."
    
    if [ -f "$PROJECT_ROOT/Dockerfile" ]; then
        log_info "Building Docker image: $APP_NAME:$VERSION"
        docker build -t "$APP_NAME:$VERSION" "$PROJECT_ROOT"
        log_success "Docker image built successfully!"
    else
        log_warning "No Dockerfile found. Skipping Docker build."
    fi
}

# Function to deploy application
deploy_application() {
    log_info "Deploying application..."
    
    case "$ENVIRONMENT" in
        "development")
            deploy_to_development
            ;;
        "staging")
            deploy_to_staging
            ;;
        "production")
            deploy_to_production
            ;;
        *)
            log_error "Unknown environment: $ENVIRONMENT"
            exit 1
            ;;
    esac
}

# Environment-specific deployment functions
deploy_to_development() {
    log_info "Deploying to development environment..."
    # Add development-specific deployment logic here
    log_success "Deployed to development!"
}

deploy_to_staging() {
    log_info "Deploying to staging environment..."
    # Add staging-specific deployment logic here
    log_success "Deployed to staging!"
}

deploy_to_production() {
    log_info "Deploying to production environment..."
    # Add production-specific deployment logic here
    log_success "Deployed to production!"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  deploy          Deploy the application"
    echo "  build           Build the application only"
    echo "  check           Check prerequisites only"
    echo "  help            Show this help message"
    echo ""
    echo "Options:"
    echo "  --env <env>     Override environment (development|staging|production)"
    echo "  --version <v>   Override version"
    echo ""
}

# Main function
main() {
    local command="${1:-help}"
    shift || true
    
    # Parse command line options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --env)
                ENVIRONMENT="$2"
                shift 2
                ;;
            --version)
                VERSION="$2"
                shift 2
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    case "$command" in
        "deploy")
            check_prerequisites
            validate_config
            build_application
            deploy_application
            ;;
        "build")
            check_prerequisites
            validate_config
            build_application
            ;;
        "check")
            check_prerequisites
            ;;
        "help")
            show_usage
            ;;
        *)
            log_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"