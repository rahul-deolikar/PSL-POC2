#!/bin/bash

# Local deployment script for ECS-EC2 cluster
# This script provides an alternative to GitHub Actions for local deployments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check terraform version
    TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
    log_info "Terraform version: $TERRAFORM_VERSION"
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials are not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    # Display AWS account info
    AWS_ACCOUNT=$(aws sts get-caller-identity --query 'Account' --output text)
    AWS_USER=$(aws sts get-caller-identity --query 'Arn' --output text)
    log_info "AWS Account: $AWS_ACCOUNT"
    log_info "AWS User: $AWS_USER"
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        log_warn "terraform.tfvars not found. Using default values from variables.tf"
        log_warn "Consider copying terraform.tfvars.example to terraform.tfvars and customizing values"
    fi
}

# Terraform operations
terraform_init() {
    log_info "Initializing Terraform..."
    terraform init
}

terraform_plan() {
    log_info "Running Terraform plan..."
    terraform plan -out=tfplan
}

terraform_apply() {
    log_info "Applying Terraform configuration..."
    terraform apply tfplan
    
    # Clean up plan file
    rm -f tfplan
    
    log_info "Deployment completed successfully!"
    log_info "ECS Cluster outputs:"
    terraform output
}

terraform_destroy() {
    log_warn "This will destroy all resources created by this Terraform configuration."
    read -p "Are you sure you want to proceed? (yes/no): " -r
    
    if [ "$REPLY" = "yes" ]; then
        log_info "Destroying Terraform resources..."
        terraform destroy -auto-approve
        log_info "Resources destroyed successfully!"
    else
        log_info "Destroy operation cancelled."
    fi
}

# Main script
main() {
    case "${1:-deploy}" in
        "deploy")
            check_prerequisites
            terraform_init
            terraform_plan
            
            echo ""
            log_warn "Review the plan above carefully."
            read -p "Do you want to apply these changes? (yes/no): " -r
            
            if [ "$REPLY" = "yes" ]; then
                terraform_apply
            else
                log_info "Deployment cancelled."
                rm -f tfplan
            fi
            ;;
        "plan")
            check_prerequisites
            terraform_init
            terraform_plan
            log_info "Plan saved to tfplan. Run './scripts/deploy.sh apply-plan' to apply."
            ;;
        "apply-plan")
            if [ ! -f "tfplan" ]; then
                log_error "No plan file found. Run './scripts/deploy.sh plan' first."
                exit 1
            fi
            terraform_apply
            ;;
        "destroy")
            terraform_destroy
            ;;
        "output")
            terraform output
            ;;
        *)
            echo "Usage: $0 {deploy|plan|apply-plan|destroy|output}"
            echo ""
            echo "Commands:"
            echo "  deploy     - Run plan and apply (default)"
            echo "  plan       - Run terraform plan only"
            echo "  apply-plan - Apply existing plan file"
            echo "  destroy    - Destroy all resources"
            echo "  output     - Show terraform outputs"
            exit 1
            ;;
    esac
}

main "$@"