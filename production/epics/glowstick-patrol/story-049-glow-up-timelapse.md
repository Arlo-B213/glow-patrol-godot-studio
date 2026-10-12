# Story 049: "Glow Up" timelapse

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Presentation
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-11

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Enhancement batch 4 (Signature Features), 2026-10-11
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH (per `docs/engine-reference/godot/VERSION.md`)

Record about 30 seconds of the hunter's evolution (outfit, then pet, then home) as a short clip the child can replay or export. Parent-gated export, same as Story 047.

## Acceptance Criteria

- [ ] (a) "Glow Up" button on HQ records a 30 s sequence: outfit change, pet joined, home decoration, in that order
- [ ] (b) Sequence is built from the player's real saved state; a player with no changes gets a shorter "not yet" clip
- [ ] (c) Playback is available in-app with pause and replay
- [ ] (d) Export uses the same parent gate as Story 047
- [ ] (e) Recording does not change save data
- [ ] (f) Retained clip/screenshots in `production/qa/evidence/story-049-glow-up-timelapse/`

## Out of Scope

Music for the clip (Story 018 audio); sharing to social platforms.

## Implementation Notes

Capture the hunter, pet and home renderers in fixed poses at intervals and stitch frames. Do not re-run game logic during capture.

## QA Test Cases

- **AC-1**: Sequence content
  - Setup: Player with one outfit, one pet, one home item
  - Verify: Clip shows all three in order
  - Pass condition: Order correct, ~30 s

- **AC-2**: Save untouched
  - Setup: Record, then compare save file
  - Verify: Save file identical before and after
  - Pass condition: No change

## Test Evidence

**Story Type**: Integration
**Required evidence**: integration test at `tests/integration/glow_up/glow_up_test.gd`; retained clip in `production/qa/evidence/story-049-glow-up-timelapse/`.

## Dependencies

Builds on Story 006 (shared hunter renderer), Story 024 (pets and home) and Story 047 (parent gate).
