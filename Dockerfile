# Use an alpine Node.js runtime as a parent image
FROM node:18-alpine

# ===== Client =====
# Set the working directory for the client
WORKDIR /usr/src/app/client

# Copy the client package.json / package-lock.json and install deps
COPY client/package*.json ./
RUN npm ci --no-audit --no-fund

# Copy client source and build
COPY client/ ./
RUN npm run build

# ===== Server =====
# Set the working directory for the server
WORKDIR /usr/src/app/server

# Copy the server package.json / package-lock.json and install deps
COPY server/package*.json ./
RUN npm ci --no-audit --no-fund

# Copy the server source
COPY server/ ./

# Copy the client build into the server's public dir
RUN mkdir -p ./public && cp -R /usr/src/app/client/dist/* ./public/

# Expose API port
EXPOSE 5000

# Start the server
CMD ["npm","start"]
