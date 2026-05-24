FROM node:24-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
ENV NPM_CONFIG_LOGLEVEL=warn

RUN corepack enable

FROM base AS build
# isolated-vm needs native build tools, keeping python/sdk here
RUN apk add --no-cache python3 alpine-sdk

WORKDIR /app
RUN mkdir -p /app /pnpm && chown -R node:node /app /pnpm

USER node
COPY --chown=node:node . /app

RUN corepack prepare --activate
RUN pnpm install --frozen-lockfile

# Final clean runtime stage
FROM base AS api
WORKDIR /app

RUN mkdir -p /app && chown -R node:node /app

USER node

# Copy the entire workspace over so @imput/version-info is naturally available
COPY --from=build --chown=node:node /app ./

# Expose Cobalt API port
EXPOSE 3000

# Launch using your exact entry path defined in package.json
CMD [ "node", "apps/cobalt-api/src/cobalt.js" ]
