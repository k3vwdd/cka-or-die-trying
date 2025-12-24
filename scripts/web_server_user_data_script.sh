#!/bin/bash
#
# Jumpbox Bootstrap Script for Kubernetes the Hard Way
#
# Purpose: Prepares a jumpbox/bastion host with all necessary tools and binaries
#          for managing a Kubernetes cluster following the "Kubernetes the Hard Way" guide.
#
# What this script installs:
#   - System packages: wget, curl, vim, git, jq, unzip
#   - Kubernetes client tools: kubectl, etcdctl
#   - Additional tools: helm, k9s
#   - All Kubernetes binaries for cluster setup (controller, worker components)
#
# Requirements:
#   - Must run as root (typically via EC2 user-data)
#   - Internet connectivity
#   - Debian-based system (uses apt-get)
#
# Reference: https://github.com/kelseyhightower/kubernetes-the-hard-way
#
# Author: k3vwd
# Project: cka-or-die-trying
#

set -e
set -o pipefail

VERBOSE=false
LOG_FILE="/var/log/web_server_user_data_script.log"
WORK_DIR="$HOME/kubernetes-setup"
ARCH=$(dpkg --print-architecture)
KTHW_REPO_URL="https://github.com/kelseyhightower/kubernetes-the-hard-way.git"
CRICTL_VERSION="v1.32.0"
CONTAINERD_VERSION="2.1.0-beta.0"
CNI_PLUGINS_VERSION="v1.6.2"
ETCD_VERSION="v3.6.0-rc.3"

error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

log_error() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp ERROR: $1" >> "$LOG_FILE"
    echo "ERROR: $1" >&2
}

log_info() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_message="$timestamp INFO: $message"
    echo "$timestamp INFO: $message" >> "$LOG_FILE"
    echo "$timestamp INFO: $message"
}

debug() {
    if [ "$VERBOSE" = true ]; then
        echo "DEBUG: $1" >&2
    fi
}

cleanup() {
    log_info "Cleaning up after error..."
    if [ -d "$WORK_DIR" ]; then
        rm -rf "$WORK_DIR"
        log_info "Removed work directory after failure: $WORK_DIR"
    else
        log_info "Work directory did not exist, nothing to clean"
    fi
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        error_exit "This script must be run as root" 1
    fi

    # Check for dpkg (needed to determine architecture and for apt to work)
    if ! command -v dpkg &> /dev/null; then
        error_exit "Required command 'dpkg' not found - is this a Debian-based system?" 2
    fi

    # Check for apt-get (needed to install packages)
    if ! command -v apt-get &> /dev/null; then
        error_exit "Required command 'apt-get' not found - is this a Debian-based system?" 3
    fi
    
    # Note: git, wget, tar, etc. will be installed by install_packages() if missing
    
    log_info "All prerequisite checks passed"
}

install_packages() {
    log_info "Installing system packages..."

    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y || error_exit "apt-get update failed" 6

    apt-get install -y wget curl vim openssl git jq unzip || error_exit "Package installation failed" 7

    apt-get clean || error_exit "apt-get clean failed" 8

    log_info "System packages installed successfully"
}

setup_kubernetes_binaries() {
    log_info "Setting up Kubernetes binaries..."

    log_info "Creating work directory: $WORK_DIR"
    mkdir -p "$WORK_DIR" || error_exit "Failed to create work directory" 9
    cd "$WORK_DIR" || error_exit "Failed to cd to $WORK_DIR" 10
    debug "Working directory: $(pwd)"

    log_info "Cloning Kubernetes the Hard Way repository..."
    if [ -d "kubernetes-the-hard-way" ]; then
        log_info "Repository already exists, skipping clone"
    else
        git clone --depth 1 "$KTHW_REPO_URL" || error_exit "Git clone failed" 11
        log_info "Repository cloned successfully"
    fi

    log_info "Downloading Kubernetes binaries..."
    cd kubernetes-the-hard-way || error_exit "kubernetes-the-hard-way directory not found" 12

    if [ -d "downloads" ] && [ "$(ls -A downloads 2>/dev/null)" ]; then
        log_info "Binaries already downloaded, skipping download"
    else
        wget -q --show-progress \
            --https-only \
            --timestamping \
            -P downloads \
            -i downloads-${ARCH}.txt || error_exit "Binary download failed" 13
        log_info "Downloaded $(ls -1 downloads/ | wc -l) files"
    fi

    log_info "Extracting binaries..."
    mkdir -p downloads/{client,cni-plugins,controller,worker} || error_exit "Failed to create extraction directories" 14

    log_info "Extracting crictl..."
    tar -xvf downloads/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz \
        -C downloads/worker/ || error_exit "Failed to extract crictl" 15

    log_info "Extracting containerd..."
    tar -xvf downloads/containerd-${CONTAINERD_VERSION}-linux-${ARCH}.tar.gz \
        --strip-components 1 \
        -C downloads/worker/ || error_exit "Failed to extract containerd" 16

    log_info "Extracting CNI plugins..."
    tar -xvf downloads/cni-plugins-linux-${ARCH}-${CNI_PLUGINS_VERSION}.tgz \
        -C downloads/cni-plugins/ || error_exit "Failed to extract CNI plugins" 17

    log_info "Extracting etcd..."
    tar -xvf downloads/etcd-${ETCD_VERSION}-linux-${ARCH}.tar.gz \
        -C downloads/ \
        --strip-components 1 \
        etcd-${ETCD_VERSION}-linux-${ARCH}/etcdctl \
        etcd-${ETCD_VERSION}-linux-${ARCH}/etcd || error_exit "Failed to extract etcd" 18

    log_info "All binaries extracted successfully"

    log_info "Organizing binaries into directories..."

    mv downloads/{etcdctl,kubectl} downloads/client/ || error_exit "Failed to move client binaries" 19

    mv downloads/{etcd,kube-apiserver,kube-controller-manager,kube-scheduler} \
        downloads/controller/ || error_exit "Failed to move controller binaries" 20

    mv downloads/{kubelet,kube-proxy} downloads/worker/ || error_exit "Failed to move worker binaries" 21

    mv downloads/runc.${ARCH} downloads/worker/runc || error_exit "Failed to rename runc" 22

    chmod +x downloads/{client,cni-plugins,controller,worker}/* || error_exit "Failed to set executable permissions" 23

    log_info "Binaries organized successfully"
}

install_tools() {
    log_info "Installing client tools to /usr/local/bin..."

    if [ -f /usr/local/bin/kubectl ]; then
        log_info "kubectl already installed, overwriting with latest version"
    fi

    cp "$WORK_DIR/kubernetes-the-hard-way/downloads/client/kubectl" /usr/local/bin/ || error_exit "Failed to copy kubectl" 24

    cp "$WORK_DIR/kubernetes-the-hard-way/downloads/client/etcdctl" /usr/local/bin/ || error_exit "Failed to copy etcdctl" 25

    chmod +x /usr/local/bin/{kubectl,etcdctl} || error_exit "Failed to set permissions on client tools" 26

    log_info "Client tools installed to /usr/local/bin"

    log_info "Installing additional Kubernetes tools..."

    log_info "Installing Helm..."
    if command -v helm &> /dev/null; then
        log_info "Helm already installed, skipping"
    else
        curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash || log_info "Helm installation failed, continuing..."
    fi

    log_info "Installing k9s..."
    if command -v k9s &> /dev/null; then
        log_info "k9s already installed, skipping"
    else
        K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        if [ -n "$K9S_VERSION" ]; then
            wget -q https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${ARCH}.tar.gz -O /tmp/k9s.tar.gz || log_info "k9s download failed, continuing..."
            if [ -f /tmp/k9s.tar.gz ]; then
                tar -xzf /tmp/k9s.tar.gz -C /tmp || log_info "k9s extraction failed, continuing..."
                mv /tmp/k9s /usr/local/bin/ || log_info "k9s install failed, continuing..."
                chmod +x /usr/local/bin/k9s
                rm -f /tmp/k9s.tar.gz
                log_info "k9s installed successfully"
            fi
        else
            log_info "Could not determine k9s version, skipping"
        fi
    fi

    log_info "Additional tools installation complete"
}

verify_installation() {
    log_info "Verifying installation..."

    if kubectl version --client &> /dev/null; then
        KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | head -n1)
        log_info "kubectl verification passed: $KUBECTL_VERSION"
    else
        error_exit "kubectl verification failed" 27
    fi

    if etcdctl version &> /dev/null; then
        ETCDCTL_VERSION=$(etcdctl version | head -n1)
        log_info "etcdctl verification passed: $ETCDCTL_VERSION"
    else
        error_exit "etcdctl verification failed" 28
    fi

    CLIENT_COUNT=$(ls -1 "$WORK_DIR/kubernetes-the-hard-way/downloads/client" 2>/dev/null | wc -l)
    CONTROLLER_COUNT=$(ls -1 "$WORK_DIR/kubernetes-the-hard-way/downloads/controller" 2>/dev/null | wc -l)
    WORKER_COUNT=$(ls -1 "$WORK_DIR/kubernetes-the-hard-way/downloads/worker" 2>/dev/null | wc -l)

    log_info "Binary counts - Client: $CLIENT_COUNT, Controller: $CONTROLLER_COUNT, Worker: $WORKER_COUNT"

    log_info "Installed tools in /usr/local/bin:"
    ls -lh /usr/local/bin/{kubectl,etcdctl} 2>/dev/null || log_info "Some tools not found in /usr/local/bin"

    log_info "Installation verification complete"
}

# Set trap - only cleanup on error, not on successful exit
trap cleanup ERR SIGINT SIGTERM

main() {
    log_info "Starting jumpbox bootstrap script"

    check_prerequisites || error_exit "Prerequisites check failed" 29
    install_packages || error_exit "Package installation failed" 30
    setup_kubernetes_binaries || error_exit "Kubernetes binaries setup failed" 31
    install_tools || error_exit "Tools installation failed" 32
    verify_installation || error_exit "Installation verification failed" 33

    log_info "Jumpbox bootstrap completed successfully!"
    log_info "Client tools available at: /usr/local/bin/{kubectl,etcdctl}"
    log_info "All binaries available at: $WORK_DIR/kubernetes-the-hard-way/downloads"

    exit 0
}

main "$@"
