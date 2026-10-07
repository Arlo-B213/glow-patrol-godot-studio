# Story 002: Wire Rhythm Tap and Star Catch into Mini-Games

> **Epic**: glowstick-patrol
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 4

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (the **Player goal & fail state** field + MVP feature 4), scoped to this story:*

- [ ] The Rhythm Tap and Star Catch cards in Mini-Games open an intro, and "Start" launches `rhythm_tap_view` / `star_catch_view` instead of "Coming Soon".
- [ ] Each view's `finished(score, earned)` is connected and shows a result screen with score and earned ⭐.
- [ ] Scores above the saved best are stored in `best_scores["rhythm"]` / `["catch"]`; the hub card shows the best.
- [ ] `earned` is added via `GameState.earn_points` exactly once per run.
- [ ] Each result has "play again" and "back to Mini-Games".
- [ ] Both games complete a full run (26 notes / 40 seconds) with no errors.

---

## Implementation Notes

- `scenes/screens/games_screen.gd`: `_on_rhythm_pressed()` and `_on_catch_pressed()` build the "Coming Soon" intros.
- Follow `_start_zap_game()` in `battle_screen.gd` for the view-launch pattern; reuse `_build_result` here.
- `best_scores` already has `rhythm` and `catch` keys.

---

## Out of Scope

- Reward rebalancing (`/balance-check`).

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: retained screenshots of both games (intro and result) in `production/qa/evidence/`. Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: None
