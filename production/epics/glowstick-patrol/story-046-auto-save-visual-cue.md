# Story 046: Auto-save visual cue

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Presentation
> **Type**: UI/Feel
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-11

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Enhancement batch 3 (Polish & Accessibility), 2026-10-11
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH (per `docs/engine-reference/godot/VERSION.md`)

Kids should notice that their progress is safe. When the game auto-saves, the top-bar star icon gives a small glow pulse.

## Acceptance Criteria

- [ ] (a) Each successful save triggers one glow pulse on the top-bar star icon (~0.5 s)
- [ ] (b) A failed save shows a different, non-alarming cue (dimmed icon) and does not pulse
- [ ] (c) Saves that happen in quick succession do not stack pulses (max one active at a time)
- [ ] (d) Reduce motion: the cue becomes a brief static highlight
- [ ] (e) Retained clip/screenshots in `production/qa/evidence/story-046-auto-save-visual-cue/`

## Out of Scope

Save logic changes; a save-status text message.

## Implementation Notes

Listen for the existing save result signal; do not add a second save path.

## QA Test Cases

- **AC-1**: Pulse on save
  - Setup: Earn an SP to trigger auto-save
  - Verify: Star icon pulses once
  - Pass condition: Single pulse visible

- **AC-2**: Failed save
  - Setup: Make the save path unwritable (test only)
  - Verify: Dimmed icon, no pulse
  - Pass condition: Cue differs from success

## Test Evidence

**Story Type**: UI/Feel
**Required evidence**: retained clip/screenshots in `production/qa/evidence/story-046-auto-save-visual-cue/`.

## Dependencies

Builds on Story 014 (top bar redesign and motion) and the save system.
