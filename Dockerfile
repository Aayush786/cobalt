FROM node:24-alpine

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
ENV NPM_CONFIG_LOGLEVEL=warn

# Install tools needed for native compilation (isolated-vm)
RUN apk add --no-cache python3 alpine-sdk corepack

WORKDIR /app
RUN mkdir -p /app /pnpm && chown -R node:node /app /pnpm

USER node

# Copy the package files from the root context
COPY --chown=node:node package.json pnpm-lock.yaml* ./

RUN corepack enable && corepack prepare --activate
RUN pnpm install --frozen-lockfile

# Copy the entire project layout (including the api/ directory)
COPY --chown=node:node . /app

EXPOSE 3000

# Run using the exact structural path verified from your workspace
CMD [ "node", "/app/api/src/cobalt.js" ]
