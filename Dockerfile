# Base stage - Common dependencies
FROM node:18-alpine as base
RUN apk add --no-cache g++ make py3-pip libc6-compat
WORKDIR /app
COPY package*.json ./

ENV NEXT_PUBLIC_FASTAPI_URL=https://api.tantunai.com

# Builder stage - Builds the application
FROM base as builder
WORKDIR /app
COPY . .
RUN npm ci
RUN npm run build

# Production stage - Runs the built app in production mode
FROM node:18-alpine as production
WORKDIR /app

# Environment setup
ENV NODE_ENV=production

# Install only production dependencies
COPY package*.json ./
RUN npm ci --only=production


# Copy necessary files from the builder stage
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./package.json

# Start the Next.js application in production mode
# Change the exposed port to 80 or any non-privileged port
EXPOSE 80

# Update the start command to use port 80
CMD ["npm", "start", "--", "-p", "80"]

