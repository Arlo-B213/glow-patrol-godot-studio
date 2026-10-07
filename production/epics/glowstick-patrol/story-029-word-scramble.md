# Story 029: Word Scramble

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI/Feel
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Author request 2026-10-07 (mini-game upgrade round)
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH

A kid-friendly word scramble: letter tiles are shuffled, tap or drag tiles to spell the word, hint button, timer ring, streak and grade-appropriate word lists (grades 1-5 from GameState.grade), picture/emoji-free clue text, pets cheer.

## Acceptance Criteria

- [ ] Scrambled word tiles can be rearranged by tap/drag
- [ ] Grade-based word lists with clues
- [ ] Hints, timer, streak and payout
- [ ] Juice, audio, reduce motion

## Test Evidence

**Story Type**: UI/Feel
**Required evidence**: retained screenshots in `production/qa/evidence/story-029-word-scramble/`.

## Dependencies

None hard.

## Implementation Notes (autonomous run, 2026-10-07)

- Files: `src/scenes/games/scramble_view.gd` (Control, `finished(score, earned)`), `scramble_words.gd` (grade 1-5 lists, 32-35 words each, scramble logic). Status left Ready: screenshots not yet reviewed by the lead.
- Smoke script passed (never-equal shuffle, 8-word round, wrong answer, hint, timeout reveal, finished once). Windowed frame time ~6 ms.
- Unverified: drag-and-drop and keyboard typing on a real device; screenshots; audio; `scramble_view.gd` is ~516 lines (over the ~450 target). A wrong full answer returns all unlocked tiles to the tray.
