# Story 041: Gear set bonuses

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

Gear currently affects battles individually (Story 003, provisional numbers). Add set bonuses, such as the Moonlight Set (+20% crit), so collecting a matching outfit and weapon gives kids a clear collection goal.

## Acceptance Criteria

- [ ] (a) Gear items carry a set ID; a set bonus applies when all listed pieces are equipped
- [ ] (b) At least 3 sets defined in data (e.g. Moonlight Set: +20% crit), each with a visible name and icon
- [ ] (c) Equipping a partial set shows the bonus as "2 of 3 pieces" with no effect applied
- [ ] (d) Bonuses stack with, and are clamped by, the existing Story 003 caps
- [ ] (e) Unit tests cover full set, partial set, and cap clamping with fixed inputs

## Out of Scope

New gear art; the provisional numbers in Story 003 (tuned via `/balance-check`, Story 019).

## Implementation Notes

Set definitions live in a data file, not code. Battle stat resolution sums modifiers then applies caps once.

## QA Test Cases

- **AC-1**: Full set
  - Given: Moonlight Set, all three pieces equipped
  - When: Battle stats are resolved
  - Then: Crit chance includes +20%
  - Edge cases: piece removed mid-session drops the bonus

- **AC-2**: Partial set
  - Given: Two of three Moonlight pieces
  - When: Stats are resolved
  - Then: No set bonus; UI shows "2 of 3"

## Test Evidence

**Story Type**: Logic
**Required evidence**: unit tests at `tests/unit/gear/gear_set_bonus_test.gd`.

## Dependencies

Builds on Story 003 (gear affects battles) and Story 007 (outfit designs).
