# Story 034: Environment, lighting/FX toolkit and UI polish

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI/Feel
> **Estimate**: L
> **Last Updated**: 2026-10-07

## Context

Author brief: big visual upgrade beyond characters (kpop demon hunters flavour, kids 6-11).

## Done so far (partial)

- `src/scripts/fx_light.gd`, `fx_particles.gd`: code-drawn lighting/particle toolkit (reduce-motion safe).
- `src/scenes/battle/env_brawl.gd` + hooks in `brawl_scenery.gd`: clouds, hills, fog, neon spill, wet reflections, lamp pools, crowd + glow sticks, fireworks, weather, shafts, vignette.
- `src/scenes/ui/env_backdrop.gd` + `main.gd`: themed animated backdrop per tab screen.

## Also done

- fx_shine.gd (gloss/shine/tab glow), fx_wipe.gd, UiMotion.swipe_in, toast icon, star pill pop + sparkle, theme glow shadows, game_kit light pass.
- Evidence: production/qa/evidence/story-034-environment-lighting-and-ui-polish/

## Known issues

- Club screen ~25-34 ms/frame (hunter portrait cost, not backdrop); HQ ~18 ms.

## Not verified

- UI theme polish (gradients, shine on primary buttons, bars), tab-bar glow indicator, glow-wipe transition, icon-bearing toasts, star counter sparkle, mini-game backdrops (game_kit.gd) lighting pass, icon sheet review.

## Acceptance Criteria

- [ ] Every screen stable ~16 ms/frame; retained screenshots in `production/qa/evidence/`
