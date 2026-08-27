#!/bin/bash

set -e

echo "=========================================="
echo " CRM Deployment Server Setup"
echo "=========================================="

echo ""
echo "STEP 1: Updating Ubuntu..."
apt-get update -y
apt-get upgrade -y

echo ""
echo "STEP 2: Installing required packages..."
apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    jq \
    ca-certificates \
    gnupg \
    lsb-release \
    apt-transport-https \
    mysql-client

echo ""
echo "STEP 3: Installing AWS CLI..."

if command -v aws >/dev/null 2>&1; then
    echo "AWS CLI already installed."
else
    cd /tmp

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
        -o awscliv2.zip

    unzip -q awscliv2.zip

    ./aws/install

    rm -rf aws awscliv2.zip

    echo "AWS CLI installed successfully."
fi

echo ""
echo "STEP 4: Installing Docker..."

if command -v docker >/dev/null 2>&1; then
    echo "Docker already installed."
else
    curl -fsSL https://get.docker.com | sh
fi

echo ""
echo "STEP 5: Starting Docker..."

systemctl enable docker
systemctl start docker

if systemctl is-active --quiet docker; then
    echo "Docker is running."
else
    echo "ERROR: Docker is not running."
    exit 1
fi

echo ""
echo "STEP 6: Configuring Docker group..."

if getent group docker >/dev/null 2>&1; then
    echo "Docker group already exists."
else
    groupadd docker
    echo "Docker group created."
fi

if id ubuntu >/dev/null 2>&1; then
    usermod -aG docker ubuntu
    echo "ubuntu added to docker group."
fi

usermod -aG docker root

echo ""
echo "STEP 7: Installing kubectl..."

if command -v kubectl >/dev/null 2>&1; then
    echo "kubectl already installed."
else
    cd /tmp

    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

    curl -LO \
        "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

    install \
        -o root \
        -g root \
        -m 0755 \
        kubectl \
        /usr/local/bin/kubectl

    rm -f kubectl

    echo "kubectl installed successfully."
fi

echo ""
echo "STEP 8: Installing Helm..."

if command -v helm >/dev/null 2>&1; then
    echo "Helm already installed."
else
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    echo "Helm installed successfully."
fi

echo ""
echo "STEP 9: Verifying installations..."

echo ""
echo "AWS CLI:"
aws --version

echo ""
echo "Docker:"
docker --version

echo ""
echo "Docker service:"
systemctl is-active docker

echo ""
echo "kubectl:"
kubectl version --client

echo ""
echo "Helm:"
helm version --short

echo ""
echo "Git:"
git --version

echo ""
echo "MySQL Client:"
mysql --version

echo ""
echo "Docker group:"
getent group docker

echo ""
echo "=========================================="
echo " Setup Completed Successfully"
echo "=========================================="

echo ""
echo "Installed:"
echo "  Git"
echo "  AWS CLI"
echo "  Docker"
echo "  kubectl"
echo "  Helm"
echo "  MySQL Client"
echo "  jq"
echo "  curl"
echo "  wget"
echo "  unzip"

echo ""
echo "MySQL Server is NOT installed."
echo "The application database is AWS RDS MySQL."

echo ""
echo "Java and Maven are NOT installed on the host."
echo "Java and Maven are handled by the Docker build."

echo ""
echo "Docker group configured for:"
echo "  ubuntu"
echo "  root"

echo ""
echo "Please log out and SSH back in after this script."
echo "=========================================="
