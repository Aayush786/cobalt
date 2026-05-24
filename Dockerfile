FROM node:24-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# Enable corepack globally
RUN corepack enable

FROM base AS build
# Install system build dependencies needed for native node modules
RUN apk add --no-cache python3 alpine-sdk

WORKDIR /app

# Ensure the 'node' user owns the working directory and the pnpm cache
RUN chown -R node:node /app /pnpm

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

# Ensure runtime directory is owned by node
RUN chown -R node:node /app

USER node

# 3. CRITICAL: Copy the isolated deployment from the build stage
COPY --from=build --chown=node:node /app/prod/api ./

EXPOSE 3000
CMD [ "node", "src/index.js" ] # Adjust this to match your API's start file
