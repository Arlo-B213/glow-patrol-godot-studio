---
status: draft
canon: Provisional
date: 2026-11-02
---

# Juno: prompt set and reference brief (Phase P1, step 1)

Built from `design/narrative/characters/juno.md`, visual design section. Juno is female (she/her). No existing film, show or game is referenced.

## Reference brief (the image that every later image must match)

Make this image first, and approve it before generating the other expressions.

- **Pose:** bust, three-quarter view, facing slightly left, one hand raised with a glowstick.
- **Hair:** gold (hex `#FFC15E`), in twintails, a bow in the hair, long and bouncy.
- **Outfit:** teal (hex `#52E8C6`) sequin top with a sparkle pattern that catches light, short skirt in the same teal, a lighter collar.
- **Face:** bright, wide-eyed, rosy blush on both cheeks, a confident smile.
- **Glowstick:** a comet-style glowstick with a hot pink (hex `#FF5FA2`) glow and a tail of light.
- **Background:** dark neon stage, soft spotlight from above, a faint pink rim light.
- **Frame:** 1024 x 1024, character centred, head and shoulders plus the raised arm.

## Positive prompt (reference)

```
Juno, young female idol hunter, bust portrait, three-quarter view facing left, long gold twintails with a bow, bright wide eyes, rosy blush, confident smile, teal sequin top with sparkle pattern and short teal skirt, holding a comet-style glowstick with a hot pink glow and light trail, dark neon stage background, soft top spotlight, pink rim light, chibi-anime idol portrait, clean outlines, single character, centred
```

## Negative prompt (use for every image)

```
extra limbs, extra fingers, text, watermark, logo, two characters, realistic photo, western comic style, blurry, cropped face, distorted hands, different hair colour, different outfit colour, black outfit, short hair
```

## Expression variants (use the reference's settings, and the same wording above, except the expression words)

| Expression | Words to change | Extra detail |
|---|---|---|
| Neutral | `calm, relaxed expression` | glowstick held low |
| Happy | `happy open smile` | both hands near chest |
| Cheer | `cheering, mouth open, arm pumped up` | glowstick raised high, sparkles around |
| Determined | `determined, eyebrows set, focused look` | glowstick held forward |

Generate each variant with the approved reference in the image-guidance slot, and the same seed if the generator allows it.

## Checks before a result is approved

1. Hair is gold, in twintails, with a bow. Not bob, not ponytail.
2. Outfit is teal, not violet or pink.
3. The glowstick glow is pink.
4. Exactly one character, face fully visible.
5. The face matches the reference (eye shape, blush, hair parting).

Log every attempt in `design/art/pipeline/generation-log.md`, including rejected ones.
