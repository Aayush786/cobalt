FROM node:24-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
ENV NPM_CONFIG_LOGLEVEL=warn

RUN corepack enable

FROM base AS build
# isolated-vm requires native compilation tools to build successfully
RUN apk add --no-cache python3 alpine-sdk

WORKDIR /app
RUN mkdir -p /app /pnpm && chown -R node:node /app /pnpm

USER node
COPY --chown=node:node package.json pnpm-lock.yaml* ./

RUN corepack prepare --activate
RUN pnpm install --frozen-lockfile

# Copy the rest of your application source code
COPY --chown=node:node . /app

# Final clean runtime stage
FROM base AS api
WORKDIR /app

RUN mkdir -p /app && chown -R node:node /app

USER node

# Copy over everything built from the build stage
COPY --from=build --chown=node:node /app ./

# Expose Cobalt API's default port
EXPOSE 3000

# Launch directly using the native root path
CMD [ "node", "src/cobalt.js" ]
