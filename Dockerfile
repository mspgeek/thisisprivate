# Use an official Node.js runtime as the base image
FROM node:18-alpine AS build

# Set the working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN npm install --frozen-lockfile || \
    pnpm install --frozen-lockfile || \
    yarn install --frozen-lockfile

# Copy the project files
COPY . .

# Build the application
RUN npm run build

# Use a lightweight Node.js runtime for serving the built application
FROM node:18-alpine

# Set the working directory
WORKDIR /app

# Copy built files from the previous stage
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json

# Install only production dependencies
RUN npm install --omit=dev

# Expose port 4173 (SvelteKit's preview default port)
EXPOSE 4173

# Start the server
CMD ["node", "build"]
