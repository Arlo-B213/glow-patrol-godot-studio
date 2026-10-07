# Story 005: Make the Study Hall playable

> **Epic**: glowstick-patrol
> **Status**: In Progress
> **Layer**: Feature
> **Type**: UI
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 6 (Study Hall quizzes by grade 1–5)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP feature 6 and the **Who it's for** line: kids ~6–11 get grade 1–5 practice), scoped to this story:*

- [ ] The Study tab opens the Study Hall hub ("Trainee Lessons", Grade 1–5 pills, Math / Grammar / Reading cards with best scores) instead of the "coming soon" placeholder.
- [ ] Tapping a grade pill highlights it, sets `GameState.grade`, and the choice is still selected after leaving and returning to the tab and after restarting the game.
- [ ] Each subject starts a round of the right length: Math 8, Grammar 5, Reading 3 questions, each with answer choices.
- [ ] A correct answer shows "Correct! +3 ⭐" and adds 3 points immediately (top bar updates); a wrong answer shows the right answer and adds nothing; answers lock after choosing.
- [ ] Finishing a round shows the results ("You got X/Y correct · Earned ⭐N") and "Back to Study Hall" returns to the hub.
- [ ] The best correct count per subject is saved in `best_scores` (`study_math`, `study_grammar`, `study_reading`) only when higher, and the hub cards show it.
- [ ] All 15 grade × subject combinations generate a full round with no errors and no empty or duplicate answer choices (checked by script).
- [ ] Leaving the tab mid-round frees the screen with no errors in the output.

---

## Implementation Notes

- `src/scenes/screens/study_screen.tscn` is a placeholder: no script, a centred "coming soon" label. `study_screen.gd` (about 520 lines, code written) reads `%Content` via `@onready`, so attaching the script and adding a `Content` node (`unique_name_in_owner = true`, full-rect Control) is the whole wiring.
- Follow `battle_screen.tscn` / `games_screen.tscn`: script ext_resource `uid://c4g8143env6uf` (the uid in `study_screen.gd.uid`), root `StudyScreen` keeps `uid="uid://0rtn456po6y7"`.
- `GRAMMAR_BANK` and `READING_BANK` are keyed by grade; confirm every grade 1–5 has entries, since a missing key would crash that grade.
- Per-answer points are earned as the player answers, not at the end of the round.

---

## Out of Scope

*Handled elsewhere or not part of this story:*

- Reward rebalancing (`/balance-check`). Note: +3 per correct answer has no cap, so a round can repeat for points.
- New questions or subjects, and changing the question generators.
- Story 003 (gear effects) and Story 004 (story arc).

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived**, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**: a retained screenshot of each screen touched (hub, a question, the results) in `production/qa/evidence/story-005-study-hall-screen/`. Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: None
