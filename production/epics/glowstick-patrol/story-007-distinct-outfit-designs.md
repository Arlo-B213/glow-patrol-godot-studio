# Story 007: Distinct outfit designs

> **Epic**: glowstick-patrol
> **Status**: Complete
> **Layer**: Feature
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief core loop (spend ⭐ on outfits); costumes are unfinished — today all 8 outfits are one jacket in a different color

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (core loop, audience), scoped to this story. Original designs in the idol-hunter spirit, drawn in code:*

- [ ] Each of the 8 outfits has its own silhouette plus 2–3 distinct details, not only a recolor: Practice Fit, Stage Sparkle, Beat Armor, Lantern Silk, Moonlit Hanbok, Encore Gold, Honor Roll Cape, Genius Galaxy Suit.
- [ ] Outfit look is selected by a data field on each entry in `GameState.OUTFITS` (not an `if id ==` chain in the drawing code).
- [ ] The Closet cards show a small hunter wearing each outfit instead of a plain color square; locked outfits are still visible and readable.
- [ ] The equipped outfit appears on the Closet/Style live preview, the HQ avatar and the Alley Brawl hunter, in both portrait and battle poses.
- [ ] The 8 outfits are visually distinguishable from one another at Closet-card size (contact sheet of all 8).
- [ ] Every outfit works with both hairstyles and all headwear without clipping badly (contact sheet of 8 outfits × 2 hairstyles).
- [ ] The existing outfit colors (outfit / hair defaults) from the data table are still honored.

---

## Implementation Notes

- Proposed designs (adjust freely): **Practice Fit** — track jacket with side stripe; **Stage Sparkle** — sequin stage jacket with star epaulettes; **Beat Armor** — light armor plates, shoulder guards; **Lantern Silk** — long silk robe with lantern motif; **Moonlit Hanbok** — hanbok-inspired short jacket, long skirt and a ribbon (an original design); **Encore Gold** — gold tailcoat; **Honor Roll Cape** — jacket with flowing cape; **Genius Galaxy Suit** — starry bodysuit with constellation sparkle.
- Build on the shared hunter script from Story 006; add an outfit-style switch driven by a `style` field in `GameState.OUTFITS`.
- Keep the body footprint (about 52 × 70 field px) so battle hit distances are unchanged.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 006: the shared renderer, previews, headwear and face accessories.
- Story 008: weapon shapes.
- New outfits, price changes, or outfit gameplay effects (Story 003).

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived**, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-007-distinct-outfit-designs/`: the Closet tab, the 8-outfit contact sheet, the 8 × 2 hairstyle contact sheet, and one outfit in battle. Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 006
- Unlocks: None

---

## Completion Notes
**Completed**: 2026-10-07
**Criteria**: 7/7 confirmed by retained screenshots (evidence 01–06 in `production/qa/evidence/story-007-distinct-outfit-designs/`); verified by script and screenshot, not hand-played.
**Deviations**: None against scope. A self-intersecting hanbok ribbon polygon (side view) was found and fixed during verification (0 render errors afterwards). Advisory: battle hit feel with the wider robe/hanbok/cape skirts (about ±20–23 field px) is unchecked; Closet mini-hunters are small (48×60 px); Encore Gold's coat is a bit muddy and Honor Roll Cape reads somewhat like a skirt in portrait; pixel sizes in the art are inline constants.
**Test Evidence**: automated tests waived (`qa.level: minimal`); retained screenshots 01–06.
**Code Review**: Skipped (solo mode)
