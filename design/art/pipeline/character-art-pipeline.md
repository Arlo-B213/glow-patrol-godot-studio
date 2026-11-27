---
status: draft
canon: n/a
date: 2026-11-02
---

# Character Art Pipeline (AI-rendered portraits and key art)

Scope (author decision, amended 2026-11-14): portraits, key art, **and brawl figures**. The approved art replaces the code-drawn brawl characters too (hunters, the Grumble King, the Hydra, Wickmaw, Cinderwhisk, Lulltide, the Gloomlings and the pets). Brawl animation (walk, hit, knock-down) needs a sprite plan, because static images cannot follow the code's motion. Generator in use: **OpenAI Images API (gpt-image-1.5, 1024x1024, quality medium)** via `tools/generate.sh`. SeaArt and Leonardo were the original plan and are not in use.

## 1. What gets generated

| Use | Who | Size | Count |
|---|---|---|---|
| Lounge and Club portraits | Juno, Pearl, Hae, Bit, Nun | 1024 x 1024, bust | 5 characters x 4 expressions (neutral, happy, cheer, determined) |
| Story cutscene panels | all of the above, plus the Grumble King | 1024 x 1536, half body | per chapter, as needed |
| HQ hero card (fellow hunters only) | Juno, Pearl | 1024 x 1536 | 2 |
| Villain portraits (Grumble King, approved set) | Grumble King | 1024 x 1024, bust | 5 expressions (neutral, angry, gloat, determined, enraged); ref-02 is canonical |
| Pet base looks (approved references) | Xolo, Puff, Sparkfox, Moonbun, Inkydrake | 1024 x 1024 | 1 reference per species (ref-01). Egg, baby, child and adult shapes are drawn in code by `pet_art.gd`, so no per-stage images |

**Not generated:** the player's hunter (You). Her outfit, hair and colour change in the Closet, and a fixed image cannot follow those changes. The code-drawn portrait stays for her.

**Villain and pet notes:** the Grumble King is menacing but not gory or frightening to small children (see art bible pillar 4). Gloat replaces "cheer" for him, because his sheet forbids cheerful lines. Pets are reference-only for now; the pet references are not yet wired into `pet_art.gd`.

## 2. Source of truth: the character sheets

Every prompt is built from `design/narrative/characters/*.md`. Use the sheet's **Visual design** section, with its hex colours. Do not write prompts from memory or from other media.

**Do not reference or describe any existing film, show or game characters, their names, hairstyles or outfits.** Use only the original designs in our sheets. The hair and outfit words in a prompt should come from the sheet (for example "long hair down past the shoulders, deep navy, star clip"), not from another work.

## 3. Prompt template (fill from the sheet)

Positive:
`[character name], [build], [hair: style, colour hex-described], [outfit: style, colour], [accessories], [glow accent colour] stage light, [expression], chibi-anime idol portrait, clean outlines, soft rim light, neon stage background, centred, single character`

Negative:
`extra limbs, text, watermark, logo, two characters, realistic photo, western comic, blurry, cropped face, extra fingers`

Keep the same wording for all four expressions of one character. Change only the expression words.

## 4. Consistency

1. Pick one **reference image** per character (the first good result). Save it to `design/art/pipeline/refs/<character>.png`.
2. For every later image, use that reference in the generator's image-guidance or reference slot. Lock the seed when the generator allows it.
3. Log each image in `design/art/pipeline/generation-log.md`: generator, model name, seed, prompt, licence terms seen, date.

## 5. Licence check (before use)

Free tiers often limit commercial use. Before any image goes into a shipped build:
- Read the generator's terms and the model's licence (SeaArt and Leonardo each list them on the model page).
- Note the result in the generation log. If a model cannot be used commercially, do not use it.

## 6. Post-processing

1. Remove the background to a transparent PNG (any free background remover, or the generator's own option).
2. Crop to the same frame for all four expressions of a character (same head position, so the swap does not jump).
3. Save finals as PNG. Portraits are 512 px wide; hero cards are 768 px wide. Keep the raw downloads outside `src/`, so Godot does not import them.
4. Put finals in `src/assets/art/characters/<id>/<expression>.png`. The project already imports textures as ETC2.

## 7. Godot integration

- One new script, `src/scripts/character_art.gd`, looks up `<id>/<expression>.png` and returns a texture. If the file is missing it returns `null`.
- Callers fall back to the code-drawn art when the texture is `null`. The game never breaks, and each character can switch over one at a time.
- Call sites: the Lounge dialogue portrait (`club_cards.gd` dialogue view), the Lounge map tiles, the cutscene panels, and the hunter picker cards in the Closet (`club_screen.gd`).
- Tests: a unit test checks that every character and expression in the list resolves to a file or falls back. A screenshot per changed screen goes to `production/qa/evidence/art/`, per the UI evidence rule.

## 8. Phases

| Phase | Work | Done when |
|---|---|---|
| P0 | Pick the style, make one reference per character (Juno first) | Juno's reference is approved |
| P1 | Juno and Pearl: 4 expressions each | Both show in the Closet and the story panel |
| P2 | Hae, Bit, Nun: 4 expressions each | All three show in the Lounge |
| P3 | Story key art for chapters 1–10 | Cutscene panels use it |

## 9. What I need from you

1. Generate with SeaArt and Leonardo using the prompts I write from the sheets, and download the results.
2. Tell me which generator and model produced each image you pick, so I can log it.
3. Tell me the path where you saved the downloads, so I can post-process and place them.

I cannot log in to the generators or download for you.
