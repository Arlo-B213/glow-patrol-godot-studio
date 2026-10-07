# Story 021: Character and battle depth

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Author request 2026-10-07 (enhancement round)
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH

Walk cycle in battle, enemy hit reactions, two new Gloomling variants and a second boss, and story-linked outfit unlocks.

## Acceptance Criteria

- [ ] The hunter has a walk cycle distinct from idle in Alley Brawl
- [ ] Enemies flash/recoil on hit
- [ ] At least two new enemy designs and one new boss exist and appear in battle
- [ ] At least one outfit unlocks from a story chapter

## Out of Scope

Anything outside this story's title.

## Test Evidence

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-021-character-and-battle-depth/`.

## Dependencies

None hard.

## Implementation Notes (autonomous run, 2026-10-07)

Status stays **Ready**: the outfit-unlock criterion is data-only until game_state.gd / main.gd are hooked.

Done: distance-driven walk cycle with smooth blend (hunter_motion/hunter_art `walk_phase`, `walk_blend`); enemy flash/recoil/squash and defeat puff; new enemies Blinker and Mossback (`src/scripts/brawl_enemies.gd`, `ENEMY_TYPES`); second boss Hiccup Hydra (`brawl_art_hydra.gd`), selected by `boss_kind` (alternates per session run, or `--brawl-boss=hydra|king`); backdrop moved to `brawl_art_backdrop.gd`; `src/scripts/story_rewards.gd` holds chapter-linked outfit data.

Unverified: no human playtest; parse check and a 600-frame windowed smoke run were clean, screenshots in the scratchpad only (not retained in `production/qa/evidence/`). Walk-cycle look/feel, Mossback/Blinker balance, hydra readability and the boss alternation (session-only counter, not persisted) need a lead check. Outfit unlock needs hooking (see StoryRewards header comment). Reduce-motion path not exercised.

Lead verification: evidence 01–03 opened and checked (Blinker, Mossback and Gloomling; Hiccup Hydra with sneezing head; walk pose). The story-linked outfit unlock is hooked in Story 020. Not verified: the walk in motion, hit reactions in motion, balance of the new enemies, hand play.
