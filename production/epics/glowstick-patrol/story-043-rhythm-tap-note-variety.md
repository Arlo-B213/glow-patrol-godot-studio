# Story 043: Rhythm Tap hold notes, slide notes and call-and-response

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-11

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Enhancement batch 2 (Gameplay Depth), 2026-10-11
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH (per `docs/engine-reference/godot/VERSION.md`)

Rhythm Tap currently uses single taps. Add hold notes, slide notes, and "Lantern Says" call-and-response patterns for more depth as songs progress.

## Acceptance Criteria

- [ ] (a) Hold notes: press and keep held for the note's duration; release timing scores as a judgement
- [ ] (b) Slide notes: drag across a lane path; scoring uses start and end timing
- [ ] (c) Call-and-response: the game shows a pattern, the player repeats it; a wrong input breaks the streak only
- [ ] (d) Charts are data-driven; existing charts still play unchanged
- [ ] (e) Unit tests cover hold scoring, slide scoring and call-and-response matching with fixed timestamps
- [ ] (f) Retained screenshots of each note type in `production/qa/evidence/story-043-rhythm-tap-note-variety/`

## Out of Scope

New songs and audio (Story 018); difficulty tuning.

## Implementation Notes

Judgement windows reuse the existing Rhythm Tap timing constants. Note types are added to the chart format with a default type so old charts load.

## QA Test Cases

- **AC-1**: Hold note
  - Given: Hold note of 1.0 s
  - When: Player holds for 0.95–1.05 s
  - Then: Scored as perfect hold
  - Edge cases: released at 0.5 s scores as miss

- **AC-2**: Call-and-response
  - Given: Lantern Says pattern of 4 beats
  - When: Player repeats 3 correctly then 1 wrong
  - Then: Streak resets to 0; prior hits kept

## Test Evidence

**Story Type**: Logic
**Required evidence**: unit tests at `tests/unit/rhythm/note_types_test.gd`; screenshots in `production/qa/evidence/story-043-rhythm-tap-note-variety/`.

## Dependencies

Builds on Story 026 (Rhythm Tap and Lantern Says upgrade).
