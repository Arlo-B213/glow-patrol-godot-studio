# Story 010: Shared UI theme and typography

> **Epic**: glowstick-patrol
> **Status**: Complete
> **Layer**: Feature
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Visual polish: one consistent, kid-friendly look (currently every screen styles itself inline with 9–15 px text)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (**Who it's for**: kids ~6–11; **Art & audio direction**: neon purple/pink/gold, glowing lanterns, portrait touch UI), scoped to this story. Everything is drawn in code or built with Godot's own Theme and built-in font; no downloaded assets.*

- [ ] One central theme defines the palette (background, panel, accent pink, gold, teal, violet, text) and is applied at the app root so every screen inherits it.
- [ ] A type scale exists (title, heading, body, caption) and all existing text is raised to it: body at least 14 px and captions at least 12 px at 720×1280, with no clipping or overflow on any of the 5 tabs or their sub-views.
- [ ] Button styles exist for normal, hover, pressed, disabled and focus in three variants — primary (pink), secondary (dark) and tab (with a clear selected state) — with rounded corners, a border and a subtle highlight; primary buttons are at least 48 px tall.
- [ ] Card styles exist for standard, highlighted/equipped and locked states, plus styles for progress bars and the scroll bar.
- [ ] Standard text colors come from the theme: screens no longer set their own font color and size for ordinary labels.
- [ ] The shell (top bar, tab bar, content area) uses the theme, and a screenshot of each of the 5 tabs shows no regression in function.
- [ ] Changing the accent color in one place updates buttons, tabs and bars (demonstrated by a before/after capture).

---

## Implementation Notes

- Use a Godot `Theme` resource (e.g. `src/theme/glowpatrol_theme.tres`, built by a script if easier) with type variations such as `PrimaryButton`, `SecondaryButton`, `TabButton`, `CardPanel`, `Heading`, `Caption`; set it as the project's custom theme in `project.godot` (`gui/theme/custom`) or on the root control.
- Built-in font only; adjust sizes and outline/shadow through the theme. No font downloads.
- The Compatibility renderer is required for web, so avoid shader-heavy effects; use `StyleBoxFlat` (border, corner radius, shadow) and `StyleBoxTexture` with a gradient texture where a gradient is wanted.
- Existing helpers that build the pink button inline (`start_style`, `again_style`, `next_style` and similar in `battle_screen.gd`, `games_screen.gd`, `study_screen.gd`) should switch to the theme variations, but wide per-screen rewrites belong to Story 013.
- Check docs/engine-reference/godot/ for Theme and StyleBox changes in 4.5–4.7 before relying on an API.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 011: the icon set.
- Story 013: restyling every screen's cards and layout.
- Story 014: top-bar redesign and motion.

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived**, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-010-shared-ui-theme-typography/`: the 5 tabs before and after, one screen per button state (normal, pressed, disabled), a type-scale sample, and the accent-color before/after pair. Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: Story 011, Story 013, Story 014

---

## Completion Notes
**Completed**: 2026-10-07
**Criteria**: 7/7 confirmed (one with a note); evidence 01–09 in `production/qa/evidence/story-010-shared-ui-theme-typography/`; all 11 captured views opened and checked for clipping/overflow. Not hand-played.
**Deviations**: None against scope. Added: quiz answer buttons were the same fill as their card and therefore invisible — given a lighter fill and border in `study_screen.gd`. Advisory: 27 `font_color` overrides remain in the screens (special-purpose gold/feedback colors and some ordinary muted labels) for Story 013; the Study grade pills are thin (~18 px) for touch (Story 013); cards are still flat text-only panels and intro cards are large empty panels (Stories 011/013); the scroll bar is styled in code but not seen in a screenshot.
**Test Evidence**: automated tests waived (`qa.level: minimal`); retained screenshots 01–09.
**Code Review**: Skipped (solo mode)
