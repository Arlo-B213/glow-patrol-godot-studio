# Story 048: Constellation map

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Feature
> **Type**: UI
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-11

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Enhancement batch 4 (Signature Features), 2026-10-11
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH (per `docs/engine-reference/godot/VERSION.md`)

A sky map where Star Points unlock regions. Each unlocked region reveals a lore fragment, linking spending to story.

## Acceptance Criteria

- [ ] (a) Map shows at least 6 sky regions, each with a SP unlock cost and a locked/unlocked state
- [ ] (b) Unlocking a region costs SP once and persists in the save file
- [ ] (c) Each region reveals one lore fragment on unlock, shown once
- [ ] (d) Locked regions show cost and hint text, not spoilers
- [ ] (e) Unit tests cover unlock cost deduction, insufficient SP rejection and persistence round-trip
- [ ] (f) Retained screenshots of locked and unlocked states in `production/qa/evidence/story-048-constellation-map/`

## Out of Scope

Lore writing (narrative owns text; placeholder text allowed); arc progression (Story 020).

## Implementation Notes

Region definitions, costs and lore keys are data. Lore text is referenced by key so it can be localized later.

## QA Test Cases

- **AC-1**: Unlock
  - Given: 100 SP, region cost 60
  - When: Player unlocks
  - Then: SP is 40, region unlocked, lore fragment shown once
  - Edge cases: 59 SP rejects unlock with no change

- **AC-2**: Persistence
  - Setup: Unlock a region, save, restart
  - Verify: Region still unlocked; lore not shown again
  - Pass condition: State restored exactly

## Test Evidence

**Story Type**: UI
**Required evidence**: unit tests at `tests/unit/constellation/constellation_test.gd`; screenshots in `production/qa/evidence/story-048-constellation-map/`.

## Dependencies

Builds on Story 019 (rewards) and Story 004 (first arc, which already saves progress in `GameState`). Unlock state saves through `GameState`.
