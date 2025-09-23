# Multi-stage build for optimized production image
FROM node:20-alpine3.22 AS base

# Install security updates and common tools
RUN apk update && apk upgrade && \
  apk add --no-cache dumb-init curl && \
  rm -rf /var/cache/apk/*

# Create app directory with proper permissions
WORKDIR /usr/src/app
RUN addgroup -g 1001 -S nodejs && \
  adduser -S nodejs -u 1001 && \
  chown -R nodejs:nodejs /usr/src/app

# Development stage
FROM base AS development
USER nodejs
COPY --chown=nodejs:nodejs package*.json ./
RUN npm ci
COPY --chown=nodejs:nodejs . .

# Use an entrypoint that installs devDependencies when node_modules is missing
# This avoids relying on a globally installed nodemon and broken symlinks when
# the host mounts an empty volume over /usr/src/app or /usr/src/app/node_modules.
COPY --chown=nodejs:nodejs dev-entrypoint.sh /usr/local/bin/dev-entrypoint.sh
RUN chmod +x /usr/local/bin/dev-entrypoint.sh

EXPOSE 3001
ENTRYPOINT ["/usr/local/bin/dev-entrypoint.sh"]
CMD ["npm", "run", "dev"]

# Build stage for production
FROM base AS builder
USER nodejs
COPY --chown=nodejs:nodejs package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Production stage
FROM base AS production
ENV NODE_ENV=production
USER nodejs

# Copy production dependencies
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/node_modules ./node_modules

# Copy application code
COPY --chown=nodejs:nodejs package*.json ./
COPY --chown=nodejs:nodejs server.js ./
COPY --chown=nodejs:nodejs telemetry.js ./
COPY --chown=nodejs:nodejs routes/ ./routes/
COPY --chown=nodejs:nodejs middleware/ ./middleware/

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3001/health || exit 1

# Expose port
EXPOSE 3001

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]