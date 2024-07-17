# Use Debian slim as the base image
FROM debian:12-slim

# Install necessary packages
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release 

# Add Docker’s official GPG key
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the Docker stable repository
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

# Download mdsbom .deb package
RUN curl -fsSL https://app.mayhem.security/cli/mdsbom/linux/latest/mdsbom.deb -o /tmp/mdsbom.deb \
    && dpkg -i /tmp/mdsbom.deb

RUN curl -sSL https://app.mayhem.security/cli/mdsbom/linux/latest/mdsbom.deb -O \
    && dpkg -i mdsbom.deb 

# Install syft
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin 
    
# Install grype
RUN curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

# Install trivy
RUN apt-get update && apt-get -y install skopeo umoci \
    && curl -L -o trivy_0.53.0_Linux-64bit.deb https://github.com/aquasecurity/trivy/releases/download/v0.53.0/trivy_0.53.0_Linux-64bit.deb && dpkg -i trivy_0.53.0_Linux-64bit.deb

# Install docker scout
RUN mkdir /root/.docker \
    && curl -fsSL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh -o install-scout.sh \
    && sh install-scout.sh

# Clean up unnecessary files
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./docker/daemon.json /etc/docker/
COPY ./docker/entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Configure Docker to be started on run
CMD ["/entrypoint.sh"]


