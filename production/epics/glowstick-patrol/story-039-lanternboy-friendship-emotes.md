# Story 039: Lanternboy reaction emotes on friendship milestones

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Feature
> **Type**: UI/Feel
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-11

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Enhancement batch 1 (Feel & Juice), 2026-10-11
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH (per `docs/engine-reference/godot/VERSION.md`)

When a Lanternboy friendship reaches a milestone, that Lanternboy plays a short reaction emote (wave, heart, sparkle hop). This gives the social-emotional payoff the target age group responds to.

## Acceptance Criteria

- [ ] (a) Each friendship milestone (existing thresholds) triggers one emote on the matching Lanternboy
- [ ] (b) Emote lasts 1–2 s, then the Lanternboy returns to idle
- [ ] (c) Emote plays once per milestone; reloading the save does not replay it
- [ ] (d) Reduce motion: emote shows as a static icon bubble instead of animation
- [ ] (e) Retained screenshots in `production/qa/evidence/story-039-lanternboy-friendship-emotes/`

## Out of Scope

New Lanternboy art (Story 032); friendship thresholds and SP costs (Story 019).

## Implementation Notes

Store "milestone shown" per Lanternboy in the save file so milestones fire once. Emote set is data-driven.

## QA Test Cases

- **AC-1**: Milestone emote
  - Setup: Raise one Lanternboy's friendship to a milestone
  - Verify: Emote plays once on the Lanternboy
  - Pass condition: Emote visible, then idle resumes

- **AC-2**: No replay
  - Setup: Save, quit, reload
  - Verify: Milestone emote does not replay
  - Pass condition: No emote on reload

## Test Evidence

**Story Type**: UI/Feel
**Required evidence**: retained screenshots in `production/qa/evidence/story-039-lanternboy-friendship-emotes/`.

## Dependencies

Builds on Story 009 (Lanternboy art) and the friendship system from Story 020 (arc).
