FROM node:24-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable && corepack prepare pnpm@11.2.2 --activate

FROM base AS build
# 1. Install system build tools as root first
RUN apk add --no-cache python3 alpine-sdk

WORKDIR /app

# 2. Copy files and explicitly change ownership to the 'node' user
COPY --chown=node:node . /app

# 3. Switch to the non-root node user for the installation step
USER node

RUN pnpm install
RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

FROM base AS api
WORKDIR /app

# 4. Ensure the final app files are owned by node
COPY --from=build --chown=node:node /prod/api /app

USER node

EXPOSE 9000
CMD [ "node", "src/cobalt" ]
