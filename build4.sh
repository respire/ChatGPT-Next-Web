#!/bin/bash

set -e

cd "$(dirname "$0")"

BASE_URL=${BASE_URL:-'http://dockerhost:5556'}

DOCKER_BUILDKIT=1 docker build --build-arg OPENAI_API_KEY=$GPT4_KEY \
             --build-arg BASE_URL="$BASE_URL" \
             --build-arg CUSTOM_MODELS="-all,+gpt-4,+gpt-4-0125-preview,+gpt-4-0314,+gpt-4-0613,+gpt-4-1106-preview,+gpt-4-32k,+gpt-4-32k-0314,+gpt-4-32k-0613,+gpt-4-turbo-2024-04-09,+gpt-4-turbo-preview,+claude-3-haiku-20240307,+claude-3-opus-20240229,+claude-3-sonnet-20240229,+gemini-pro" \
             --no-cache \
             -f Dockerfile \
             -t alicetyan-gpt4:latest \
             .

if [ "$PACKAGE" = '1' ]; then
  docker run --rm alicetyan-gpt4:latest env
  docker save alicetyan-gpt4:latest -o alicetyan-gpt4.tar
  gzip alicetyan-gpt4.tar
fi
