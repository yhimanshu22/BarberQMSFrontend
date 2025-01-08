# Stage 1: Build Stage
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package files and install dependencies
COPY package.json ./ 
RUN npm install

# Install sharp for image optimization during the build
RUN npm install sharp

# Copy all files and build the project
COPY . .
RUN npm run build

# Stage 2: Production Stage
FROM node:18-alpine
WORKDIR /app

# Copy only production dependencies
COPY package.json ./ 
RUN npm install --production

# Install sharp for production usage
RUN npm install sharp --production

# Copy build output and necessary files from the builder stage
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.js ./next.config.js

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV NEXT_PUBLIC_API_URL=http://backend:8000
ENV NEXTAUTH_URL=http://localhost:8000
ENV NEXTAUTH_SECRET=123456

# Expose the application port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
