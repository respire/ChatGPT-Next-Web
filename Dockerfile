ARG OPENAI_API_KEY
ARG BASE_URL
ARG DISABLE_GPT4=""

FROM node:20-alpine AS base

FROM base AS deps

RUN apk add --no-cache libc6-compat

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install

FROM base AS builder
ARG OPENAI_API_KEY
ARG BASE_URL
ARG DISABLE_GPT4
ENV OPENAI_API_KEY=$OPENAI_API_KEY
ENV BASE_URL=$BASE_URL
ENV DISABLE_GPT4=$DISABLE_GPT4
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
ARG OPENAI_API_KEY
ARG BASE_URL
ARG DISABLE_GPT4
ENV OPENAI_API_KEY=$OPENAI_API_KEY
ENV BASE_URL=$BASE_URL
ENV DISABLE_GPT4=$DISABLE_GPT4
ENV HIDE_USER_API_KEY="1"
ENV TZ="Asia/Tokyo"
ENV NEXT_TELEMETRY_DISABLED="1"
ENV NODE_ENV="production"

WORKDIR /app

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/.next/server ./.next/server

EXPOSE 3000
