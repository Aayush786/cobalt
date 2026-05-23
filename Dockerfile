FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app

COPY . /app

RUN corepack enable && corepack prepare pnpm@latest --activate
RUN apk add --no-cache python3 alpine-sdk

# 1. install dependencies FIRST
RUN pnpm install

# 2. then deploy filtered app
RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

RUN pnpm install

FROM base AS api
WORKDIR /app

COPY --from=build --chown=node:node /prod/api /app

USER node

EXPOSE 9000
CMD [ "node", "src/cobalt" ]
