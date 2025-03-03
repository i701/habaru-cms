# Stage 1: Build
FROM node:18-alpine AS build

# Install necessary build tools and dependencies
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git

# Set environment variables
ENV NODE_ENV=production

# Set working directory
WORKDIR /opt/

# Copy package.json and yarn.lock
COPY package.json yarn.lock ./

# Install yarn globally and add necessary packages
RUN yarn global add node-gyp && \
    yarn add pg -W && \
    yarn config set network-timeout 600000 -g && \
    yarn install --frozen-lockfile --production

# Set PATH environment variable
ENV PATH /opt/node_modules/.bin:$PATH

# Set working directory for the app
WORKDIR /opt/app

# Copy the rest of the application code
COPY . .

# Install local plugins and generate types
RUN cd /opt/app/src/plugins/strapi-plugin-ckeditor && \
    yarn install && \
    cd /opt/app && \
    yarn run strapi ts:generate-types && \
    yarn build

# Stage 2: Final Production Image
FROM node:18-alpine

# Install runtime dependencies
RUN apk add --no-cache vips-dev

# Set environment variables
ENV NODE_ENV=production

# Set working directory
WORKDIR /opt/

# Copy node_modules from the build stage
COPY --from=build /opt/node_modules ./node_modules

# Set working directory for the app
WORKDIR /opt/app

# Copy the application code from the build stage
COPY --from=build /opt/app ./

# Set PATH environment variable
ENV PATH /opt/node_modules/.bin:$PATH

# Change ownership of the app directory
RUN chown -R node:node /opt/app

# Switch to non-root user
USER node

# Expose the application port
EXPOSE 1337

# Start the application
CMD ["yarn", "start"]