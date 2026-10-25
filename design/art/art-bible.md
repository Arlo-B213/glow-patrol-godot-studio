# Art Bible: Glowstick Patrol

> **Status**: Draft v1 — for author approval
> **Direction**: Sleek and stylised, kid-readable
> **Source of palette**: values already used in `src/scripts/hunter_art.gd` and `src/theme/` so new art matches what is on screen

## 1. Visual pillars

1. **Glow is the hero.** Light sources (glowsticks, lanterns, stage lights) are the brightest things on screen. Everything else is slightly muted so glow reads first.
2. **Clear at a glance.** A 6-year-old must tell hunter, Lanternboy, demon and pickup apart at phone size, in under a second.
3. **Idol polish.** Clean silhouettes, confident poses, tidy outlines. No grit, no gore.
4. **Friendly monsters.** Gloom characters are spooky-cute, never scary. Dark purple, not black.

## 2. Palette

Core colours, taken from the existing code. Use these exact hex values.

| Role | Name | Hex | Used for |
|------|------|-----|----------|
| Glow accent | Idol pink | `#FF5FA2` | Hunter highlights, UI primary, glow rims |
| Reward gold | Star gold | `#FFD36E` | Star Points, badges, sparkle |
| Skin light | Warm peach | `#FFD9C2` | Skin highlight |
| Light neutral | Lavender white | `#F5EFFF` | Text on dark, panel light |
| Shadow dark | Night plum | `#2A1B4D` | Outlines, UI panel fill |
| Deepest | Ink violet | `#1A0B33` | Outline on characters, background |
| Support | Electric violet | `#6C5CE7` | Secondary accent, Lanternboy tints (`0.42, 0.36, 0.91`) |

Rules:
- **Maximum 24 colours** across the whole game, shades included. Add a new hue only through this file.
- Each character uses one hue family plus neutrals. No more than three saturated colours per sprite.
- Shadows are darker shades of the local hue, never grey or black.

## 3. Shape and line

- **Outline**: 2 px at 1× in `#1A0B33` on all characters. Pets and gloom enemies use the same weight.
- **Silhouette first**: each character must read as a solid black shape. Test with a black fill before colouring.
- **Proportions**: hunter is about 3 heads tall (stylised, slightly longer legs). Lanternboys match the idol look. Pets are simpler, rounder shapes.
- **Corners**: rounded (2–3 px radius at 1×). No sharp spikes except on demons.

## 4. Light and glow

- **Light direction**: top-left, a single key light. Shadows fall bottom-right, in `#2A1B4D` at about 35% opacity.
- **Rim light**: a 1 px line of `#FFD9C2` or `#FF5FA2` on the lit edge of characters.
- **Glow**: additive, soft edge, on glowsticks and lanterns only. Glow never sits on UI text.
- **Colour grade**: scenes sit in a dark violet ambience (`#1A0B33` base) so glow stands out.

## 5. Sprite rules (for the sprite pipeline)

- **Base still**: one character, front-facing 3/4, neutral pose, transparent background, on a plain light grey ground for review.
- **Canvas**: 256 × 256 px per frame at 1×. The sprite is exported at 1× and scaled in Godot with nearest-neighbour off (smooth), so the outline stays clean.
- **Animation rows**: idle (6 frames), walk (8), attack (6), hurt (3). Each row starts and ends on the same pose so loops are seamless.
- **Pivot**: feet centred at the bottom of the frame, so Godot positions all characters from one point.
- **Atlas**: PNG atlas with a JSON manifest. Frame names follow `<character>_<state>_<index>`.

## 6. UI

- **Panels**: `#2A1B4D` fill, `#FF5FA2` 2 px border on focus, 16 px corner radius.
- **Buttons**: `#FF5FA2` primary, `#FFD36E` reward, `#6C5CE7` secondary. Text is `#F5EFFF` on dark, `#1A0B33` on gold.
- **Icons**: 2 px outline in `#1A0B33`, flat fills from the palette, 48 px at 1×.
- **Text**: heavy display face for headings, readable sans for body. Minimum body size 18 px. Dyslexia-friendly font (Story 044) replaces body text when on.

## 7. Colour-blind safety

Glow colours never carry meaning on their own. Every state also uses a shape or icon (Story 045). The palette must pass the contrast check defined there.

## 8. Handoff checklist (for any artist or generated sprite)

- [ ] Matches palette hex values above, no extra hues
- [ ] Reads as a black silhouette
- [ ] 2 px `#1A0B33` outline at 1×
- [ ] Light from top-left, rim light present
- [ ] Feet pivot at bottom centre of 256 × 256
- [ ] Loops seamlessly for idle, walk and hurt
- [ ] Transparent background, PNG, no baked shadows on the ground

## Open questions

- Final display font licence (needed for Story 044 and the UI kit).
- Whether Lanternboys share the hunter's proportions or are slightly shorter.
