# Story 045: Colorblind palette modes

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

The game relies on glow colours to signal state (enemy types, rhythm lanes, gear rarity). Add three palette modes (protanopia, deuteranopia, tritanopia) that remap these key colours to distinguishable alternatives.

## Acceptance Criteria

- [ ] (a) Settings offers Off / Protan / Deutan / Tritan, default Off
- [ ] (b) Mode remaps the palette used for rhythm lanes, enemy type tints, rarity and HUD warnings
- [ ] (c) Every state signal also has a non-colour cue (shape or icon), so no information is colour-only
- [ ] (d) Palettes are data-driven; adding a fourth mode requires no code change
- [ ] (e) Unit test: each mode's palette keeps required contrast pairs above threshold
- [ ] (f) Retained screenshots of each mode in `production/qa/evidence/story-045-colorblind-palette-modes/`

## Out of Scope

Full art re-skin; high-contrast mode.

## Implementation Notes

Palette lookup goes through the shared theme/colour helper. Contrast check uses a fixed WCAG ratio in the test.

## QA Test Cases

- **AC-1**: Mode applies
  - Setup: Set Deutan mode, open Rhythm Tap
  - Verify: Lanes remain distinguishable
  - Pass condition: Lanes differ by colour and shape

- **AC-2**: Contrast
  - Given: Each palette
  - When: Contrast pairs are computed
  - Then: All pairs ≥ threshold
  - Edge cases: Off mode uses existing palette unchanged

## Test Evidence

**Story Type**: UI
**Required evidence**: unit test at `tests/unit/theme/palette_modes_test.gd`; screenshots in `production/qa/evidence/story-045-colorblind-palette-modes/`.

## Dependencies

Builds on Story 010 (shared theme) and Story 013 (screen polish). **Depends on Story 051 (Settings screen)** — the palette picker lives there.
