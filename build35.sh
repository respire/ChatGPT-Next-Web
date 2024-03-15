#!/bin/bash

set -e

cd "$(dirname "$0")"

DOCKER_BUILDKIT=1 docker build --build-arg OPENAI_API_KEY=$GPT35_KEY \
             --build-arg BASE_URL="http://127.0.0.1:5555" \
             --build-arg DISABLE_GPT4="1" \
             --build-arg CUSTOM_MODELS="-all,+gpt-3.5-turbo-0613,+gpt-3.5-turbo-1106,+gpt-3.5-turbo-16k,+gpt-3.5-turbo-16k-0613,+gpt-3.5-turbo,+gpt-3.5-turbo-0125,+gpt-3.5-turbo-0301,+gpt-3.5-turbo-instruct" \
             --no-cache \
             -f Dockerfile \
             -t alicetyan-gpt35:latest \
             .
