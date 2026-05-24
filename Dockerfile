FROM node:24-alpine

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
ENV NPM_CONFIG_LOGLEVEL=warn

# Swapped alpine-sdk for build-base, removed corepack since Node 24 already has it
RUN apk add --no-cache python3 build-base

WORKDIR /app
RUN mkdir -p /app /pnpm && chown -R node:node /app /pnpm

USER node

COPY --chown=node:node package.json pnpm-lock.yaml* ./

# Enable the corepack binary that already exists inside the Node image
RUN corepack enable && corepack prepare --activate
RUN pnpm install --frozen-lockfile

COPY --chown=node:node . /app

EXPOSE 3000

CMD [ "node", "/app/api/src/cobalt.js" ]
