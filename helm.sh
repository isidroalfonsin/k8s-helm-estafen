#!/bin/bash
# Makefile-style commands for managing the Estafen Helm Chart

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
CHART_NAME="estafen"
NAMESPACE="estafen"
RELEASE_NAME="estafen"

# Help
help() {
    echo -e "${GREEN}Estafen Helm Chart - Available Commands${NC}"
    echo ""
    echo "  make lint              - Lint the Helm chart"
    echo "  make template          - Generate Kubernetes manifests"
    echo "  make install           - Install the chart"
    echo "  make install-aws       - Install with AWS configuration"
    echo "  make install-gcp       - Install with GCP configuration"
    echo "  make install-prod      - Install with production values"
    echo "  make upgrade           - Upgrade the release"
    echo "  make uninstall         - Uninstall the release"
    echo "  make status            - Show release status"
    echo "  make values            - Show computed values"
    echo "  make test              - Run helm test"
    echo "  make package           - Package the chart"
    echo "  make deps              - Update dependencies"
    echo "  make dry-run           - Dry run installation"
    echo "  make verify            - Verify installation"
    echo "  make logs              - Show pod logs"
    echo "  make describe          - Describe pods"
    echo "  make port-forward      - Port forward to service"
    echo "  make monitoring        - Install monitoring stack"
    echo ""
}

# Lint
lint() {
    echo -e "${YELLOW}Linting Helm chart...${NC}"
    helm lint .
    echo -e "${GREEN}✓ Lint completed${NC}"
}

# Template
template() {
    echo -e "${YELLOW}Generating Kubernetes manifests...${NC}"
    helm template ${RELEASE_NAME} . --debug
}

# Install
install() {
    echo -e "${YELLOW}Installing ${CHART_NAME}...${NC}"
    helm install ${RELEASE_NAME} . \
        --namespace ${NAMESPACE} \
        --create-namespace
    echo -e "${GREEN}✓ Installation completed${NC}"
}

# Install AWS
install_aws() {
    echo -e "${YELLOW}Installing ${CHART_NAME} with AWS configuration...${NC}"
    helm install ${RELEASE_NAME} . \
        --namespace ${NAMESPACE} \
        --create-namespace \
        --set cloudProvider=aws \
        --set aws.region=us-east-1 \
        --set karpenter.enabled=true
    echo -e "${GREEN}✓ Installation completed${NC}"
}

# Install GCP
install_gcp() {
    echo -e "${YELLOW}Installing ${CHART_NAME} with GCP configuration...${NC}"
    read -p "Enter GCP Project ID: " PROJECT_ID
    helm install ${RELEASE_NAME} . \
        --namespace ${NAMESPACE} \
        --create-namespace \
        --set cloudProvider=gcp \
        --set gcp.region=us-central1 \
        --set gcp.projectId=${PROJECT_ID} \
        --set karpenter.enabled=false
    echo -e "${GREEN}✓ Installation completed${NC}"
}

# Install Production
install_prod() {
    echo -e "${YELLOW}Installing ${CHART_NAME} with production values...${NC}"
    helm install ${RELEASE_NAME} . \
        --namespace ${NAMESPACE} \
        --create-namespace \
        --values values-production.yaml
    echo -e "${GREEN}✓ Installation completed${NC}"
}

# Upgrade
upgrade() {
    echo -e "${YELLOW}Upgrading ${RELEASE_NAME}...${NC}"
    helm upgrade ${RELEASE_NAME} . \
        --namespace ${NAMESPACE}
    echo -e "${GREEN}✓ Upgrade completed${NC}"
}

# Uninstall
uninstall() {
    echo -e "${YELLOW}Uninstalling ${RELEASE_NAME}...${NC}"
    helm uninstall ${RELEASE_NAME} -n ${NAMESPACE}
    kubectl delete namespace ${NAMESPACE}
    echo -e "${GREEN}✓ Uninstallation completed${NC}"
}

# Status
status() {
    echo -e "${YELLOW}Checking status...${NC}"
    helm status ${RELEASE_NAME} -n ${NAMESPACE}
}

# Values
values() {
    echo -e "${YELLOW}Showing computed values...${NC}"
    helm get values ${RELEASE_NAME} -n ${NAMESPACE}
}

# Test
test() {
    echo -e "${YELLOW}Running tests...${NC}"
    helm test ${RELEASE_NAME} -n ${NAMESPACE}
}

# Package
package() {
    echo -e "${YELLOW}Packaging chart...${NC}"
    helm package .
    echo -e "${GREEN}✓ Package created${NC}"
}

# Dependencies
deps() {
    echo -e "${YELLOW}Updating dependencies...${NC}"
    helm dependency update
    echo -e "${GREEN}✓ Dependencies updated${NC}"
}

# Dry Run
dry_run() {
    echo -e "${YELLOW}Running dry-run installation...${NC}"
    helm install ${RELEASE_NAME} . \
        --namespace ${NAMESPACE} \
        --dry-run --debug
}

# Verify
verify() {
    echo -e "${YELLOW}Verifying installation...${NC}"
    echo ""
    echo "=== Pods ==="
    kubectl get pods -n ${NAMESPACE}
    echo ""
    echo "=== Services ==="
    kubectl get svc -n ${NAMESPACE}
    echo ""
    echo "=== Ingress ==="
    kubectl get ingress -n ${NAMESPACE}
    echo ""
    echo "=== HPA ==="
    kubectl get hpa -n ${NAMESPACE}
    echo ""
    echo "=== Secrets ==="
    kubectl get secrets -n ${NAMESPACE}
    echo -e "${GREEN}✓ Verification completed${NC}"
}

# Logs
logs() {
    echo -e "${YELLOW}Showing pod logs...${NC}"
    kubectl logs -n ${NAMESPACE} -l app.kubernetes.io/name=${CHART_NAME} --tail=50 -f
}

# Describe
describe() {
    echo -e "${YELLOW}Describing pods...${NC}"
    kubectl describe pods -n ${NAMESPACE} -l app.kubernetes.io/name=${CHART_NAME}
}

# Port Forward
port_forward() {
    echo -e "${YELLOW}Port forwarding to service...${NC}"
    kubectl port-forward -n ${NAMESPACE} svc/${RELEASE_NAME} 8080:80
}

# Monitoring
monitoring() {
    echo -e "${YELLOW}Installing monitoring stack...${NC}"
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --create-namespace
    echo -e "${GREEN}✓ Monitoring stack installed${NC}"
    echo ""
    echo "Access Grafana:"
    echo "  kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
    echo "  Default credentials: admin / prom-operator"
}

# Main
case "$1" in
    lint)
        lint
        ;;
    template)
        template
        ;;
    install)
        install
        ;;
    install-aws)
        install_aws
        ;;
    install-gcp)
        install_gcp
        ;;
    install-prod)
        install_prod
        ;;
    upgrade)
        upgrade
        ;;
    uninstall)
        uninstall
        ;;
    status)
        status
        ;;
    values)
        values
        ;;
    test)
        test
        ;;
    package)
        package
        ;;
    deps)
        deps
        ;;
    dry-run)
        dry_run
        ;;
    verify)
        verify
        ;;
    logs)
        logs
        ;;
    describe)
        describe
        ;;
    port-forward)
        port_forward
        ;;
    monitoring)
        monitoring
        ;;
    help|*)
        help
        ;;
esac
