# Story 022: Kid-friendliness and onboarding

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Author request 2026-10-07 (enhancement round)
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH

First-run tutorial, grade picker for Study, daily star bonus and streak, larger touch targets (min 56 px), a stickers/collection page.

## Acceptance Criteria

- [x] A first-run tutorial runs once and can be skipped
- [x] Grade is selectable in the Study screen and saved
- [x] Daily bonus and streak work off the date and are saved
- [x] All primary buttons are at least 56 px tall
- [x] A stickers page shows collected stickers earned from milestones

## Out of Scope

Anything outside this story's title.

## Test Evidence

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-022-kid-friendliness-and-onboarding/`.

## Dependencies

None hard.

## Implementation Notes (autonomous run, 2026-10-07)

Done: TutorialOverlay (5 steps, Skip/Next 56 px, HQ "How to play" replay, honours reduce motion), Study grade picker (5 large pills, selected = primary style), Daily Glow Bonus (`DailyRewards`, `DailyPopup`; 10 + 2*min(streak-1,5) stars, no loss on missed days), Stickers (`Stickers.STICKERS`, 13 badges, `StickerPage`, HQ "Stickers" button, toast on earn), touch-target floor `UiTheme.MIN_TOUCH = 56` applied to every Button added under Main (deferred) plus top-bar icon buttons 56 px. New save fields: tutorial_done, streak, last_login_date, stickers. `GameState.save_game()` now respects `persist_saves`.

Headless/windowed smoke script passed (pure functions, tutorial flow, claim-once, sticker checks, page build, save file untouched).

Unverified (no screenshots taken): visual look and layout of tutorial card/spotlight, daily popup, sticker grid, Study pills, HQ extra button row (HQ height may be tight); effect of the global 56 px floor on other screens (games/pets/club buttons may grow); "5 high fives" is approximated as total Lanternboy affection >= 20; sound ids `coin`/`chapter` assumed fine by ear. Retained screenshots still required in `production/qa/evidence/story-022-kid-friendliness-and-onboarding/`.

Lead verification: evidence 01–05 opened and checked (daily popup's "+10" wrapped vertically; fixed and rechecked). Not verified: tutorial steps 2–5, the Club/Pets screens with the 56 px floor, hand play.
