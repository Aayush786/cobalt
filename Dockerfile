FROM node:24-alpine

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
ENV NPM_CONFIG_LOGLEVEL=warn

# 1. Install build tools, git, and enable corepack
RUN apk add --no-cache python3 build-base git && corepack enable

WORKDIR /app
RUN mkdir -p /app /pnpm && chown -R node:node /app /pnpm

USER node

COPY --chown=node:node . /app

WORKDIR /app/api

# 2. Fake a complete git setup including an upstream remote so Cobalt parses happily
RUN git init && \
    git config user.name "railway" && \
    git config user.email "railway@local.internal" && \
    git remote add origin https://github.com/imputnet/cobalt.git && \
    git add . && \
    git commit -m "initial release"

# 3. Clean install inside the sub-directory
RUN pnpm install --frozen-lockfile

EXPOSE 3000

CMD [ "node", "src/cobalt.js" ]
