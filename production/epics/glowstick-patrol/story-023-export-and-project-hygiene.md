# Story 023: Export and project hygiene

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: Config/Data
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Author request 2026-10-07 (enhancement round)
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH

Web and Android export presets, tests moved to a root `tests/` folder with a runnable smoke test, a README run/export section.

## Acceptance Criteria

- [ ] Export presets exist for Web and Android
- [ ] A tests/ folder has at least a save round-trip test that runs headless
- [ ] The README explains running, testing and exporting

## Out of Scope

Anything outside this story's title.

## Test Evidence

**Story Type**: Config/Data
**Required evidence**: automated tests waived at qa.level minimal; run output saved under `production/qa/evidence/story-023-export-and-project-hygiene/`.

## Dependencies

None hard.

## Implementation Notes (autonomous run, 2026-10-07)
Not closed — run `/story-done`. Done: Web + Android presets in `src/export_presets.cfg`; `docs/RUNNING.md` (run, test, export, save location); `tests/smoke/logic_smoke.gd` (17 pure-logic checks, passes headless, never writes the save). **Not done / unverified:** no actual export was run (no export templates installed; Android needs SDK + keystore), and the README itself was not changed (the repo README is the studio template's; `docs/RUNNING.md` is the game's guide). The tests are plain scripts, not gdUnit4.
