# Story 030: Games hub integration and polish

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Author request 2026-10-07 (mini-game upgrade round)
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH

Wire all mini-games into the Games hub with new cards, best-score keys, intro cards, result screens and stickers/music, using the games hub shared flow.

## Acceptance Criteria

- [ ] Hub lists all six games with best scores
- [ ] Each game launches, finishes and returns correctly
- [ ] Sound/music per game

## Test Evidence

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-030-games-hub-integration-and-polish/`.

## Dependencies

None hard.

## Implementation Notes (autonomous run, 2026-10-07)
Not closed — run `/story-done`. `games_screen.gd` is now a data-driven hub (`GAMES` table: rhythm, memory, catch, lantern, bubbles, scramble) with intro cards, best-score saving (Memory keeps the fewest moves), one payout, shared result screen; the old in-hub Memory/Lantern code is removed. Zap Patrol stays in the Battle hub (upgraded in Story 027). Lead verification: hub + all six games launched from the hub in a windowed run (no errors; Memory Match triangulation error found and fixed by the agent); screenshots opened for hub, Lantern, Memory, Star Catch, Zap, Bubbles, Scramble, Rhythm. Not verified: hand play, audio, touch, reduce motion, Memory mismatch flip-back, bubbles frame time (17–27 ms on the dev GPU), `bubbles_view.gd`/`scramble_view.gd` are ~515 lines (over the 450 target).
