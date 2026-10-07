# Story 015: Hunter detail pass: shading, outlines and finer details

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Visual polish: a richer, more detailed hunter in both battle and portrait modes

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (**Who it's for**: kids ~6–11; **Art & audio direction**: neon purple/pink/gold, glowing lanterns, portrait touch UI), scoped to this story. Everything is drawn in code or built with Godot's own Theme and built-in font; no downloaded assets.*

- [ ] A soft outline surrounds the hunter's silhouette in both the side-view and portrait modes and stays clean on dark and light backgrounds.
- [ ] Two-tone shading is applied to the jacket or outfit, skin and hair: a shadow side and a highlight, consistent for all 8 outfits.
- [ ] Hair has highlights and strand detail, for both hairstyles and all 6 colors.
- [ ] The face has more detail: eyes with iris, highlight and lashes, nose and mouth hints, and eyebrows.
- [ ] Hands show finger detail, shoes have soles and trims, and clothing shows seams and trims.
- [ ] Headwear and face accessories keep working with the new detail (8 outfits × 2 hairstyles × headwear contact sheets).
- [ ] The hunter stays legible at battle size (about 70 px tall) and at Closet-card size, with a before/after comparison.
- [ ] Drawing cost is checked: the battle view keeps its frame rate with the hunter on screen.

---

## Implementation Notes

- Work in `src/scripts/hunter_art.gd`, `hunter_outfits.gd` and `hunter_accessories.gd`; keep files under about 450 lines by splitting out a shading helper.
- Use polygon layering and `draw_polyline` outlines; avoid per-frame allocations in `_draw` where possible.
- Make sure every new polygon is simple (non-self-intersecting): a self-crossing hanbok ribbon silently failed in Story 007.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Animation (Story 016).
- Large hero portrait (Story 017).
- New outfits or accessories.

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived**, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-015-hunter-detail-pass/`: before/after contact sheets, the 8 outfits in both modes, hair colors and hairstyles, and the battle hunter at actual size. Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: Story 012, Story 016, Story 017

---

## Implementation Notes (autonomous run, 2026-10-07)
Built while the author was away; **not closed** — run `/story-done` to verify and close. New files: `hunter_shade.gd` (outline and two-tone shading helpers), `hunter_limbs.gd`, `hunter_face.gd`, `hunter_outfit_kit.gd`, `hunter_outfits_b.gd`; reworked `hunter_art.gd`, `hunter_outfits.gd`. Added: soft outlines, shaded skin/hair/legs/boots, hair highlights and strands, larger eyes with iris, lashes, brows, nose/mouth, hands with finger detail, boot soles, and per-outfit seams, trims, plates, pleats and sparkles. Battle view measured at about 148 fps (vsync off) with the new art. Evidence 01–05 opened and checked; "before" for comparison is `production/qa/evidence/story-007-distinct-outfit-designs/01-*`. Not hand-played; glasses/headwear over the new eyes were checked by the agent's 60-look smoke run (no errors), and visually only on the earlier contact sheet.
