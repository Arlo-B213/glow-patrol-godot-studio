# Story 042: Daily and weekly challenges with SP bonus

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-11

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Enhancement batch 2 (Gameplay Depth), 2026-10-11
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH (per `docs/engine-reference/godot/VERSION.md`)

Add a rotating set of daily and weekly challenges, such as "Defeat 10 Gloom with Sparkle Sword", that grant bonus Star Points. This is a retention loop.

## Acceptance Criteria

- [ ] (a) Three daily challenges are assigned per local calendar day; one weekly challenge per week
- [ ] (b) Each challenge tracks progress from existing gameplay events (battle wins, SP collected, games played)
- [ ] (c) Completing a challenge grants its SP bonus once; claiming is idempotent
- [ ] (d) Challenge selection is deterministic for a given date and seed (no random at runtime in tests)
- [ ] (e) Progress and claim state persist in the save file and survive restart
- [ ] (f) Unit tests cover assignment, progress, claim-once and day rollover

## Out of Scope

Live server events (Story 050 covers seasonal events); challenge art.

## Implementation Notes

Challenge definitions are data. Date comes from an injected clock so tests are deterministic.

## QA Test Cases

- **AC-1**: Progress and claim
  - Given: Challenge "Defeat 10 Gloom", progress 9
  - When: One more enemy defeated, then claim
  - Then: Complete; SP granted once; second claim is a no-op

- **AC-2**: Rollover
  - Given: Daily challenges for day N, injected clock moves to N+1
  - When: Challenges are loaded
  - Then: New set assigned; old progress not carried over

## Test Evidence

**Story Type**: Logic
**Required evidence**: unit tests at `tests/unit/challenges/challenge_test.gd`.

## Dependencies

Builds on Story 019 (reward pass). Progress and claim state saves through the existing `GameState` save (no separate save system exists).
