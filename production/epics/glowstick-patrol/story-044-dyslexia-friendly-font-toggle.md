# Story 044: Dyslexia-friendly font toggle

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-11

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Enhancement batch 3 (Polish & Accessibility), 2026-10-11
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH (per `docs/engine-reference/godot/VERSION.md`)

Many 6–11 year olds read with dyslexia or early readers. Add a Settings toggle that swaps the UI font to OpenDyslexic (free, OFL-licensed).

## Acceptance Criteria

- [ ] (a) Settings has a "Dyslexia-friendly font" toggle, default off
- [ ] (b) Toggle swaps all UI text to OpenDyslexic from the shared theme without restart
- [ ] (c) Layouts do not clip or overflow with the wider font on the HQ tabs and Study Hall
- [ ] (d) Choice is saved and respected on next launch
- [ ] (e) Font licence file is included in the repository alongside the font
- [ ] (f) Retained screenshots, font on and off, in `production/qa/evidence/story-044-dyslexia-friendly-font-toggle/`

## Out of Scope

Font choice beyond this toggle; localization (separate work).

## Implementation Notes

Use the shared theme from Story 010 so one swap covers all controls. Confirm the OpenDyslexic licence before adding the file.

## QA Test Cases

- **AC-1**: Swap applies live
  - Setup: Settings, toggle on
  - Verify: Labels change to OpenDyslexic immediately
  - Pass condition: No restart needed

- **AC-2**: No overflow
  - Setup: Toggle on, open each HQ tab
  - Verify: No clipped text or buttons
  - Pass condition: All labels fully visible

## Test Evidence

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-044-dyslexia-friendly-font-toggle/`.

## Dependencies

Builds on Story 010 (shared UI theme and typography). **Depends on Story 051 (Settings screen)** — the toggle lives there.
