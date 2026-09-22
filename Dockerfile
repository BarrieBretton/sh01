# Build Bash from the Alpine release used by n8n 2.20.0.
FROM alpine:3.22 AS bash-source
RUN apk add --no-cache bash

# Build curl and collect its complete shared-library tree separately.
FROM alpine:3.22 AS curl-source
RUN apk add --no-cache curl pax-utils \
    && mkdir -p /opt/curl/bin /opt/curl/lib \
    && cp -L /usr/bin/curl /opt/curl/bin/curl \
    && lddtree -l /usr/bin/curl \
        | awk '/^\/usr\/lib\// { print }' \
        | sort -u \
        | while read -r library; do \
            cp -L "$library" /opt/curl/lib/; \
        done

FROM n8nio/n8n:2.20.0

USER root

# Preserve the Bash installation approach that was already working.
COPY --from=bash-source /bin/bash /bin/bash
COPY --from=bash-source /usr/lib/libreadline.so.8* /usr/lib/
COPY --from=bash-source /usr/lib/libhistory.so.8* /usr/lib/
COPY --from=bash-source /usr/lib/libncursesw.so.6* /usr/lib/
RUN ln -sf /bin/bash /usr/bin/bash

# Keep curl and its dependencies isolated from n8n's runtime libraries.
COPY --from=curl-source /opt/curl /opt/curl

RUN printf '%s\n' \
        '#!/bin/sh' \
        'export LD_LIBRARY_PATH="/opt/curl/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"' \
        'exec /opt/curl/bin/curl "$@"' \
        > /usr/local/bin/curl \
    && chmod 755 /usr/local/bin/curl \
    && curl --version \
    && bash --version

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
