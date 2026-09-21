# Use official n8n image as base (Alpine-based)
# FROM n8nio/n8n:latest

# Build a compatible Bash binary separately
FROM alpine:3.22 AS bash-source
RUN apk add --no-cache bash

FROM n8nio/n8n:2.20.0

# Switch to root to install packages
USER root

# Install curl (Alpine package manager)
# apk is intentionally absent/locked in this n8n image.
# Add Bash directly instead, with only its runtime libraries.
COPY --from=bash-source /bin/bash /bin/bash
COPY --from=bash-source /usr/lib/libreadline.so.8* /usr/lib/
COPY --from=bash-source /usr/lib/libhistory.so.8* /usr/lib/
COPY --from=bash-source /usr/lib/libncursesw.so.6* /usr/lib/
RUN ln -sf /bin/bash /usr/bin/bash

# Set environment variables
ENV NODE_ENV=production
ENV N8N_SECURE_COOKIE=false
# ENV NODE_VERSION=22.19.0
# ENV YARN_VERSION=1.22.22
# ENV NODE_ICU_DATA=/usr/local/lib/node_modules/full-icu

# dynamic proxy by cloudflare (must be set in cloud container/instance settings)
# ENV WEBHOOK_URL=https://aimee-unmodest-pseudoartistically.ngrok-free.dev

# Enforce correct permissions on settings file
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# Set working directory
WORKDIR /home/node

# Set labels
LABEL org.opencontainers.image.description="Workflow Automation Tool"
LABEL org.opencontainers.image.source="https://github.com/n8n-io/n8n"
LABEL org.opencontainers.image.title="n8n"
LABEL org.opencontainers.image.url="https://n8n.io"
# LABEL org.opencontainers.image.version="2.0.2"

# Expose n8n port
EXPOSE 5678

# Switch back to n8n user
USER node

# Ensure n8n binary is in PATH
ENV PATH=/usr/local/bin:$PATH
