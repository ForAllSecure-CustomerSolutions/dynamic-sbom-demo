# Makefile for Docker image and container management

# Image and container names
IMAGE_NAME := mdsbom-demo
CONTAINER_NAME := mdsbom-demo
SCANNED_IMAGE := redis:7.4-rc-bookworm
SCANNED_CONTAINER_NAME := scanned

# Define phony targets for make
.PHONY: build start clean

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Start the demo and pull Redis image inside the demo container
start: build
	docker run -d --privileged --name $(CONTAINER_NAME) $(IMAGE_NAME)
	docker exec $(CONTAINER_NAME) docker run -d --name $(SCANNED_CONTAINER_NAME) $(SCANNED_IMAGE)
	sleep 5
	docker exec $(CONTAINER_NAME) docker stop $(SCANNED_CONTAINER_NAME)

# Generate an report based off of anchore
anchore:
	docker exec -it $(CONTAINER_NAME) mdsbom anchore --full-summary $(SCANNED_IMAGE)

# Generate an report based off of scout
scout:
	# docker exec -it $(CONTAINER_NAME) mdsbom scout --full-summary $(SCANNED_IMAGE)
	docker exec -it $(CONTAINER_NAME) docker scout sbom --format spdx --output scout-sbom.json $(SCANNED_IMAGE)
	docker exec -it $(CONTAINER_NAME) mdsbom report --full-summary --sbom-report-source scout-sbom.json redis:7.4-rc-bookworm

# # Generate an report based off of trivy
trivy:
	docker exec -it $(CONTAINER_NAME) mdsbom trivy --full-summary $(SCANNED_IMAGE)
# Bash shell into the demo container
shell:
	docker exec -it $(CONTAINER_NAME) bash

# Stop the demo
stop:
	-@docker ps -q --filter "name=$(CONTAINER_NAME)" | xargs -r docker stop
	-@docker ps -aq --filter "name=$(CONTAINER_NAME)" | xargs -r docker rm

# Stop and remove the running container, and remove the Docker image
clean: stop
	-@docker images -q $(IMAGE_NAME) | xargs -r docker rmi

