# Story 028: Glow Bubbles (bubble pop)

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

A Puzzle-Bobble-style bubble shooter, original name and art: aim and shoot glowing orbs up at a ceiling grid, match 3+ to pop, orphaned clusters drop, ceiling lowers over time, combos, stage clearing, pets cheer. Touch aiming (drag to aim, release to fire) plus keyboard.

## Acceptance Criteria

- [ ] Aim and fire with drag/release or keyboard
- [ ] Matches of 3+ pop; disconnected clusters fall
- [ ] Ceiling descends; losing and winning conditions work
- [ ] Levels increase in difficulty; payout through GameState.payout_for
- [ ] Juice, audio, reduce motion

## Test Evidence

**Story Type**: UI/Feel
**Required evidence**: retained screenshots in `production/qa/evidence/story-028-glow-bubbles-bubble-pop/`.

## Dependencies

None hard.

## Implementation Notes (autonomous run, 2026-10-07)

- Files: `src/scenes/games/bubbles_view.gd` (Control, `finished(score, earned)`), `bubbles_grid.gd` (pure logic), `bubbles_art.gd` (orbs). Status left Ready: screenshots not yet reviewed by the lead.
- Smoke script passed (grid logic, seeded stages, stage clear, stage 8 win, game over, finished once, payout_for). Windowed frame time ~17 ms (vsync off, 720x1280).
- Unverified: real touch input and keyboard on device; look of screenshots; audio; `bubbles_view.gd` is ~515 lines (over the ~450 target); reduce-motion only smoke-run, not viewed. Views preload GameKit/HunterArt instead of using class_name (class cache incomplete headless).
