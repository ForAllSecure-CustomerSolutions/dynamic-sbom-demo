# Dynamic Sbom Demo

## Overview

The `mdsbom-demo` project is used to run `mdsbom` locally by leveraging Docker in Docker. This leverages tools like Anchore, Docker Scout, and Trivy to analyze and report on the contents and security status of Docker images.

## Prerequisites

Before you begin, ensure you have the following installed:

- Docker: To build, run, and manage containers. That's it!

## Project Features

### Docker Image and Container Management

The project includes a Makefile that simplifies common Docker tasks such as:

- **Building the Docker Image**: Creates the Docker image for the `mdsbom-demo` project.
- **Starting the Demo**: Runs the Docker container for the project, and inside it, pulls and starts a container to scan and generate an SBOM report.
- **Stopping and Cleaning Up**: Stops and removes the Docker containers and images to clean up the environment.

### SBOM Report Generation

The project supports generating detailed SBOM reports using multiple tools:

- **Anchore**
- **Docker Scout**
- **Trivy**


## Usage

The project uses a Makefile to manage its operations. Below are the primary commands you can use:

1. **Build the Docker Image**

   Build the Docker image for the project:

   ```
   make build
   ```

2. **Start the Demo**

   Start the Docker container and the Redis container within it:

   ```
   make start
   ```

3. **Generate SBOM Reports**

   - Using Anchore:

     ```
     make anchore
     ```

   - Using Docker Scout:

     ```
     make scout
     ```

   - Using Trivy:

     ```
     make trivy
     ```

4. **Open a Shell Inside the Demo Container**

   Access a bash shell for interactive use:

   ```
   make shell
   ```

5. **Stop the Demo**

   Stop the running Docker containers:

   ```
   make stop
   ```

6. **Clean Up**

   Stop and remove the Docker containers and image:

   ```
   make clean
   ```


