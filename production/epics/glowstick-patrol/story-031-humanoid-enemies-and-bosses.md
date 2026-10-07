# Story 031: Humanoid gloom enemies and bosses

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Feature
> **Type**: UI/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Author request 2026-10-07 (visual overhaul: more human features, big upgrade)
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: MEDIUM

The Gloomlings, Blinker, Mossback, Grumble King and Hiccup Hydra were blobs with dots for eyes. This story redraws them as expressive chibi "gloom idol" humanoids (head, torso, arms with hands, legs with feet, clothing, glow accents) with an expression system, keeping the draw API, hit radii and `fx` dictionary. Star Catch hazards and Zap Patrol demons reuse the gloom imp at small sizes.

## Acceptance Criteria

- [ ] (a) Every enemy and boss is a humanoid with outlined 3-tone shading, rim light, glow aura and glowing eyes with brows, nose, mouth/teeth
- [ ] (b) Expressions: idle, angry, hurt, stunned, dying, defeated-smile (plus sleepy, giggle, sneeze, roar, grumpy for bosses)
- [ ] (c) Walk cycle, breathing, wind-up lunge, hurt recoil, dying fade; boss intro pose, hurt flinch, enraged look at low health
- [ ] (d) Static poses under reduce motion
- [ ] (e) Star Catch and Zap Patrol read at ~40-60 px
- [ ] (f) No script errors or triangulation failures from the new art; frame time acceptable with 6 enemies
- [ ] (g) Retained screenshots by the lead in `production/qa/evidence/story-031-humanoid-enemies-and-bosses/`

## Out of Scope

Hunter, Lanternboy and pet art; scenery; balance changes (hit radii and speeds unchanged).

## Test Evidence

**Story Type**: UI/Feel
**Required evidence**: retained screenshots in `production/qa/evidence/story-031-humanoid-enemies-and-bosses/`.

## Dependencies

Builds on Story 021 (enemy variants, bosses) and Story 025 (actors drawing).

## Implementation Notes

Files: `src/scenes/battle/gloom_kit.gd` (Rig, limbs, pose), `gloom_face.gd`, `gloom_gear.gd`, `gloom_imp.gd`, `gloom_scout.gd`, `gloom_brute.gd`, `gloom_king.gd`, `gloom_hydra.gd`; entry points kept in `brawl_art.gd`, `brawl_art_enemies.gd`, `brawl_art_hydra.gd`; callers `brawl_actors.gd`, `catch_art.gd`, `zap_art.gd`. Status moves to In Review only when every criterion above is confirmed by the lead.
