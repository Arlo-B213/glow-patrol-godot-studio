# Story 018: Sound effects and music

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Author request 2026-10-07 (enhancement round)
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH

Audio is generated in code (no downloaded assets): short sound effects (punch, hit, star pickup, button tap, level-up, high five, chapter unlock, win, lose) and a looping chiptune-style music track per area, respecting `GameState.sound_on`; a music/SFX volume sense is not required. Hooks wired into battles, games, Club, HQ and the story.

## Acceptance Criteria

- [ ] Every listed sound effect exists and plays at its event
- [ ] Music loops without clicks and stops/starts with the Sound toggle
- [ ] Nothing plays when sound is off, and the game still runs headless without audio errors
- [ ] No external audio files are added

## Out of Scope

Anything outside this story's title.

## Test Evidence

**Story Type**: Logic
**Required evidence**: automated tests waived at qa.level minimal; run output saved under `production/qa/evidence/story-018-sound-effects-and-music/`.

## Dependencies

None hard.

## Implementation Notes (autonomous run, 2026-10-07)
Not closed — run `/story-done`. Audio is synthesized in code (`sfx.gd` autoload, `sfx_synth.gd`, `music_tracks.gd`, `snd.gd` safe wrapper): 20 SFX and 8 music loops, honouring the Sound toggle (`Snd.refresh()`). Wired: tab taps, per-screen music, battle/mini-game hits and results, quiz right/wrong, Club unlocks/errors/high five, pets, stars (`points_earned`), level-up. Checked only headless/no errors; **nothing has been listened to** (no audio verified by ear); each music track costs ~300 ms to render the first time it plays (small hitch). No external audio files.
