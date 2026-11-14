# Story 050: Seasonal Glow Fest events

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-11

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Enhancement batch 4 (Signature Features), 2026-10-11
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH (per `docs/engine-reference/godot/VERSION.md`)

Limited-time Glow Fest events with exclusive outfits, a featured mini-game variant and event challenges. No server: events are data bundled with the game and gated by the local date.

## Acceptance Criteria

- [ ] (a) An event is defined in data with start date, end date, exclusive outfit IDs and a featured mini-game
- [ ] (b) Event items appear only between start and end dates (local date, injected clock in tests)
- [ ] (c) Event challenges reuse the Story 042 system and grant the event's exclusive reward
- [ ] (d) After an event ends, its outfits remain owned but cannot be newly earned
- [ ] (e) HQ shows an event banner with time remaining while an event is active
- [ ] (f) Unit tests cover active window, expiry and ownership retention with fixed dates
- [ ] (g) Retained screenshots of the banner and an event outfit in `production/qa/evidence/story-050-seasonal-glow-fest-events/`

## Out of Scope

Server-driven events; new outfit art (Story 007 pattern); event narrative.

## Implementation Notes

Event definitions live in a data file. The date source is injected. No network calls.

## QA Test Cases

- **AC-1**: Active window
  - Given: Event Mar 1–Mar 14, clock on Mar 5
  - When: HQ loads
  - Then: Banner shows, exclusive outfit is purchasable
  - Edge cases: Mar 15 shows event ended

- **AC-2**: Ownership retained
  - Given: Player bought an event outfit, then the event ends
  - When: Wardrobe loads
  - Then: Outfit still owned and equippable

## Test Evidence

**Story Type**: Integration
**Required evidence**: unit tests at `tests/unit/events/glow_fest_test.gd`; screenshots in `production/qa/evidence/story-050-seasonal-glow-fest-events/`.

## Dependencies

Builds on Story 042 (challenges), Story 007 (outfit designs) and Story 030 (games hub). Event ownership saves through `GameState`.
