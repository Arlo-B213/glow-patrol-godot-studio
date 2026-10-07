# Story 020: Story arc expansion and finale

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Author request 2026-10-07 (enhancement round)
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH

Replace placeholder arc with a fuller 'The Dimming Streets' (author text still welcome): each Lanternboy gets arc scenes unlocked by affection, a finale boss fight flagged to the last chapter, a win screen and rewards (an outfit and a pet egg), arc replay.

## Acceptance Criteria

- [ ] Arc scenes per Lanternboy unlock at affection thresholds
- [ ] The final chapter launches a boss patrol and shows a win screen on victory
- [ ] Finale rewards are granted once and saved
- [ ] Evidence screenshots of scene, finale and win screen

## Out of Scope

Anything outside this story's title.

## Test Evidence

**Story Type**: Integration
**Required evidence**: retained screenshots in `production/qa/evidence/story-020-story-arc-expansion-and-finale/`.

## Dependencies

None hard.

## Implementation Notes (autonomous run, 2026-10-07)

- **All story text is PROVISIONAL** (chapters in `story_arc.gd`, 6 Lanternboy scenes in `arc_scenes.gd`, finale epilogue): original text written while the author was away; replace freely.
- Scenes: Hae/Bit/Nun at affection 20 and 60; Lounge dialogue shows a 56 px Story scene button (new scene opens directly, otherwise replay list). First view pays +15 stars once and plays the chapter sound; `seen_scenes` saved.
- Finale: Face the Grumble King launches Alley Brawl with `finale = true` (King, 12 health, no waves). Win pays once (`finale_done`): +50 stars, Lantern Hero Cape, free Sparkfox egg (else +20 stars). Loss: Try Again, no penalty. Replay finale pays no rewards.
- Outfits: Lamplighter Robe unlocks with chapter 1 (toast); Lantern Hero Cape is granted by the finale. `GameState.all_outfits()` feeds the Closet and HQ counter.
- Verified by smoke script (logic checks all OK, screenshots rendered). NOT verified: real hand-played finale difficulty/balance, win-card look judged by a human, audio, old-save load from a real file, toast stacking for chapter + outfit toasts. Evidence screenshots still need retaining in `production/qa/evidence/story-020-story-arc-expansion-and-finale/`.

Lead verification: evidence 01–04 opened and checked. Found and fixed two layout bugs (the story panel rendered blank and the win card was squeezed into a narrow column; both fixed by `set_anchors_and_offsets_preset`) and re-checked. Not verified: a hand-played finale (12 boss health is a guess), the loss screen, audio, loading a real old save.
