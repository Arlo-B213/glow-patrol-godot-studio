# Balance — Glowstick Patrol (provisional, 2026-10-07)

Written during an autonomous run; the numbers are targets to playtest, not facts.

## Pacing targets
- First outfit (Stage Sparkle, 40 ⭐) after ~2 runs of any mode.
- A casual day (≈6 battles/games + 1 quiz + a pet feed or two) earns ≈ 100 ⭐.
- The whole shop (outfits 870 + weapons 510 = 1380 ⭐, plus pets) takes ≈ 2 weeks of casual play.

## Current payouts (before this pass)
- Zap Patrol / Alley Brawl: `earned = max(5, round(score / 2))`. Observed best Brawl score 16 → 8 ⭐/run.
  At ≈ 8 ⭐/run the shop would take ≈ 140 runs. Too slow for 6–11 year-olds.
- Study quiz: 3 ⭐ per correct answer (a 10-question quiz ≈ 30 ⭐ at best).
- High five: +2 ⭐. Story chapter: +10 ⭐ each (5 chapters).

## Changes (applied in Story 019)
- Battle payout becomes `earned = clamp(score, 10, 40)` (≈ 15 ⭐ for an average run, hard cap to protect pacing). Data: `GameState.PAYOUT`.
- Study, high five and chapter rewards unchanged.
- Shop prices unchanged (they already ramp 40 → 260 outfits, 60 → 220 weapons).
- Pet food costs a few ⭐ per feed (see `GameState.PETS`); pets are optional so they never gate progress.

## Open questions for the author
- Is a 2-week full-shop target right, or do you want it faster/slower?
- Should weapons cost more than outfits, since they have an effect?
- Daily bonus size once Story 022 lands (suggest 10 ⭐ + 2 per streak day, max 20).
