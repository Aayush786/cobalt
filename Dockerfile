FROM node:24-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
ENV NPM_CONFIG_LOGLEVEL=warn

RUN corepack enable

FROM base AS build
RUN apk add --no-cache python3 alpine-sdk

WORKDIR /app
RUN mkdir -p /app /pnpm && chown -R node:node /app /pnpm

USER node
COPY --chown=node:node . /app

RUN corepack prepare --activate
RUN pnpm install

# --- ADDED STEP: Compile your TypeScript code first ---
RUN pnpm --filter=@imput/cobalt-api run build

# Deploying with full isolation. 
RUN mkdir -p /home/node/deploy && pnpm deploy /home/node/deploy --filter=@imput/cobalt-api --prod


# Final clean runtime stage
FROM base AS api
WORKDIR /app

RUN mkdir -p /app && chown -R node:node /app

USER node

# Copy the completely compiled bundle over
COPY --from=build --chown=node:node /home/node/deploy ./

EXPOSE 3000

# We will double-check this path below!
CMD [ "node", "dist/index.js" ]
