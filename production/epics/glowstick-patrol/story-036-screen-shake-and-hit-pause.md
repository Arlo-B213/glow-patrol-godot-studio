# Story 036: Screen shake and hit pause in Alley Brawl

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

Alley Brawl hits currently land without impact feedback. Add a short camera shake and a brief hit pause (time scale dip) on enemy hits, so strikes feel weighty for kids aged 6–11.

## Acceptance Criteria

- [ ] (a) Landing a hit on an enemy triggers a camera shake of ~0.15 s; strength scales with the hit's damage (capped)
- [ ] (b) Each hit freezes the attacker and target for ~60–80 ms (hit pause), then resumes at normal speed
- [ ] (c) Shake and pause are suppressed when reduce motion is enabled (shake off; pause kept at most 40 ms)
- [ ] (d) Shake and pause do not stack into a runaway freeze when several hits land in one frame
- [ ] (e) Retained screenshots/clip in `production/qa/evidence/story-036-screen-shake-and-hit-pause/`

## Out of Scope

Haptics (Story 040); enemy hit reaction art (Story 031); balance of damage values.

## Implementation Notes

Files: `src/scenes/battle/` brawl combat and camera owner. Keep tuning values (shake strength, pause ms) in a data resource, not hardcoded.

## QA Test Cases

- **AC-1**: Hit triggers shake
  - Setup: Alley Brawl, stand next to one enemy, strike once
  - Verify: Camera offset moves and settles within ~0.15 s
  - Pass condition: Visible shake, returns to rest position

- **AC-2**: Hit pause
  - Setup: Strike once with frame capture
  - Verify: Attacker and target pause ~60–80 ms
  - Pass condition: Pause visible, no permanent slowdown afterwards

## Test Evidence

**Story Type**: UI/Feel
**Required evidence**: retained screenshots/clip in `production/qa/evidence/story-036-screen-shake-and-hit-pause/`.

## Dependencies

Builds on Story 025 (arena combat) and Story 021 (enemy variants).
