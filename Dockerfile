# Build curl and Bash against the same Alpine release as n8n 2.20.0.
FROM alpine:3.22 AS tools-source

RUN apk add --no-cache bash curl pax-utils \
    && mkdir -p /tool-root/bin /tool-root/usr/bin \
    && cp -L /bin/bash /tool-root/bin/bash \
    && cp -L /usr/bin/curl /tool-root/usr/bin/curl \
    && for binary in /bin/bash /usr/bin/curl; do \
        lddtree -l "$binary" | sort -u | while read -r library; do \
            [ -f "$library" ] || continue; \
            mkdir -p "/tool-root$(dirname "$library")"; \
            cp -L "$library" "/tool-root$library"; \
        done; \
    done

FROM n8nio/n8n:2.20.0

USER root

# n8n's final image intentionally has no apk. Add only the runtime files
# required by curl and Bash.
COPY --from=tools-source /tool-root/ /

RUN ln -sf /bin/bash /usr/bin/bash \
    && /usr/bin/curl --version \
    && /bin/bash --version

ENV NODE_ENV=production
ENV N8N_SECURE_COOKIE=false
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

WORKDIR /home/node

LABEL org.opencontainers.image.description="Workflow Automation Tool"
LABEL org.opencontainers.image.source="https://github.com/n8n-io/n8n"
LABEL org.opencontainers.image.title="n8n"
LABEL org.opencontainers.image.url="https://n8n.io"
LABEL org.opencontainers.image.version="2.20.0"

EXPOSE 5678

USER node

ENV PATH=/usr/local/bin:$PATH
