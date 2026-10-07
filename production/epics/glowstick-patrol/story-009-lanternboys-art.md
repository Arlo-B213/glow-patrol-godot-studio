# Story 009: Lanternboys character art

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief core loop (high-five the Lanternboys for affection); characters are unfinished — today Hae, Bit and Nun are colored bars in the Lounge

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (core loop, audience), scoped to this story. Original designs, drawn in code:*

- [ ] Hae, Bit and Nun each have their own character portrait with a distinct silhouette, hair, outfit and prop: Hae the leader carrying the biggest lantern, Bit the dancer, Nun the quiet one who talks to the moths.
- [ ] The Lounge list shows each portrait in place of the colored bar, keeping the name, role and friendship meter readable.
- [ ] The dialogue view for a Lanternboy shows a large portrait beside his line, and the high-five button gives a small reaction (a bounce or hearts) when pressed.
- [ ] Portraits keep each character's accent color (`GameState.LANTERNBOYS[*].color`).
- [ ] The three portraits are distinguishable from one another at the Lounge row size (contact sheet).
- [ ] Affection, the +2 ⭐ per high-five, and the dialogue lines are unchanged.

---

## Implementation Notes

- The Lounge is `club_screen.gd` `render_lounge()` / `open_dialogue()` / `_on_high_five_pressed()`; each Lanternboy currently uses `_lantern_panel(color, size, radius)` for his bar.
- Reuse helper functions from the shared hunter script (Story 006) for ellipses, alpha and faces; each character needs its own draw function.
- Hair and prop ideas: Hae — neat hair, big glowing lantern; Bit — messy hair, dancing pose, headphones; Nun — long hair, moths circling a small lantern.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 006–008: hunter portrait, outfits, weapons.
- New dialogue, new Lanternboys, or story-arc content (Story 004).

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived**, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-009-lanternboys-art/`: the Lounge list and each character's dialogue view. Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 006
- Unlocks: None

---

## Implementation Notes (autonomous run, 2026-10-07)
Built while the author was away; **not closed** — run `/story-done` to verify and close. New `lanternboy_art.gd` + `lanternboy_parts.gd` (code-drawn Hae, Bit, Nun) and `lanternboy_portrait.gd` (Control with bounce + sparkles); `club_cards.gd` gets `portrait_tile`; Lounge rows and the dialogue view use the portraits. Affection, +2 ⭐ and dialogue lines untouched (bounce is added in the button callback only). Evidence 01–04 opened and checked: three distinct characters at row and dialogue size, accent colours kept. Not verified: the high-five bounce/hearts in motion (not hand-pressed, to protect the real save), Nun's moths are tiny at row size, the portrait is stacked above the line rather than beside it, reduce-motion path reasoned from code. Not hand-played.
