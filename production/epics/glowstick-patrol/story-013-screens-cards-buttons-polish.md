# Story 013: Screen, card and button polish

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Visual polish: every screen looks cohesive, illustrated and inviting

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (**Who it's for**: kids ~6–11; **Art & audio direction**: neon purple/pink/gold, glowing lanterns, portrait touch UI), scoped to this story. Everything is drawn in code or built with Godot's own Theme and built-in font; no downloaded assets.*

- [ ] The HQ navigation cards show an illustrated icon, a heading and a short description with clear hierarchy and generous tap targets.
- [ ] The Study subject cards, Mini-Games cards and Battle mode cards use the icon set (or illustrated icons drawn for them) instead of tiny emoji.
- [ ] The Club tabs (Closet, Style, Weapons, Lounge) use the theme's standard, equipped and locked card states with a clear equipped badge and a readable price.
- [ ] The shared intro and result screens (Zap Patrol, Alley Brawl, Rhythm Tap, Star Catch, Memory Match, Lantern Says, Study results) use the primary and secondary button variations and a consistent layout.
- [ ] No screen builds its own pink button or card style inline any more; each uses a theme variation.
- [ ] All 5 tabs and every sub-view are captured at 720×1280 with no clipping, overflow or text under 12 px.
- [ ] The quiz question screen, mini-game HUDs and battle HUD keep their function and readability.

---

## Implementation Notes

- Replace the inline `StyleBoxFlat` blocks (pink buttons, mode cards) with theme variations from Story 010.
- Illustrated icons for cards can be larger variants of the Story 011 icons or purpose-drawn art, in code.
- Work screen by screen and capture each one.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 010 and 011 work.
- Top-bar redesign and motion (Story 014).
- Lanternboys art (Story 009).

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived**, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-013-screens-cards-buttons-polish/`: every tab and sub-view before and after, intro and result screens for two games, and the Club states (equipped, locked, normal). Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 010, Story 011
- Unlocks: None

---

## Implementation Notes (autonomous run, 2026-10-07)
Built while the author was away; **not closed** — run `/story-done` to verify and close. New: `ui_cards.gd` (mode/intro/result cards, icon tiles), `ui_icons_cards.gd` (12 card icons), `club_cards.gd`, `ModeCard` theme variation, `forward` arrow icon. Restyled HQ nav, Battle/Games/Study hubs, shared intro and result screens, Study grade pills (44 px), Club Closet/Style/Weapons/Lounge (EQUIPPED pill, star price chips, lantern tiles, friendship meters), Lounge dialogue, quiz question screen (progress bar, 56 px answers), Memory Match and Lantern Says (icons instead of emoji). Found and fixed: card chevrons pointed left (added `forward` icon). Evidence 01–12, all opened. Remaining: 8 intentional `font_color` overrides (gold/feedback text), `toast.gd` light pill and `hq_screen` outfit tile kept; the Weapons tab was captured but not opened; result screens for Games/Study were not captured (only the Battle result). Not hand-played.
