# Use official n8n image as base (Alpine-based)
# FROM n8nio/n8n:latest
FROM n8nio/n8n:2.0.3

# Switch to root to install packages
USER root

# Install curl (Alpine package manager)
RUN apk add --no-cache curl bash

# Set environment variables
ENV NODE_ENV=production
ENV N8N_SECURE_COOKIE=false
ENV NODE_VERSION=22.19.0
ENV YARN_VERSION=1.22.22
ENV NODE_ICU_DATA=/usr/local/lib/node_modules/full-icu
ENV WEBHOOK_URL=https://aimee-unmodest-pseudoartistically.ngrok-free.dev

# Enforce correct permissions on settings file
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# Set working directory
WORKDIR /home/node

# Set labels
LABEL org.opencontainers.image.description="Workflow Automation Tool"
LABEL org.opencontainers.image.source="https://github.com/n8n-io/n8n"
LABEL org.opencontainers.image.title="n8n"
LABEL org.opencontainers.image.url="https://n8n.io"
LABEL org.opencontainers.image.version="2.0.2"

# Expose n8n port
EXPOSE 5678

# Switch back to n8n user
USER node

# Ensure n8n binary is in PATH
ENV PATH=/usr/local/bin:$PATH


