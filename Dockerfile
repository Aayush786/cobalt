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

# 2. Deploy filtered app to a production-isolated directory
RUN pnpm deploy --filter=@imput/cobalt-api --prod /app/prod/api


# Final lean runtime stage
FROM base AS api
WORKDIR /app

# Ensure runtime and pnpm directories exist and are owned by node
RUN mkdir -p /app /pnpm && chown -R node:node /app /pnpm

USER node

# Expose your API port (change if your app uses a different port)
EXPOSE 3000

# Update this line to match your API's production start command
CMD [ "sh", "-c", "ls -R" ]
