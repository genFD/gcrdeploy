ARG NODE_VERSION="18"
ARG ALPINE_VERSION="3.17"
ARG PORT=3000

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS builder
RUN apk update \
 && apk add dumb-init 

WORKDIR /usr/src/app
COPY  package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM builder As production

ENV NODE_ENV=${NODE_ENV_PROD}
COPY --chown=node:node --from=builder /usr/src/app/dist ./dist
COPY --chown=node:node --from=builder /usr/src/app/package.json .
COPY --chown=node:node --from=builder /usr/src/app/package-lock.json .
RUN npm ci --omit=dev
EXPOSE ${PORT}
CMD ["dumb-init", "node", "dist/main"]
