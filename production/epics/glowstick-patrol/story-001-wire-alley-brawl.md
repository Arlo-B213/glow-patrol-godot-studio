# Story 001: Wire Alley Brawl into the Battle hub

> **Epic**: glowstick-patrol
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 3

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (the **Player goal & fail state** field + MVP feature 3), scoped to this story:*

- [ ] The Alley Brawl card in the Battle hub opens its intro screen, and "Start Brawl" launches `alley_brawl_view` instead of the "Coming Soon" stub.
- [ ] The view's `finished(score, earned, won)` signal is connected and its values reach a result screen.
- [ ] A score above `best_scores["brawl"]` is saved; a lower score leaves it unchanged.
- [ ] `earned` is added via `GameState.earn_points` exactly once per run.
- [ ] "Back to Battle Menu" returns to the hub with the best score refreshed.
- [ ] A full run plays through 3 waves, the boss, and both end states (win, and lose all 3 hearts).
- [ ] Leaving the screen frees the view with no errors in the output.

---

## Implementation Notes

- `scenes/screens/battle_screen.gd`: `_start_brawl_game()` currently builds a "Coming Soon" intro.
- Mirror `_start_zap_game()` / `_on_zap_finished()`; the brawl signal has an extra `won` argument.
- `_build_result` is shared — reuse it; the "Patrol Complete!" heading may need a win/lose variant.
- Layout (2026-10-07): ground at 66% of view height, backdrop drawn in `_draw_backdrop()`, sprite sizes and hit distances scaled together by `u = size.x / 480` (clamped 1–2).
- Debug-only boss skip (ignored in release builds): launch with user args, e.g. `... --windowed --resolution 720x1280 -- --brawl-boss` to start at the boss, optionally with `--brawl-boss-health=N`.

---

## Out of Scope

- Story 003: gear effects on the brawl.
- Reward rebalancing (`/balance-check`).

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: a retained screenshot of the intro, mid-run and result screens in `production/qa/evidence/` (player-visible, so not waived). Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: Story 003

---

## Completion Notes
**Completed**: 2026-10-07 — closed with verdict NOT ASSESSED, by the user's explicit choice.
**Criteria**: 6/7 confirmed. **AC-1 (card → intro → "Start Brawl" launches the view) was not directly verified by clicking.** The user's other answers (result screen, boss, both endings) imply it works; screenshots call `_start_brawl_game()` directly. Waves 2–3 may only have been exercised via `--brawl-boss`.
**Deviations**: Extra work beyond the story, requested by the user — new `src/scenes/battle/brawl_art.gd` (procedural hunter, Gloomlings and Grumble King), a layout/backdrop rewrite and layout scaling in `alley_brawl_view.gd`, and a debug-only boss skip (`--brawl-boss`, `--brawl-boss-health=N`). Advisory: gameplay constants in `alley_brawl_view.gd` are hardcoded (candidate for Story 003). Result button still reads "Patrol Again".
**Test Evidence**: automated tests waived (`qa.level: minimal`). Retained screenshots in `production/qa/evidence/story-001-wire-alley-brawl/` (01–04).
**Code Review**: Skipped (solo mode)
