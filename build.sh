#!/bin/bash

set -e

cd "$(dirname "$0")"

source ".env"

DOCKER_BUILDKIT=1 docker build --build-arg OPENAI_API_KEY=$OPENAI_API_KEY \
             --build-arg BASE_URL="$BASE_URL" \
             --build-arg ANTHROPIC_URL="$ANTHROPIC_URL" \
             --build-arg ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
             --build-arg CUSTOM_MODELS="-all,+claude-3-7-sonnet-20250219-thinking@OpenAI,+gpt-4.1-2025-04-14@OpenAI,+gpt-4.5-preview-2025-02-27@OpenAI,+claude-3-7-sonnet-20250219@Anthropic,+claude-opus-4-20250514@Anthropic,+claude-sonnet-4-20250514@Anthropic" \
             --no-cache \
             -f Dockerfile \
             -t chatgpt-next-web:latest \
             .

if [ "$PACKAGE" = '1' ]; then
  docker run --rm chatgpt-next-web:latest env
  rm -f chatgpt-next-web.tar
  rm -f chatgpt-next-web.tar.gz
  docker save chatgpt-next-web:latest -o chatgpt-next-web.tar
  gzip chatgpt-next-web.tar
fi
