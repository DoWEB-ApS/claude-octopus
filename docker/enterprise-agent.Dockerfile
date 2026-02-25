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
# Task Master is required as a full native CLI in the image.
RUN npm install -g @anthropic-ai/claude-code @openai/codex @google/gemini-cli task-master-ai

WORKDIR /project
COPY docker/entrypoint-enterprise.sh /usr/local/bin/entrypoint-enterprise.sh
RUN chmod +x /usr/local/bin/entrypoint-enterprise.sh

# Official node image already includes non-root user "node" (uid 1000).
USER node

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint-enterprise.sh"]
CMD ["bash"]
