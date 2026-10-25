# Story 037: Star Point sparkle trail on collection

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Feature
> **Type**: UI/Feel
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-11

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Enhancement batch 1 (Feel & Juice), 2026-10-11
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH (per `docs/engine-reference/godot/VERSION.md`)

When a Star Point is collected, a short sparkle trail flies from the pickup to the top-bar star counter, reinforcing the core currency loop.

## Acceptance Criteria

- [ ] (a) Each collected SP spawns a sparkle that travels from its world position to the top-bar star icon
- [ ] (b) Trail lasts ~0.4–0.6 s; the counter increments when the sparkle arrives, not at pickup
- [ ] (c) Large SP grants emit a burst capped at a fixed particle count (no frame drops with 30 pickups)
- [ ] (d) Works across Alley Brawl, Star Catch and Zap Patrol
- [ ] (e) Retained screenshot in `production/qa/evidence/story-037-star-point-sparkle-trail/`

## Out of Scope

Top-bar pulse on save (Story 046); SP economy values (Story 019).

## Implementation Notes

Reuse the existing FX dictionary/helpers used by other effects. Particle count and duration are tuning knobs in data.

## QA Test Cases

- **AC-1**: Sparkle travels to counter
  - Setup: Collect one SP in any mini-game
  - Verify: Sparkle moves from pickup to top-bar star
  - Pass condition: Counter increments on arrival

- **AC-2**: Performance cap
  - Setup: Collect 30 SP rapidly
  - Verify: Frame time stays stable
  - Pass condition: No visible stutter, count capped

## Test Evidence

**Story Type**: UI/Feel
**Required evidence**: retained screenshot in `production/qa/evidence/story-037-star-point-sparkle-trail/`.

## Dependencies

Builds on Story 019 (rewards) and Story 014 (top bar).
