# Story 016: Hunter animation

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Visual polish: a hunter that feels alive

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (**Who it's for**: kids ~6–11; **Art & audio direction**: neon purple/pink/gold, glowing lanterns, portrait touch UI), scoped to this story. Everything is drawn in code or built with Godot's own Theme and built-in font; no downloaded assets.*

- [ ] The hunter blinks every 3 to 5 seconds and has a subtle breathing motion in idle, in portrait and battle.
- [ ] Hair, skirts, capes and coat tails sway with movement and settle when idle.
- [ ] A proper walk cycle swings the arms and legs with a small body bounce.
- [ ] Punching has a wind-up, swing and recovery, and being hurt shows a flash plus a knockback pose.
- [ ] The glowstick glow pulses gently in idle.
- [ ] All animation can be turned off by the reduce-motion setting (Story 014), leaving a still pose.
- [ ] Frame-strip sheets are captured for the walk (4 frames), punch (4 frames), blink and sway.

---

## Implementation Notes

- Drive animation from `anim_t` and the existing `punch_active` / `player_invincible` counters, not new nodes.
- Keep hit distances the same: animation is visual only.
- Check frame rate in battle with 6+ Gloomlings on screen.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- New attacks or combat changes.
- Gloomling and boss animation upgrades.

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived**, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-016-hunter-animation/`: frame strips for walk, punch, blink and sway, and the reduce-motion still pose. Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 015
- Unlocks: None

---

## Implementation Notes (autonomous run, 2026-10-07)
Built while the author was away; **not closed** — run `/story-done` to verify and close. New `hunter_motion.gd`; `draw_hunter` gained trailing optional `hurt_t` and `animate`; `draw_portrait` gained `animate`; the brawl view passes `hurt_t` from `player_invincible`. Added blink (~0.12 s every 3–5 s), breathing, hair/skirt sway, a 24-frame walk cycle, punch anticipation/strike/recovery, hurt knockback pose with flash, and a glow pulse; `animate=false` or reduce-motion draws a still pose. Evidence 01 (frame strips: walk, punch, hurt, still pose, blink) opened and checked. Known limits (from the build and my review): the walk snaps to idle when the player stops (no settling), hurt is skipped under reduce-motion, turning reduce-motion back on while a portrait is visible does not restart it until it refreshes. Walk-cycle legs are mostly hidden by long skirts in the hanbok strip, so it was not judged on that outfit alone. In-game feel and frame rate with animation were not measured; not hand-played.
