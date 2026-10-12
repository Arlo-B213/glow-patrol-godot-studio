# Story 040: Haptic feedback on mobile

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-11

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Enhancement batch 1 (Feel & Juice), 2026-10-11
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH (per `docs/engine-reference/godot/VERSION.md`)

Add light vibration on mobile for key moments (enemy hit, SP burst, Zap Patrol strike) so the game feels tactile on phones and tablets.

## Acceptance Criteria

- [ ] (a) Haptic pulse fires on enemy hit, large SP grant and Zap Patrol strike, with per-event duration
- [ ] (b) On platforms without vibration support, calls are no-ops with no errors
- [ ] (c) A Haptics on/off toggle in Settings is saved and respected
- [ ] (d) Haptics default off when reduce motion is enabled
- [ ] (e) Unit test: haptic dispatcher maps events to durations and respects the toggle, with the vibration call injected (no real device needed)

## Out of Scope

Desktop/web controller rumble; audio cues (Story 018).

## Implementation Notes

Verify `Input.vibrate_handheld` against the Godot 4.7 docs in `docs/engine-reference/godot/` before coding (version is HIGH risk). Inject the vibration call so the dispatcher is unit-testable.

## QA Test Cases

- **AC-1**: Dispatcher mapping
  - Given: Mock vibration sink, haptics on
  - When: Enemy hit event fires
  - Then: One pulse with the configured duration
  - Edge cases: toggle off produces zero calls

- **AC-2**: Toggle persistence
  - Setup: Turn haptics off, restart the game
  - Verify: Still off
  - Pass condition: Setting persists

## Test Evidence

**Story Type**: Logic
**Required evidence**: unit test at `tests/unit/haptics/haptic_dispatcher_test.gd`.

## Dependencies

Builds on Story 036 (hit events). **Depends on Story 051 (Settings screen)** — the haptics toggle lives there.
