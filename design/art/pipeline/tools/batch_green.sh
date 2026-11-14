#!/usr/bin/env bash
# Renders every approved character at high quality on a flat green background, then keys the green out.
# Usage (from design/art/pipeline): bash tools/batch_green.sh
# Needs OPENAI_API_KEY in the environment. Outputs go to raw/keyed/<id>/<expr>.png (raw, git-ignored).
set -uo pipefail

GREEN=" Isolated character on a perfectly flat pure green #00FF00 background, no shadows, no floor, no glow or smoke on the background, no vignette."
work="raw/green-batch"
mkdir -p "$work"

run() { # run <id> <expr> <prompt-file>
  local id="$1" expr="$2" pf="$3"
  local out="raw/keyed/$id/$expr.png"
  local tmp="$work/$id-$expr.txt"
  mkdir -p "raw/keyed/$id"
  if [ ! -f "$pf" ]; then echo "MISSING prompt $pf"; return; fi
  { cat "$pf"; printf '%s' "$GREEN"; } > "$tmp"
  if bash tools/generate.sh "$work/$id-$expr.png" "$tmp" 1024x1024 high >/dev/null 2>&1; then
    python tools/key_green.py "$work/$id-$expr.png" "$out" && echo "ok $id/$expr"
  else
    echo "FAILED $id/$expr"
  fi
}

# Grumble King: ref-02 plus the five approved expressions.
run grumble-king ref   grumble-king-ref-v2-prompt.txt
for e in neutral angry gloat determined enraged; do
  run grumble-king "$e" "grumble-king/$e-prompt.txt"
done

# Hunters: approved reference plus approved expressions.
run juno ref         juno-ref-prompt-v2.txt
run juno neutral     juno-neutral-v2-prompt.txt
run juno cheer       juno-cheer-v2-prompt.txt
run juno determined  juno-determined-v2-prompt.txt
run juno happy       juno-happy-prompt.txt

run hae ref         hae-ref-prompt.txt
for e in neutral happy cheer determined; do run hae "$e" "hae-$e-prompt.txt"; done

run bit ref         bit-ref-v2-prompt.txt
for e in neutral happy cheer determined; do run bit "$e" "bit-$e-prompt.txt"; done

run nun ref         nun-ref-v3-prompt.txt
for e in neutral happy cheer determined; do run nun "$e" "nun-$e-prompt.txt"; done

run pearl ref       pearl-ref-prompt.txt
for e in neutral happy cheer determined; do run pearl "$e" "pearl-$e-prompt.txt"; done

# Pets: approved base-look reference per species.
for s in xolo puff sparkfox moonbun inkydrake; do
  run "$s" ref "pets/$s-ref-prompt.txt"
done

# New villains: menacing references (approved).
for v in hiccup-hydra wickmaw cinderwhisk lulltide; do
  run "$v" ref "villains/$v-ref-prompt.txt"
done

echo "batch done"
