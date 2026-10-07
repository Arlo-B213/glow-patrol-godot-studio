# Story 004: First story arc

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: —

> **BLOCKED**: the brief says battles should advance a story, but no story content, structure or progression rule exists in the code or the brief. Design it first (`/quick-design story-arc`), then fill in the acceptance criteria below.

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 7

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (the **Player goal & fail state** field), scoped to this story:*

- [ ] Completing battles advances a story the player can see (confirmed intent).
- [ ] *(to be written after the arc is designed — length, beats, how progress is shown, and how it ties to Lanternboy affection are all undecided)*

---

## Implementation Notes

- Existing hooks: `GameState` (add story progress to the save), Battle hub, Lounge dialogue (`LANTERNBOYS` lines).

---

## Out of Scope

- Anything beyond the first arc.

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: retained screenshots of the story UI in `production/qa/evidence/`. Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: story arc design decision; Stories 001–003 for battles to advance it
- Unlocks: None

---

## Implementation Notes (autonomous run, 2026-10-07) — PROVISIONAL DESIGN
Built while the author was away; **the arc was never designed with the author, so everything here is a placeholder for your call before closing.** Chosen: a 5-chapter original arc "The Dimming Streets" (`src/scripts/story_arc.gd`, data-driven: chapter unlocks at 1/2/4/6/9 cleared patrols, each first unlock pays 10 ⭐ and shows a toast); a cleared patrol = Alley Brawl win or a Zap Patrol with score > 0; progress (`story_wins`, `story_claimed`) is saved in `GameState`. The Battle hub has a "The Dimming Streets" card that opens the chapter list. Chapters feature Hae/Nun/Bit in the text only (no affection tie-in). Evidence 01–02 opened and checked; logic checked by calling `record_battle_win()` (1st win → chapter 1, 2nd → chapter 2, 3rd → none). Not verified: the toast after a real result screen, a full 9-win playthrough, hand play. Tuning knobs: `CHAPTERS` (wins, text) and `REWARD_PER_CHAPTER`. Replace the arc entirely if you have a story in mind.
