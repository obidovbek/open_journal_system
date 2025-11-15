#!/bin/bash

# OJS FSTU Kubernetes Database Connectivity Fix
# This script diagnoses and fixes database connectivity issues

set -e

echo "🔍 OJS FSTU Database Connectivity Diagnostic & Fix"
echo "=================================================="

NAMESPACE="ojs-fstu"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to check if namespace exists
check_namespace() {
    if kubectl get namespace $NAMESPACE >/dev/null 2>&1; then
        echo "✅ Namespace $NAMESPACE exists"
        return 0
    else
        echo "❌ Namespace $NAMESPACE does not exist"
        return 1
    fi
}

# Function to check pod status
check_pods() {
    echo ""
    echo "📊 Checking Pod Status:"
    echo "======================="
    kubectl get pods -n $NAMESPACE -o wide || echo "❌ No pods found in namespace $NAMESPACE"
}

# Function to check services
check_services() {
    echo ""
    echo "🌐 Checking Services:"
    echo "===================="
    kubectl get svc -n $NAMESPACE || echo "❌ No services found in namespace $NAMESPACE"
}

# Function to check PVCs
check_pvcs() {
    echo ""
    echo "💾 Checking Persistent Volume Claims:"
    echo "===================================="
    kubectl get pvc -n $NAMESPACE || echo "❌ No PVCs found in namespace $NAMESPACE"
}

# Function to check deployments
check_deployments() {
    echo ""
    echo "🚀 Checking Deployments:"
    echo "========================"
    kubectl get deployments -n $NAMESPACE || echo "❌ No deployments found in namespace $NAMESPACE"
}

# Function to show MySQL logs
show_mysql_logs() {
    echo ""
    echo "📋 MySQL Pod Logs (last 20 lines):"
    echo "=================================="
    kubectl logs -l app=ojs-mysql-fstu -n $NAMESPACE --tail=20 || echo "❌ Cannot get MySQL logs"
}

# Function to show OJS logs
show_ojs_logs() {
    echo ""
    echo "📋 OJS Pod Logs (last 20 lines):"
    echo "==============================="
    kubectl logs -l app=ojs-fstu -n $NAMESPACE --tail=20 || echo "❌ Cannot get OJS logs"
}

# Function to test database connectivity
test_db_connectivity() {
    echo ""
    echo "🔌 Testing Database Connectivity:"
    echo "================================="
    
    # Get MySQL pod name
    MYSQL_POD=$(kubectl get pods -n $NAMESPACE -l app=ojs-mysql-fstu -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    
    if [ -z "$MYSQL_POD" ]; then
        echo "❌ No MySQL pod found"
        return 1
    fi
    
    echo "Testing connection to MySQL pod: $MYSQL_POD"
    
    # Test if MySQL is accepting connections
    kubectl exec -n $NAMESPACE $MYSQL_POD -- mysqladmin ping -h localhost || {
        echo "❌ MySQL is not responding to ping"
        return 1
    }
    
    echo "✅ MySQL is responding"
    
    # Test if database exists
    kubectl exec -n $NAMESPACE $MYSQL_POD -- mysql -u root -psecure_mysql_root_password -e "SHOW DATABASES;" | grep ojs_fstu_db && {
        echo "✅ Database ojs_fstu_db exists"
    } || {
        echo "❌ Database ojs_fstu_db does not exist"
        echo "🔧 Creating database..."
        kubectl exec -n $NAMESPACE $MYSQL_POD -- mysql -u root -psecure_mysql_root_password -e "CREATE DATABASE IF NOT EXISTS ojs_fstu_db;"
        kubectl exec -n $NAMESPACE $MYSQL_POD -- mysql -u root -psecure_mysql_root_password -e "GRANT ALL PRIVILEGES ON ojs_fstu_db.* TO 'ojs_fstu_user'@'%';"
        kubectl exec -n $NAMESPACE $MYSQL_POD -- mysql -u root -psecure_mysql_root_password -e "FLUSH PRIVILEGES;"
    }
}

# Function to fix PVC issues
fix_pvc_issues() {
    echo ""
    echo "🔧 Fixing PVC Issues:"
    echo "===================="
    
    # Check if PVCs are bound
    PENDING_PVCS=$(kubectl get pvc -n $NAMESPACE --no-headers | grep Pending | wc -l)
    
    if [ "$PENDING_PVCS" -gt 0 ]; then
        echo "⚠️  Found $PENDING_PVCS pending PVCs. Attempting to fix..."
        
        # Delete pending PVCs
        kubectl get pvc -n $NAMESPACE --no-headers | grep Pending | awk '{print $1}' | xargs -r kubectl delete pvc -n $NAMESPACE
        
        # Apply fixed PVC configuration
        if [ -f "$SCRIPT_DIR/ojs-pvc-fixed.yaml" ]; then
            echo "Applying fixed PVC configuration..."
            kubectl apply -f "$SCRIPT_DIR/ojs-pvc-fixed.yaml"
        else
            echo "Creating dynamic PVC configuration..."
            kubectl apply -f "$SCRIPT_DIR/ojs-pvc.yaml"
        fi
        
        # Wait for PVCs to bind
        echo "⏳ Waiting for PVCs to bind..."
        kubectl wait --for=condition=Bound pvc --all -n $NAMESPACE --timeout=60s || {
            echo "⚠️  PVCs still not bound. Check storage class configuration."
        }
    else
        echo "✅ All PVCs are bound"
    fi
}

# Function to restart deployments
restart_deployments() {
    echo ""
    echo "🔄 Restarting Deployments:"
    echo "========================="
    
    # Restart MySQL first
    if kubectl get deployment ojs-mysql-deployment-fstu -n $NAMESPACE >/dev/null 2>&1; then
        echo "Restarting MySQL deployment..."
        kubectl rollout restart deployment/ojs-mysql-deployment-fstu -n $NAMESPACE
        kubectl rollout status deployment/ojs-mysql-deployment-fstu -n $NAMESPACE --timeout=300s
    fi
    
    # Then restart OJS
    if kubectl get deployment ojs-deployment-fstu -n $NAMESPACE >/dev/null 2>&1; then
        echo "Restarting OJS deployment..."
        kubectl rollout restart deployment/ojs-deployment-fstu -n $NAMESPACE
        kubectl rollout status deployment/ojs-deployment-fstu -n $NAMESPACE --timeout=300s
    fi
}

# Function to apply complete configuration
apply_complete_config() {
    echo ""
    echo "🚀 Applying Complete Configuration:"
    echo "=================================="
    
    # Apply in correct order
    echo "1. Creating namespace..."
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    
    echo "2. Applying ConfigMap and Secrets..."
    kubectl apply -f "$SCRIPT_DIR/ojs-configmap.yaml"
    
    echo "3. Applying PVCs..."
    if [ -f "$SCRIPT_DIR/ojs-pvc-fixed.yaml" ]; then
        kubectl apply -f "$SCRIPT_DIR/ojs-pvc-fixed.yaml"
    else
        kubectl apply -f "$SCRIPT_DIR/ojs-pvc.yaml"
    fi
    
    echo "4. Waiting for PVCs to bind..."
    kubectl wait --for=condition=Bound pvc --all -n $NAMESPACE --timeout=120s || {
        echo "⚠️  PVCs not bound. Continuing anyway..."
    }
    
    echo "5. Applying MySQL deployment..."
    kubectl apply -f "$SCRIPT_DIR/ojs-mysql-deployment.yaml"
    
    echo "6. Waiting for MySQL to be ready..."
    kubectl wait --for=condition=available deployment/ojs-mysql-deployment-fstu -n $NAMESPACE --timeout=300s || {
        echo "⚠️  MySQL deployment not ready. Check logs."
    }
    
    echo "7. Applying OJS deployment..."
    if [ -f "$SCRIPT_DIR/ojs-deployment-fixed.yaml" ]; then
        kubectl apply -f "$SCRIPT_DIR/ojs-deployment-fixed.yaml"
    else
        kubectl apply -f "$SCRIPT_DIR/ojs-deployment.yaml"
    fi
    
    echo "8. Applying Ingress..."
    kubectl apply -f "$SCRIPT_DIR/ojs-ingress.yaml"
    
    echo "9. Waiting for OJS to be ready..."
    kubectl wait --for=condition=available deployment/ojs-deployment-fstu -n $NAMESPACE --timeout=300s || {
        echo "⚠️  OJS deployment not ready. Check logs."
    }
}

# Main execution
main() {
    echo "Starting diagnostic..."
    
    # Check if namespace exists
    if ! check_namespace; then
        echo "🔧 Namespace missing. Will create during configuration apply."
    fi
    
    # Run diagnostics
    check_pods
    check_services
    check_pvcs
    check_deployments
    
    # Show logs if pods exist
    show_mysql_logs
    show_ojs_logs
    
    # Ask user what to do
    echo ""
    echo "🤔 What would you like to do?"
    echo "1) Fix PVC issues only"
    echo "2) Restart deployments only"
    echo "3) Apply complete configuration (recommended)"
    echo "4) Test database connectivity"
    echo "5) Show detailed logs"
    echo "6) Exit"
    
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1)
            fix_pvc_issues
            ;;
        2)
            restart_deployments
            ;;
        3)
            apply_complete_config
            echo ""
            echo "⏳ Waiting 30 seconds for services to stabilize..."
            sleep 30
            test_db_connectivity
            ;;
        4)
            test_db_connectivity
            ;;
        5)
            echo ""
            echo "📋 Detailed MySQL Logs:"
            kubectl logs -l app=ojs-mysql-fstu -n $NAMESPACE --tail=50 || echo "No MySQL logs available"
            echo ""
            echo "📋 Detailed OJS Logs:"
            kubectl logs -l app=ojs-fstu -n $NAMESPACE --tail=50 || echo "No OJS logs available"
            ;;
        6)
            echo "👋 Exiting..."
            exit 0
            ;;
        *)
            echo "❌ Invalid choice"
            exit 1
            ;;
    esac
    
    echo ""
    echo "✅ Operation completed!"
    echo ""
    echo "🌐 After fixing, try accessing: https://publications.fstu.uz/index/install"
    echo ""
    echo "🔍 To monitor:"
    echo "   kubectl get pods -n $NAMESPACE -w"
    echo "   kubectl logs -f deployment/ojs-mysql-deployment-fstu -n $NAMESPACE"
    echo "   kubectl logs -f deployment/ojs-deployment-fstu -n $NAMESPACE"
}

# Run main function
main "$@" 