# Story 019: Reward and balance pass

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: Config/Data
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Author request 2026-10-07 (enhancement round)
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH

Rewards were flagged 'needs rebalancing'. Define a reward table in data, review battle/game/study payouts, shop prices, story chapter rewards and pet costs against a target pacing (first outfit in ~2 runs, whole shop in ~2 weeks of casual play).

## Acceptance Criteria

- [ ] A written balance table in `design/balance.md` with the formulas and targets
- [ ] Payouts and prices live in data tables, not in views
- [ ] Prices and rewards adjusted to hit the pacing targets, with before/after noted

## Out of Scope

Anything outside this story's title.

## Test Evidence

**Story Type**: Config/Data
**Required evidence**: automated tests waived at qa.level minimal; run output saved under `production/qa/evidence/story-019-reward-and-balance-pass/`.

## Dependencies

None hard.

## Implementation Notes (autonomous run, 2026-10-07)
Not closed — run `/story-done`. Wrote `design/balance.md` (pacing targets, old/new payouts, open questions). Battle/game payout is now `GameState.payout_for(score)` = score clamped to 10–40 ⭐ (was `max(5, score/2)`). Prices unchanged. Targets are unplaytested guesses; tune `PAYOUT_MIN/MAX` and review the open questions in the doc.
