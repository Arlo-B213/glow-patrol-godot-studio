# Story 011: UI icon set and tab bar icons

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Visual polish: clear drawn icons instead of text-only tabs and tiny emoji

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (**Who it's for**: kids ~6–11; **Art & audio direction**: neon purple/pink/gold, glowing lanterns, portrait touch UI), scoped to this story. Everything is drawn in code or built with Godot's own Theme and built-in font; no downloaded assets.*

- [ ] A shared script draws a set of original icons in code: Star Points, level badge, heart, outfit/hanger, friendship heart, sound on, sound off, and one icon per tab — HQ, Club, Battle, Games, Study — plus back and close arrows.
- [ ] A reusable `UiIcon` control takes an icon name, size and tint and stays crisp and centred from 24 to 64 px.
- [ ] The tab bar shows each tab's icon above its label, and the selected tab's icon is highlighted using theme colors.
- [ ] The top bar and HQ stat tiles use the star, level, outfit and friendship icons instead of text-only or emoji.
- [ ] The sound button shows the on and off icons.
- [ ] A contact sheet of every icon at 24, 40 and 64 px shows each one is recognisable; icons use theme colors so they follow an accent change.

---

## Implementation Notes

- Mirror how `hunter_art.gd` draws with `CanvasItem` calls: a static `ui_icons.gd` with one `draw_<name>(ci, rect, tint)` per icon and a small `ui_icon.gd` Control wrapper.
- Keep strokes and fills simple and bold so they read at small sizes; use a consistent corner radius and line weight across the set.
- Tab buttons are built in `main.tscn`; add the icon inside each tab button or swap to a custom tab control.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 013: icons on menu and subject cards.
- Story 012: the app icon.

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived**, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-011-ui-icon-set/`: the icon contact sheet at three sizes, the tab bar with a selected state, and the top bar and HQ stat tiles. Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 010
- Unlocks: Story 013, Story 014

---

## Implementation Notes (autonomous run, 2026-10-07)
Built while the author was away; **not closed** — run `/story-done` to verify and close. 14 icons (star, level, heart, outfit, friendship, sound_on, sound_off, home, club, battle, games, study, back, close) in `ui_icons.gd`/`ui_icons_tabs.gd` with shared helpers in `ui_icon_kit.gd` and a `UiIcon` control. Tab bar shows icon above label with a highlighted selected state; top bar uses star/level/sound icons; HQ stat tiles use star/outfit/friendship icons. Found and fixed: the first heart looked like a gem. Evidence 01–02 opened and checked. Not hand-played; the Club/Battle/Games/Study tab icons were seen only in the HQ tab bar capture.
