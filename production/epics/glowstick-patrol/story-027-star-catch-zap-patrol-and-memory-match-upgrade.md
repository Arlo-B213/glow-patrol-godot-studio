# Story 027: Star Catch, Zap Patrol and Memory Match upgrade

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

Bring Star Catch, Zap Patrol and Memory Match up to the Alley Brawl standard (backdrops, HUD, controls, juice, audio, pet cheer, reduce motion). Memory Match is extracted from games_screen.gd into its own view.

## Acceptance Criteria

- [ ] Three games have animated backdrops and the shared HUD style
- [ ] Controls/feedback/audio are polished
- [ ] Memory Match lives in its own view file
- [ ] Payout rules and best-score keys unchanged

## Test Evidence

**Story Type**: UI/Feel
**Required evidence**: retained screenshots in `production/qa/evidence/story-027-star-catch-zap-patrol-and-memory-match-upgrade/`.

## Dependencies

None hard.

## Implementation Notes (autonomous run, 2026-10-07)

Status left at Ready: hub integration of Memory Match (games_screen.gd) and lead sign-off on screenshots are outstanding.

- Star Catch: `star_catch_view.gd` + `catch_art.gd` + `catch_input.gd` (dusk sky, falling-star streaks, glowing ground, hunter holding a lantern basket, pet sidekick, golden x2 / magnet stars, Gloomling hazards with Alley Brawl art, near-miss popups, combo bar, timer ring). Drag anywhere with acceleration, round left/right buttons (72px+), A/D/arrows.
- Zap Patrol: `zap_patrol_view.gd` + `zap_art.gd` (mint rooftops, neon signs, floating blinking demons, bolts and ripples, charge orb tied to combo, Grumble King with health bar).
- Memory Match: `src/scenes/games/memory_match_view.gd` + `memory_art.gd`; `finished(moves, earned)`, `var moves`, earned = max(5, min(30, 30 - moves)); 1.1 s peek at start. Old code stays in games_screen.gd until the hub is wired.
- .tscn files reduced to a script-only root (labels/timer nodes removed).
- Unverified: look on a real device, audio ids by ear, hunter weapon-tip position (approximated), calm (reduce motion) mode visually, keyboard play, touch multi-finger.
- No hearts in Star Catch / Zap Patrol: neither game has a fail state, adding one would change rules.
