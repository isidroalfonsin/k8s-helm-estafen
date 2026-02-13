# Project: Online Boutique Deployment on Kubernetes with Helm

This project documents my process of adapting and deploying Google's "Online Boutique" (a microservices demo application) into a local Kubernetes environment using Helm.

The main goal was to take a complex microservices architecture (11 services + database) and build a custom Helm Chart from scratch to deploy it efficiently on my local machine.

## About the Application

I chose this application because it represents a real-world e-commerce scenario: it consists of a Frontend in Go, Cart Service in C#, Recommendation Service in Python, Payment Service in Node.js, and more. All services communicate with each other via gRPC, making it perfect for testing Kubernetes orchestration.

## Project Demo & Screenshots

Detailed screenshots and a video demonstration of the project's functionality added in screenshots folder to showcase the fully operational microservices architecture.

## What I Did

Instead of using loose Kubernetes manifests, I decided to package everything into a Helm Chart to have better control over the deployment.

1.  **Chart Structure**: I organized the project in a modular way, with a dedicated template for each microservice and a unified global configuration.
2.  **Flexible Configuration**: I made it easy to modify parameters like resources (CPU/RAM) or image versions without touching the template code.
3.  **Local Adaptation**: I tweaked the configuration to ensure it works smoothly in a local environment like Kind or Docker Desktop, which has different constraints than a cloud environment (like GCP or AWS).

## Challenges I Faced (and How I Solved Them)

During development, I encountered several interesting issues that I had to investigate and solve:

### 1. Images Not Downloading (ImagePullBackOff)

At first, nothing was working because the pods couldn't pull the images. I discovered that Docker Hub was having connection issues or rate limits with my local network.

**Solution:**
*   For Redis, I stopped using Docker Hub and switched to the Amazon Public ECR image, which downloaded without issues.
*   For the Google microservices, I pointed directly to Google's Artifact Registry (`us-central1-docker.pkg.dev`) instead of `gcr.io`, which was causing problems.
*   I modified the Load Generator configuration to use a lighter and more stable base image.

### 2. Frontend Constant Restarts

The frontend service would start and immediately crash. Checking the logs, I saw that the Go application was programmed to panic if a specific environment variable (`SHOPPING_ASSISTANT_SERVICE_ADDR`) was missing, even if that feature wasn't being used.

**Solution:** I injected a "dummy" variable into the configuration to bypass the strict check and allow the service to start correctly.

### 3. Conflicts with Google Cloud Tools

Some services (like the Payment Service) tried to automatically connect to the Google Cloud Profiler. Since they had no credentials in my local environment, they failed.

**Solution:** I explicitly disabled these debugging tools via environment variables to force the services to run in "isolated" mode.

## Final Result

I now have a functional Chart that deploys the entire online store with a single command. It serves as a complete testing environment running locally, which helped me understand how microservices interact and how to manage complex configurations with Helm.
