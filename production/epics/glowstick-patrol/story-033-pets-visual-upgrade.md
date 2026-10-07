# Story 033: Pets visual upgrade

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI/Feel
> **Estimate**: L
> **Last Updated**: 2026-10-07

## Context
Author request 2026-10-07: big visual upgrade of the pets (cel shading, outlines, expressive faces, moods, accessories, a richer Den) plus two new species.

## Acceptance Criteria
- [x] Five species (xolo, puff, sparkfox, moonbun, inkydrake) at 4 stages with outlines, shading, faces and lagging tails/ears/gills
- [x] Seven moods and reactions (eat, pet, grow, hop, spin) in `PetArt`
- [x] Five accessories (bow, scarf, crown, headphones, sunglasses) with a Den picker, saved
- [x] Cosier Den with a day/night window, bed, bowl and toys
- [ ] Battle companion animation viewed live (not verified)

## Implementation Notes (autonomous run, 2026-10-07)
Not closed — run `/story-done`. Built by a build agent; lead verification: evidence 01–05 opened and checked (Den with Moonbun child and Inkydrake adult, shop, species/stage and mood/accessory sheets). Unverified: Brawl companion live, reaction animations in motion, reduce-motion, shop thumbnails. Known: a pet draw costs ~5 ms over vsync on the dev GPU; Moonbun baby ears are barely visible.
