# Story 008: Weapon visuals

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief core loop (spend ⭐ on weapons); weapons are unfinished — today all 5 are a colored square in the shop and the same stick in battle

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (core loop), scoped to this story. Drawn in code:*

- [ ] Each of the 5 weapons has a distinct shape: Practice Glowstick (plain stick), Comet Baton (comet-tail head), Storm Rod (bolt head), Solar Scepter (ornate sun head), Galaxy Wand (star head with orbiting sparkles).
- [ ] The Weapons tab cards show the weapon's shape in its glow color instead of a plain square; locked and equipped states stay readable.
- [ ] The equipped weapon is drawn in the hunter's hand at rest and during the punch swing, in the Closet/Style preview, HQ avatar and Alley Brawl.
- [ ] The weapon glow color still comes from the `GameState.WEAPONS` data table.
- [ ] The swing trail and reach stay the same, so combat is unchanged (hit distances are Story 003's, not changed here).
- [ ] All 5 weapons are distinguishable at shop-card size (contact sheet).

---

## Implementation Notes

- Weapon drawing lives at the end of the hunter art (`draw_hunter`): currently a `#F5EFFF` line with a glow circle at the tip. Add a `style` field to each `GameState.WEAPONS` entry and a draw function per style.
- Reuse the shared hunter script from Story 006; keep the swing arc math (`ang`, `dir`, 54 × u reach).

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 003: weapon gameplay effects.
- Story 006 / 007: renderer and outfit designs.
- New weapons or price changes.

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived**, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-008-weapon-visuals/`: the Weapons tab, the 5-weapon contact sheet, and a punch swing in battle. Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 006
- Unlocks: None

---

## Implementation Notes (autonomous run, 2026-10-07)
Built while the author was away; **not closed** — run `/story-done` to verify and close. New `hunter_weapons.gd` (five shapes: stick, comet baton, storm rod, solar scepter, galaxy wand), `weapon_thumb.gd` (Weapons tab thumbnails), `style` field in `GameState.WEAPONS`, `weapon` in `hunter_look()`. Weapons appear in the hunter's hand in portrait and battle views and in the Weapons tab. Reach and trail are unchanged. Evidence 01–02 opened and checked: all five are distinguishable in hand and as thumbnails. Not verified: the weapon during an actual punch swing in battle (only idle/moving strips were seen on the sheet), the hero portrait with each weapon, and the sparkle wobble on the wand. Reduce-motion leaves the wand sparkles static (reasoned from code). Not hand-played.
