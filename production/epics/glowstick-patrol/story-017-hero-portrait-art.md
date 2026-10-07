# Story 017: Large full-body hero portrait

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Visual polish: a big, detailed hunter as the hero of HQ and the Closet

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (**Who it's for**: kids ~6–11; **Art & audio direction**: neon purple/pink/gold, glowing lanterns, portrait touch UI), scoped to this story. Everything is drawn in code or built with Godot's own Theme and built-in font; no downloaded assets.*

- [ ] A large full-body hunter portrait (about 300 × 460 px) shows the detailed outfit, hair, accessories and the weapon in hand, in a confident pose with personality.
- [ ] It has a subtle stage backdrop (spotlight, glow and sparkles) that uses theme colors.
- [ ] HQ features the portrait as its hero area with the greeting and level beside or below it, and the layout still fits at 720×1280.
- [ ] The Closet and Style tabs use the large portrait as their live preview, updating as items are equipped.
- [ ] The portrait respects the reduce-motion setting and has no rendering errors across all outfits, hairstyles and headwear.
- [ ] Contact sheets of at least 8 outfits and a few full style combinations at the large size are captured.

---

## Implementation Notes

- Extend `HunterArt.draw_portrait` with a hero mode, or add `draw_hero`, building on Story 015's detail; the existing portrait control `hunter_portrait.gd` scales to any rect.
- Keep the small portraits (HQ avatar, Closet cards) cheap to draw.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Lanternboys portraits (Story 009).
- New poses or emotes.

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived**, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-017-hero-portrait-art/`: HQ and the Closet at actual size, outfit contact sheet at the large size, and a style-combination sheet. Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 015
- Unlocks: None

---

## Implementation Notes (autonomous run, 2026-10-07)
Built while the author was away; **not closed** — run `/story-done` to verify and close. New `hunter_hero.gd` (`draw_hero`: stage backdrop with spotlight, halo, stage disc and sparkles, hunter full body); `HunterPortrait.hero`; HQ now has a 300×420 hero card with greeting, XP and stats beside it; Closet/Style previews use a 260×340 hero. Found and fixed: at 300 px wide the portrait fell back to the bust crop (character floated above an empty stage) — the inner rect is now kept narrow so the full body is always used. Evidence 01–03 opened and checked (04 is the Closet capture from before that fix, kept for reference; the Closet itself was not re-captured after the fix, only HQ and Style). Reduce-motion was reasoned from the code (`draw_hero` checks `HunterMotion.motion_on()`), not run. The right column on HQ has some empty space under the stat tiles. Not hand-played.
