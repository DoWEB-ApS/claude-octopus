FROM node:20-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    make \
    openssh-client \
    python3 \
    ripgrep \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Enterprise baseline CLIs used by the orchestrator.
RUN npm install -g @anthropic-ai/claude-code @openai/codex @google/gemini-cli \
    && (npm install -g task-master-ai || echo "WARN: task-master-ai npm package not available at build time; wrapper will use npx fallback")

WORKDIR /workspace
COPY docker/entrypoint-enterprise.sh /usr/local/bin/entrypoint-enterprise.sh
COPY docker/task-master-wrapper.sh /usr/local/bin/task-master
RUN chmod +x /usr/local/bin/entrypoint-enterprise.sh
RUN chmod +x /usr/local/bin/task-master \
    && ln -sf /usr/local/bin/task-master /usr/local/bin/taskmaster

# Official node image already includes non-root user "node" (uid 1000).
USER node

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint-enterprise.sh"]
CMD ["bash"]
