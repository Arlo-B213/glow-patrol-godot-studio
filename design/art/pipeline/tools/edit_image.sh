#!/usr/bin/env bash
# Edits a reference image with the OpenAI image-edit API, so new parts match the approved look.
# Usage: edit_image.sh <out.png> <reference.png> <prompt-file> [size] [quality]
# The API key comes from OPENAI_API_KEY and is never written to disk.
set -euo pipefail

out="${1:?output png path}"
ref="${2:?reference png path}"
prompt_file="${3:?prompt text file}"
size="${4:-1024x1024}"
quality="${5:-high}"
model="${OPENAI_IMAGE_MODEL:-gpt-image-1.5}"

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "OPENAI_API_KEY is not set." >&2
  exit 1
fi

prompt="$(tr -d '\r\n' < "$prompt_file")"

resp="$(curl -sS https://api.openai.com/v1/images/edits \
  -H "Authorization: Bearer ${OPENAI_API_KEY}" \
  -F "model=${model}" \
  -F "image=@${ref}" \
  -F "prompt=${prompt}" \
  -F "size=${size}" \
  -F "quality=${quality}" \
  -F "n=1")"

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
