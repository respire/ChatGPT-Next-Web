ARG BASE_URL
ARG OPENAI_API_KEY
ARG ANTHROPIC_URL
ARG ANTHROPIC_API_KEY
ARG CUSTOM_MODELS

FROM node:22-alpine AS base

FROM base AS deps

RUN apk add --no-cache libc6-compat

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install

FROM base AS builder
ARG BASE_URL
ARG OPENAI_API_KEY
ARG ANTHROPIC_URL
ARG ANTHROPIC_API_KEY
ARG CUSTOM_MODELS

ENV BASE_URL=$BASE_URL
ENV OPENAI_API_KEY=$OPENAI_API_KEY
ENV ANTHROPIC_URL=$ANTHROPIC_URL
ENV ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY
ENV CUSTOM_MODELS=$CUSTOM_MODELS
ENV HIDE_USER_API_KEY="1"
ENV TZ="Asia/Tokyo"
ENV NEXT_TELEMETRY_DISABLED="1"
ENV NODE_ENV="production"

RUN apk update && apk add --no-cache git

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN yarn build

FROM base AS runner
ARG BASE_URL
ARG OPENAI_API_KEY
ARG ANTHROPIC_URL
ARG ANTHROPIC_API_KEY
ARG CUSTOM_MODELS

ENV BASE_URL=$BASE_URL
ENV OPENAI_API_KEY=$OPENAI_API_KEY
ENV ANTHROPIC_URL=$ANTHROPIC_URL
ENV ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY
ENV CUSTOM_MODELS=$CUSTOM_MODELS
ENV HIDE_USER_API_KEY="1"
ENV TZ="Asia/Tokyo"
ENV NEXT_TELEMETRY_DISABLED="1"
ENV NODE_ENV="production"

WORKDIR /app

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/.next/server ./.next/server

RUN addgroup -g 1001 -S app; \
    adduser -u 1001 -G app -D -h /app -S -H app; \
    chown -R app:app /app

EXPOSE 3000
USER app:app
CMD ["node", "server.js"]
