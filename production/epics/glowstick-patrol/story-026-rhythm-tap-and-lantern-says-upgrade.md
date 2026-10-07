# Story 026: Rhythm Tap and Lantern Says upgrade

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Author request 2026-10-07 (mini-game upgrade round)
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH

Bring Rhythm Tap and Lantern Says up to the Alley Brawl standard: themed animated backdrops with parallax, redesigned HUD (hearts/pills/progress), round touch-friendly controls, particles and juice, audio on every action, pet cheer, reduce motion respected, and a polished intro/result flow.

## Acceptance Criteria

- [ ] Both games have an animated themed backdrop and the shared HUD style
- [ ] Controls are large and touch-friendly with feedback and sound
- [ ] Pets/reduce motion/audio/payout rules honoured
- [ ] Lantern Says lives in its own view file (extracted from games_screen.gd)

## Test Evidence

**Story Type**: UI/Feel
**Required evidence**: retained screenshots in `production/qa/evidence/story-026-rhythm-tap-and-lantern-says-upgrade/`.

## Dependencies

None hard.

## Implementation Notes (autonomous run, 2026-10-07)

- Rhythm Tap rewritten as a code-drawn view: `src/scenes/battle/rhythm_tap_view.gd` (+ minimal `.tscn`, same path) and `src/scenes/games/rhythm_stage.gd` (neon backdrop, spotlights, beat floor glow, edges). Four round pads (D/F/J/K or touch), orbs with trails, Perfect/Good/Miss popups, combo, FEVER every 10 combo (+2 score, harder pulse), progress bar, 3-2-1-GO, pet cheer, screen-edge flashes, SparkleBurst on perfects.
- Lantern Says extracted to `src/scenes/games/lantern_says_view.gd` (+ `lantern_scenery.gd`): diamond of four lanterns with distinct tones, 3 hearts (wrong tap = lose heart + replay), round pill, Watch/Your turn banner, streak pill, pet cheer. Payout `max(5, rounds*3)` as before; `finished(score=rounds, earned)`.
- Both emit `finished` once; neither saves/pays (hub does). Delta-time driven via `advance(dt)`.
- Unverified: real touch input on device, reduce-motion visual look, sound audibility/pitch distinctness, pet cheer rendering with a hatched pet, fresh-run screenshot after last tweak (lantern strings shortened), hub integration (games_screen.gd still uses old lantern code until lead removes it). Retained evidence screenshots not yet copied to `production/qa/evidence/`.
