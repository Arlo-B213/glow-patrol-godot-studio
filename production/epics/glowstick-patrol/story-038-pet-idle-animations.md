# Story 038: Pet idle animations

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Feature
> **Type**: UI/Feel
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-11

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Enhancement batch 1 (Feel & Juice), 2026-10-11
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH (per `docs/engine-reference/godot/VERSION.md`)

Pets are a retention hook. Give each pet looping idle motion (tail wag, glow pulse) so they feel alive on the home screen and in battle.

## Acceptance Criteria

- [ ] (a) Every pet has a tail/ear idle loop (~2 s) and a glow pulse (~3 s), offset per pet so they do not sync
- [ ] (b) Idle motion pauses while the pet is fed or petted, and resumes after
- [ ] (c) Reduce motion: glow pulse becomes static; tail wag stops
- [ ] (d) No added per-frame allocations (verified in profiler)
- [ ] (e) Retained clip/screenshots in `production/qa/evidence/story-038-pet-idle-animations/`

## Out of Scope

New pet art (Story 033); pet care mechanics (Story 024).

## Implementation Notes

Drive motion from the existing pet draw code with a time phase; no new scene nodes unless needed.

## QA Test Cases

- **AC-1**: Idle loop plays
  - Setup: Open Home with each pet
  - Verify: Tail and glow move continuously
  - Pass condition: Motion visible for each pet, out of phase

- **AC-2**: Reduce motion
  - Setup: Enable reduce motion, reopen Home
  - Verify: Pets static apart from breathing
  - Pass condition: No looping tail or pulse

## Test Evidence

**Story Type**: UI/Feel
**Required evidence**: retained clip/screenshots in `production/qa/evidence/story-038-pet-idle-animations/`.

## Dependencies

Builds on Story 024 (pets) and Story 033 (pets visual upgrade).
