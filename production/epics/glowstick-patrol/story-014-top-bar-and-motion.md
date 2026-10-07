# Story 014: Top bar redesign and motion

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Visual polish: a lively, rewarding interface for kids

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (**Who it's for**: kids ~6–11; **Art & audio direction**: neon purple/pink/gold, glowing lanterns, portrait touch UI), scoped to this story. Everything is drawn in code or built with Godot's own Theme and built-in font; no downloaded assets.*

- [ ] The top bar is redesigned with a star counter using the star icon and a level badge showing XP progress as a ring or bar, plus the sound icon button.
- [ ] The star count animates (counts up) when points change, and a small floating '+N' with a star pops up where points are earned.
- [ ] The selected tab animates (a small scale or slide) and presses give visible feedback (scale and brightness) on all buttons that use the theme.
- [ ] Switching tabs uses a short transition (fade or slide, no longer than 200 ms) that never blocks input.
- [ ] Levelling up triggers a short celebration (a sparkle or confetti burst and a toast).
- [ ] A reduce-motion setting turns every animation off, is saved with the game, and is reachable from the top bar or an obvious spot.
- [ ] Animations are checked by captured frame strips and cause no errors or dropped input.

---

## Implementation Notes

- `GameState` already has the `points_changed` and `leveled_up` signals; hook the animations to them.
- Prefer `Tween` and simple `_draw` particles; keep the Compatibility renderer and web in mind.
- Add `reduce_motion` to the save data alongside `sound_on`, defaulting to false, and keep backward compatibility with older saves.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Sound and music.
- Per-screen custom animations beyond the shared ones.

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived**, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-014-top-bar-and-motion/`: a frame strip of a points gain, a tab switch and a level-up, the redesigned top bar, and the reduce-motion setting. Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 010, Story 011
- Unlocks: None

---

## Implementation Notes (autonomous run, 2026-10-07)
Built while the author was away; **not closed** — run `/story-done` to verify and close. New: `ui_motion.gd`, `top_bar.gd`, `xp_ring.gd`, `sparkle_burst.gd`; `GameState.reduce_motion` (saved, old saves load with the default) and `points_earned` signal; motion toggle icons. Top bar: gold star pill with counting number, level badge with XP ring, sound and motion buttons. Points gain shows a '+N' pop, level-up shows a sparkle burst and a Toast, tabs pop when selected, every button gets press feedback, screen changes fade/slide in (<= 0.18 s). Found and fixed: `main.gd` referenced the `Toast` autoload by identifier (failed to compile in script-mode runs; now `get_node`), and the '+N' pop covered the counter (now starts below the pill). Evidence 01–05 opened and checked. Reduce-motion verified by setting it in memory (counter jumps, no pop or burst); the motion button's icon did not swap in that capture because the script did not call its update path, so toggling by click is unverified. Old-save compatibility is reasoned from `load_game` using `.get(key, default)`, not run. Not hand-played.
