# ============================================================================
# Ed-Verse Backend - Production Dockerfile for AWS Lightsail
# ============================================================================

# Stage 1: Builder
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including devDependencies for build)
RUN npm install

# Copy all source code (needed for build)
COPY . .

# Build the NestJS application (includes schema generation)
RUN npm run build && \
    echo "✅ Build completed" && \
    ls -la dist/main.js || (echo "❌ main.js not found!" && exit 1)

# ============================================================================
# Stage 2: Production
FROM node:20-alpine AS production

WORKDIR /app

# Install production dependencies only
COPY package*.json ./
RUN npm install --only=production

# Copy Prisma schema and generated client from builder
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

# Copy built application from builder
COPY --from=builder /app/dist ./dist

# Copy public assets (Flutter dashboard, landing page)
COPY --from=builder /app/public ./public

# Copy entrypoint script
COPY --from=builder /app/scripts/docker-entrypoint.sh ./docker-entrypoint.sh

# Regenerate Prisma Client in production stage
RUN npx prisma generate

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001

# Make entrypoint script executable
RUN chmod +x /app/docker-entrypoint.sh

# Change ownership
RUN chown -R nestjs:nodejs /app

# Switch to non-root user
USER nestjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start command: Use entrypoint script that handles migrations
ENTRYPOINT ["/app/docker-entrypoint.sh"]

