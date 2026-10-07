# Story 032: Hunter and Lanternboys visual upgrade

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Feature
> **Type**: UI/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Author request 2026-10-07 (big visual upgrade, "kpop demon hunters" flavour, kids 6-11)
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: MEDIUM

The hunter and the three Lanternboys looked blocky. This story gives them a stronger drawing language: gradient hair with strand highlights and lagging sway, richer eyes, an 8-expression system, tapered limbs with elbows/knees, finger hands, detailed boots, glow rim light and aura, portrait poses (idle, cheer/victory, sit, fever) and weapon light trails.

## Acceptance Criteria

- [x] (a) Expression system (neutral, happy, cheer, determined, hurt, surprised, shy, sleepy) with eyes, brows, mouth and blush per expression (`hunter_expr.gd`), used by the hunter front and side views via `look["expression"]`
- [x] (b) Gradient hair, parted side-swept fringe, bob/twintails/ponytail with sway lag (`hunter_hair.gd`)
- [x] (c) Tapered limbs, elbow bend, knee, finger hands (grip/open), boots with cuff/toe cap/laces, glow rim light and aura
- [x] (d) Portrait poses via `look["pose"]` (idle, cheer, victory, sit, fever) and weapon idle light trail; public draw APIs unchanged
- [ ] (e) Per-outfit detail pass (waist/shoulder silhouettes, extra trims) for all 8 styles
- [ ] (f) Lanternboys Hae/Bit/Nun: expressions, hair gradients, idle animation, eye-tracking close-up, lantern rim light
- [ ] (g) 300-frame frame-time measure of HQ and Brawl (target ~16 ms on Quadro K610M)
- [ ] (h) Retained screenshots by the lead in `production/qa/evidence/story-032-hunter-lanternboys-upgrade/`

## Out of Scope

Enemy/boss/pet art, game_state hairstyle list (ponytail needs a HAIRSTYLES entry there).
