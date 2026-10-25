# Story 051: Settings screen

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-11

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Prerequisite for enhancement stories 040, 044 and 045, 2026-10-11
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH (per `docs/engine-reference/godot/VERSION.md`)

No Settings screen exists in stories 001–035. Stories 040 (haptics), 044 (dyslexia font) and 045 (colorblind palettes) each need a toggle or picker in one place. This story creates that screen with the controls those stories plug into.

## Acceptance Criteria

- [ ] (a) A Settings screen is reachable from HQ and returns to HQ on close
- [ ] (b) Screen hosts: Haptics on/off (040), Dyslexia-friendly font on/off (044), Colour palette Off/Protan/Deutan/Tritan (045), and Reduce motion on/off (used by 036, 038, 039, 046)
- [ ] (c) Each control writes to `GameState` settings and persists across restart
- [ ] (d) Controls not yet implemented by their owning stories are shown disabled with "coming soon" rather than hidden
- [ ] (e) Unit tests: each setting round-trips through save and load with fixed values
- [ ] (f) Retained screenshots of the screen in `production/qa/evidence/story-051-settings-screen/`

## Out of Scope

The effects of each setting (owned by stories 036–046); audio volume (Story 018).

## Implementation Notes

Settings are stored in `GameState` next to existing progress data. **Reuse the existing `GameState.reduce_motion` flag** (`src/scripts/game_state.gd:171`, toggled from the top bar in `src/scenes/ui/top_bar.gd`) and `GameState.sound_on` (`game_state.gd:169`, toggled in `src/scripts/main.gd:178`). Do not add a second reduce-motion flag. The Settings screen shows these alongside the new controls.

## QA Test Cases

- **AC-1**: Round trip
  - Given: Haptics off, palette Deutan, dyslexia font on, reduce motion on
  - When: Game is saved and reloaded
  - Then: All four settings restored exactly

- **AC-2**: Navigation
  - Setup: Open Settings from HQ, then close
  - Verify: Returns to HQ with no state change
  - Pass condition: HQ shown, settings unchanged

## Test Evidence

**Story Type**: UI
**Required evidence**: unit tests at `tests/unit/settings/settings_test.gd`; screenshots in `production/qa/evidence/story-051-settings-screen/`.

## Dependencies

Builds on the HQ screen (Story 013 polish) and `GameState` save. **Must be done before** stories 040, 044 and 045.
