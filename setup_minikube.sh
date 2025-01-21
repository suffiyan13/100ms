#!/bin/bash

# Script to set up Minikube and deploy a Flask app on Kubernetes

echo "Starting Minikube setup and Flask app deployment..."

# Check and install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi

# Ensure the user is added to the Docker group
if ! groups | grep -q "docker"; then
    echo "Adding user to the Docker group..."
    sudo usermod -aG docker $USER
    echo "You may need to log out and log back in for the changes to take effect."
fi

# Check and install Minikube if not installed
if ! command -v minikube &> /dev/null; then
    echo "Minikube not found. Installing Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    echo "Minikube installed successfully."
else
    echo "Minikube is already installed."
fi

# Check and install kubectl if not installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Installing kubectl..."
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install kubectl /usr/local/bin/
    echo "kubectl installed successfully."
else
    echo "kubectl is already installed."
fi

# Start Minikube 
echo "Starting Minikube..."
minikube start --force
if [ $? -ne 0 ]; then
    echo "Failed to start Minikube. Please check the driver configuration and try again."
    exit 1
fi

# Configure kubectl to use Minikube context
echo "Configuring kubectl to use Minikube context..."
kubectl config use-context minikube

# Deploy the Flask app
echo "Deploying Flask app..."
kubectl apply -f deployment/flask-app-deployment.yaml
if [ $? -ne 0 ]; then
    echo "Failed to deploy Flask app. Please check the deployment YAML file."
    exit 1
fi

echo "Deploying Flask service..."
kubectl apply -f service/flask-app-service.yaml
if [ $? -ne 0 ]; then
    echo "Failed to deploy Flask service. Please check the service YAML file."
    exit 1
fi

# Retrieve the Minikube service URL
echo "Retrieving service URL..."
minikube service flask-app-service --url

echo "Setup and deployment completed successfully!"

