FROM node:24-alpine

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
ENV NPM_CONFIG_LOGLEVEL=warn

# 1. Install build tools and enable corepack globally as root
RUN apk add --no-cache python3 build-base && corepack enable

WORKDIR /app
RUN mkdir -p /app /pnpm && chown -R node:node /app /pnpm

# 2. Switch to node user now that global configurations are complete
USER node

COPY --chown=node:node package.json pnpm-lock.yaml* ./

# 3. Direct install (Corepack will fetch the lockfile-specified pnpm version automatically)
RUN pnpm install --frozen-lockfile

COPY --chown=node:node . /app

EXPOSE 3000

CMD [ "node", "/app/api/src/cobalt.js" ]
