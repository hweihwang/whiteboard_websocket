# syntax=docker/dockerfile:latest
# SPDX-FileCopyrightText: 2024 Nextcloud GmbH and Nextcloud contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

# FROM node:22.8.0-alpine3.20 AS build
# SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# ARG NODE_ENV=production
# COPY ./ /app
# WORKDIR /app
# RUN apk upgrade --no-cache -a && \
#     apk add --no-cache ca-certificates && \
#     npm install --global clean-modules && \
#     npm clean-install && \
#     clean-modules --yes && \
#     npm cache clean --force

# FROM node:22.8.0-alpine3.20
# COPY --from=build --chown=nobody:nobody /app /app
# WORKDIR /app
# RUN apk upgrade --no-cache -a && \
#     apk add --no-cache ca-certificates tzdata netcat-openbsd openssl nginx && \
#     mkdir -p /run/nginx && \
#     chown -R nobody:nobody /run/nginx && \
#     mkdir -p /var/lib/nginx/tmp /var/lib/nginx/logs && \
#     chown -R nobody:nobody /var/lib/nginx

# # Generate self-signed SSL certificate
# RUN mkdir -p /app/ssl && \
#     openssl req -x509 -newkey rsa:4096 -keyout /app/ssl/key.pem -out /app/ssl/cert.pem -days 365 -nodes -subj "/CN=localhost" && \
#     chown -R nobody:nobody /app/ssl && \
#     chmod 600 /app/ssl/key.pem /app/ssl/cert.pem

# # Copy Nginx configuration
# COPY nginx.conf /etc/nginx/nginx.conf

# # Forward request and error logs to Docker log collector
# RUN ln -sf /dev/stdout /var/lib/nginx/logs/access.log && \
#     ln -sf /dev/stderr /var/lib/nginx/logs/error.log

# USER nobody
# EXPOSE 443
# CMD ["sh", "-c", "nginx && npm run start"]

FROM node:22.8.0-alpine3.20 AS build
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
ARG NODE_ENV=production
COPY ./ /app
WORKDIR /app
RUN apk upgrade --no-cache -a && \
    apk add --no-cache ca-certificates && \
    npm install --global clean-modules && \
    npm clean-install && \
    clean-modules --yes && \
    npm cache clean --force

FROM node:22.8.0-alpine3.20
COPY --from=build --chown=nobody:nobody /app /app
WORKDIR /app
RUN apk upgrade --no-cache -a && \
    apk add --no-cache ca-certificates tzdata netcat-openbsd

USER nobody
EXPOSE 23000
ENTRYPOINT ["npm", "run", "start"]
HEALTHCHECK CMD nc -z 127.0.0.1 23000 || exit 1
