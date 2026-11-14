# Story 047: Photo mode

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-11

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Enhancement batch 3 (Polish & Accessibility), 2026-10-11
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH (per `docs/engine-reference/godot/VERSION.md`)

Let kids pause a scene, hide the UI and save a screenshot of their hunter. Export is parent-gated because it writes files outside the game.

## Acceptance Criteria

- [ ] (a) Photo mode pauses the current scene and hides HUD and buttons
- [ ] (b) A parent gate (simple math or hold-to-confirm) is required before saving an image
- [ ] (c) Saved image is written to the user's pictures folder or the game's user:// folder with a timestamped name
- [ ] (d) Exiting photo mode restores the prior scene state and UI
- [ ] (e) On web builds the image is offered as a download instead of a file write
- [ ] (f) Retained screenshots of the mode and parent gate in `production/qa/evidence/story-047-photo-mode/`

## Out of Scope

Filters, stickers or sharing to social platforms.

## Implementation Notes

Capture from the viewport after a frame render. Parent gate state is not saved.

## QA Test Cases

- **AC-1**: Pause and hide
  - Setup: Enter Photo mode from HQ
  - Verify: Scene paused, HUD hidden
  - Pass condition: No UI visible except photo controls

- **AC-2**: Parent gate
  - Setup: Tap save
  - Verify: Gate appears and blocks save until passed
  - Pass condition: File written only after gate

## Test Evidence

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-047-photo-mode/`.

## Dependencies

Builds on Story 013 (screen polish) and Story 017 (hero portrait).
