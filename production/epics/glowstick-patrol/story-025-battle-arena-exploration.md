# Story 025: Battle arena exploration, blocking and movement

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Author request 2026-10-07 (Alley Brawl redesign)
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH

Alley Brawl was one fixed screen with a small walking strip, three flat buttons and nothing to explore. This story turns it into a scrolling three-district world with encounter zones, adds a block mechanic with a guard meter, new touch/keyboard controls and a redesigned HUD.

## Acceptance Criteria

- [ ] (a) The world scrolls with a follow camera and has 3 districts (Noodle Row, Neon Crossing, Lantern Bridge) with parallax scenery and ambient life (static under reduce motion)
- [ ] (b) The player can move with a drag-anywhere slider, round arrow buttons or the keyboard (A/D, arrows)
- [ ] (c) Block works (hold; negates damage and knockback from the facing side) with a guard meter, guard break and perfect block
- [ ] (d) Encounters happen at zones along the world with a pulsing GO arrow and a progress minimap; the boss waits at the far end
- [ ] (e) HUD is redesigned in the shared UiTheme style (hearts, guard bar, minimap, score and wave pills)
- [ ] (f) Finale option, debug boss flags, payout, pet companion and audio ids are unchanged
- [ ] (g) Retained screenshots by the lead in `production/qa/evidence/story-025-battle-arena-exploration/`

## Out of Scope

Anything outside this story's title.

## Test Evidence

**Story Type**: UI/Feel
**Required evidence**: retained screenshots in `production/qa/evidence/story-025-battle-arena-exploration/`.

## Dependencies

Builds on Story 021 (walk cycle, enemies, bosses) and Story 024 (pet companion).

## Implementation Notes

See the implementation report for files, verification and unverified items. Status moves to In Review only when every criterion above is confirmed.

Lead verification: evidence 01–07 opened and checked (3 districts with parallax, minimap/hearts/guard HUD, round controls with stick, zone fight, guard break, boss arena, block pose). Not verified: real touch hardware, feel/balance (speeds, guard numbers, zone spacing — zone 3 and the boss arena are only 0.6 screen apart), the GO arrow showing while enemies are on screen in one test shot (setup artifact, unconfirmed), hand play. `brawl_art_backdrop.gd` is now unused.
