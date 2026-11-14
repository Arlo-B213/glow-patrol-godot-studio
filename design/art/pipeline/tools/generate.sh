#!/usr/bin/env bash
# Generates one character image with the OpenAI Images API and saves it as PNG.
# Usage: generate.sh <out.png> <prompt-file> [size] [quality]
# The API key comes from the OPENAI_API_KEY environment variable and is never written to disk.
# Model comes from OPENAI_IMAGE_MODEL. Check the current model id before a large batch.
set -euo pipefail

out="${1:?output png path}"
prompt_file="${2:?prompt text file}"
size="${3:-1024x1024}"
quality="${4:-medium}"
model="${OPENAI_IMAGE_MODEL:-gpt-image-1.5}"

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "OPENAI_API_KEY is not set. Set it in your environment and run again." >&2
  exit 1
fi

# Escape the prompt for a JSON string (backslash, quote, newline), then build the body.
raw_prompt="$(tr -d '\r\n' < "$prompt_file")"
bs="$(printf '\')"
dq="$(printf '"')"
prompt="${raw_prompt//"$bs"/"$bs$bs"}"
prompt="${prompt//"$dq"/"$bs$dq"}"
prompt="${raw_prompt//$bs/$bs$bs}"
prompt="${prompt//$dq/$bs$dq}"
# Optional: OPENAI_BACKGROUND=transparent gives a PNG with an alpha channel (no cutout step needed).
extra=""
if [ -n "${OPENAI_BACKGROUND:-}" ]; then
  extra=",\"background\":\"${OPENAI_BACKGROUND}\",\"output_format\":\"png\""
fi
body="{\"model\":\"${model}\",\"prompt\":\"${prompt}\",\"size\":\"${size}\",\"quality\":\"${quality}\",\"n\":1${extra}}"

resp="$(curl -sS https://api.openai.com/v1/images/generations \
  -H "Authorization: Bearer ${OPENAI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$body")"

b64="$(printf '%s' "$resp" | tr -d '\n' | sed -n 's/.*"b64_json": *"\([^"]*\)".*/\1/p')"
if [ -z "$b64" ]; then
  echo "No image returned. API said:" >&2
  printf '%s\n' "$resp" | head -c 600 >&2
  echo >&2
  exit 1
fi

mkdir -p "$(dirname "$out")"
printf '%s' "$b64" | base64 -d > "$out"
echo "saved $out ($model, $size, $quality)"
