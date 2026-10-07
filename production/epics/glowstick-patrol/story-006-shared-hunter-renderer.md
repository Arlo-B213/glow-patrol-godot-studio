# Story 006: Shared hunter renderer, live preview and style items

> **Epic**: glowstick-patrol
> **Status**: Complete
> **Layer**: Feature
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief core loop (spend ⭐ in the Clubhouse on outfits, hair and accessories); characters and costumes are unfinished

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (core loop + audience), scoped to this story. Art is drawn in code (vector shapes in GDScript), as the Alley Brawl hunter is:*

- [ ] One shared drawing script draws the hunter in two modes: a front-facing **portrait** and the existing side-view **battle** pose. Alley Brawl uses the shared script and looks the same as before (compare to `production/qa/evidence/story-001-wire-alley-brawl/04-brawl-punch-swing.png`).
- [ ] A reusable portrait control shows the hunter from the player's equipped items; HQ's avatar square is replaced by it and updates when the player returns to HQ after equipping.
- [ ] The Closet and Style tabs show a live portrait at the top that updates as soon as an item is equipped.
- [ ] Both hairstyles (Classic Bob, Twin Tails) and all six hair colors render correctly in portrait.
- [ ] All four headwear items are drawn on the head — Ribbon Bow, Star Clip, Flower Crown, Cat Ears — and "No Headwear" draws nothing.
- [ ] All three face accessories are drawn on the face — Rosy Blush, Star Glasses, Freckles — and "No Accessory" draws nothing.
- [ ] Headwear and face accessories also appear on the Alley Brawl hunter.
- [ ] A contact sheet of every headwear × hairstyle combination (10) is captured and none overlaps badly (bow on twin-tail roots, cat ears under a flower crown, etc.).

---

## Implementation Notes

- The hunter currently lives in `src/scenes/battle/brawl_art.gd` (`BrawlArt.draw_hunter(ci, x, ground_y, u, facing, anim_t, moving, alpha, punch_active, look)`), with `look = {outfit, hair, glow, hairstyle}` built in `alley_brawl_view.gd._ready()`.
- Extract it into a shared script (suggest `src/scripts/hunter_art.gd`) that keeps the side-view mode and adds a portrait mode; keep `BrawlArt` for the Gloomlings and boss.
- Add a `GameState.hunter_look()` helper that returns the dictionary (outfit, hair, glow, hairstyle, **headwear**, **face_acc**) so every screen builds it the same way. `GameState` already holds `headwear` and `face_acc` ids.
- Portrait control: a small `Control` with `_draw()` that calls the shared script; give it a `refresh()` the screens call after equipping.
- Use `modulate`/alpha helpers already in the art script (`_c`, `_ellipse`).

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 007: distinct designs per outfit (this story keeps the single jacket shape, recolored).
- Story 008: weapon shapes.
- Story 009: Lanternboys art.
- Buying, unlock, or price changes.

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived**, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-006-shared-hunter-renderer/` of HQ, the Closet and Style tabs with the live preview, the 10-combination contact sheet, and the brawl hunter. Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: Story 007, Story 008, Story 009

---

## Completion Notes
**Completed**: 2026-10-07
**Criteria**: 8/8 confirmed by retained screenshots (evidence 01–10 in `production/qa/evidence/story-006-shared-hunter-renderer/`); equip → live portrait and HQ update verified by driving the real Closet button in a script (save backed up and restored), not hand-played.
**Deviations**: None against scope. Advisory: idle bob has no motion-preference setting (`idle_bob` can be switched off per instance); the front portrait is a chibi pose, a different style from the side-view battle hunter; Closet outfit cards are still color squares (Story 007). Jet Black hair is low-contrast on the dark background.
**Test Evidence**: automated tests waived (`qa.level: minimal`); retained screenshots 01–10.
**Code Review**: Skipped (solo mode)
