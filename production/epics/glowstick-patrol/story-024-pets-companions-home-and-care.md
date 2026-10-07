# Story 024: Pets: companions, home and care

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI
> **Estimate**: XL
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Author request 2026-10-07 (enhancement round)
**ADR**: N/A (minimal) | **Engine**: Godot 4.7.2 | **Risk**: HIGH

A Pet Den section with a place to feed, pet and watch pets grow. Original pet species including an axolotl-like 'Xolo' (xocoatl); pets join the player in battle as a small companion. Stages: egg, baby, child, adult, driven by care and time-light activity (kid-friendly, no punishing death). Needs: hunger and happiness that only slow growth, never harm.

## Acceptance Criteria

- [ ] A Pets tab/section exists with a home scene showing the active pet
- [ ] Pets can be fed (cost stars), petted (animated reaction + hearts) and grow through at least 3 stages
- [ ] At least 3 original pet species including an axolotl-like one
- [ ] The active pet appears as a companion in Alley Brawl and assists lightly (no balance break)
- [ ] Pets and their care state persist in the save and never die or get punished
- [ ] Evidence screenshots of the home, feeding, petting and growth stages

## Out of Scope

Anything outside this story's title.

## Test Evidence

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-024-pets-companions-home-and-care/`.

## Dependencies

None hard.

## Implementation Notes (autonomous run, 2026-10-07)

- **Data/logic**: `GameState.PETS` (xolo, puff, sparkfox; egg cost, growth thresholds, zap timing/boss chip), `PET_*` tuning consts, `owned_pets`/`active_pet` saved with defaults for old saves. API: `adopt_pet`, `can_feed`/`feed_pet` (3 stars), `pet_pet` (4 s cooldown), `pet_stage`, `pet_progress`, `set_active_pet`, `active_pet_id`, `refresh_pet_needs`, `decay_needs` (static, pure), signals `pet_changed`, `pet_stage_changed`, `active_pet_changed`. Needs decay gently with real time (max 24 h counted, floor 10); low needs only slow growth (x0.4), never harm. All PROVISIONAL tuning.
- **Art**: `scripts/pet_art.gd` + `pet_art_species.gd` (code-drawn, simple polygons, eggs/baby/child/adult, blink, breathing, wag, happy/sleepy moods; still when reduce motion). `scenes/ui/pet_view.gd` (PetView, `pet()`, `react()`), `scenes/ui/pet_den.gd` (room).
- **Screen**: 6th tab "Pets" (new `paw` and `bowl` icons), `scenes/screens/pets_screen.gd/.tscn`: Den, Pet Shop, switch-pet picker, grew-up popup.
- **Battle**: `scenes/battle/pet_companion.gd` used by `alley_brawl_view.gd`; zap every 7-9 s removes the nearest Gloomling (+1 score) or chips the boss by 1 (never its last health point).
- **Not done**: HQ sidekick (optional, skipped). Screenshot evidence still to be captured by the lead.
- **Checked**: parse check on all files; headless/windowed smoke of care logic, 108 art views, screen build, popup, shop, picker. Real save untouched.

Lead verification: evidence 01–05 in `production/qa/evidence/story-024-pets-companions-home-and-care/` opened and checked (shop, den: egg/baby/adult xolo, child puff). Not verified: the battle companion live, feed/pet reactions in motion, hand play. Old-save loading was checked by the build agent.
