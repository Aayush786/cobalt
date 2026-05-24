FROM node:24-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# Enable corepack globally
RUN corepack enable

FROM base AS build
# Install system build dependencies needed for native node modules
RUN apk add --no-cache python3 alpine-sdk

WORKDIR /app

# Ensure both directories exist on disk before running chown
RUN mkdir -p /app /pnpm && chown -R node:node /app /pnpm

# Switch to the non-root node user before copying files or installing
USER node

# Copy project files and ensure they are owned by the node user
COPY --chown=node:node . /app

# Activate the specific pnpm version defined in your package.json
RUN corepack prepare --activate

# 1. Install dependencies safely as the node user
RUN pnpm install

# 2. Deploy filtered app to an isolated folder in the user's home directory
# FIX: Moving out of /app completely breaks pnpm's path normalization loop
RUN mkdir -p /home/node/deploy && pnpm deploy /home/node/deploy --filter=@imput/cobalt-api --prod


# Final clean runtime stage
FROM base AS api
WORKDIR /app

# Ensure runtime and pnpm directories exist and are owned by node
RUN mkdir -p /app /pnpm && chown -R node:node /app /pnpm

USER node

# FIX: Copy from the stable /home/node/deploy folder instead
COPY --from=build --chown=node:node /home/node/deploy ./

# Expose your API port 
EXPOSE 3000

# Let pnpm handle executing the script straight out of the isolated context
CMD [ "pnpm", "start" ]
