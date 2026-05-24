FROM node:24-alpine

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV CI=true
ENV NPM_CONFIG_LOGLEVEL=warn

# Install compilation tools and enable corepack globally as root
RUN apk add --no-cache python3 build-base && corepack enable

# Set the working directory to the explicit location of your project code
WORKDIR /app
RUN mkdir -p /app /pnpm && chown -R node:node /app /pnpm

USER node

# Copy everything into the container first
COPY --chown=node:node . /app

# Switch context directly into the subdirectory containing package.json
WORKDIR /app/api

# Run install directly inside the folder where the dependencies are declared
RUN pnpm install --frozen-lockfile

EXPOSE 3000

# Execute relative to the configured api subdirectory context
CMD [ "node", "src/cobalt.js" ]
