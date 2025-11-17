FROM node:18-alpine

# take environment variables
ARG NODE_ENV=prod
ARG PORT=8080
ENV NODE_ENV=$NODE_ENV
ENV PORT=$PORT

# Create app directory
WORKDIR /usr/src/app

COPY package*.json ./

RUN if [ "$NODE_ENV" = "dev" ]; then \
    npm install; \
    else \
    npm install --omit=dev; \
    fi

# Copy app source code
COPY ./ ./

# Expose port and start application
EXPOSE $PORT
CMD npm run $NODE_ENV --loglevel=verbose

