# Story 003: Gear affects battles

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 5

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (the **Player goal & fail state** field + MVP feature 5), scoped to this story:*

- [ ] Each of the 5 weapons (and, if chosen, outfits) has a defined effect value in the `GameState` data tables — not hardcoded in views. **Effect type needs author decision** (e.g. tap radius, hearts, boss damage).
- [ ] The equipped weapon's effect applies in Zap Patrol and in Alley Brawl.
- [ ] The default "Practice Glowstick" gives the current baseline behaviour (no regression).
- [ ] Higher-cost gear is measurably stronger, and the Clubhouse shows what each item does.
- [ ] Effects are applied at run start from `equipped_weapon` and survive save/load.

---

## Implementation Notes

- Weapons live in `GameState.WEAPONS` (`id`, `name`, `cost`, `glow`); add an effect field there.
- Zap Patrol hit test: `zap_patrol_view.gd` around the tap-position check; Brawl punch logic in `alley_brawl_view.gd`.
- Provisional numbers — rebalance with `/balance-check` afterwards.

---

## Out of Scope

- Outfit effects unless the author asks for them.
- Reward formula changes.

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: automated test waived at `qa.level: minimal` (advisory). Retained screenshot of the Clubhouse effect text in `production/qa/evidence/`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 001 (Brawl must be playable)
- Unlocks: None

---

## Implementation Notes (autonomous run, 2026-10-07) — PROVISIONAL DESIGN
Built while the author was away; **the design was never decided with the author, so the numbers are provisional and need your call before this is closed.** Chosen: each weapon has a data-driven `reach` multiplier in `GameState.WEAPONS` (Practice Glowstick 1.0, Comet Baton 1.1, Storm Rod 1.2, Solar Scepter 1.3, Galaxy Wand 1.4), read once at the start of a run (`GameState.weapon_reach()`) and applied to the Zap Patrol tap radius (demons and boss) and the Alley Brawl punch reach (enemies and boss); the default weapon is the unchanged baseline. The Weapons tab shows each weapon's effect ('Reach +10%'). **Outfits do not have effects** (the story left that optional). Checked by a throwaway script (output saved as `production/qa/evidence/story-003-gear-affects-battles/02-reach-test-output.txt`) and the Weapons tab screenshot (`01`, opened). Not hand-played; the reward numbers are untouched; run `/balance-check`. Tuning knobs: the `reach` and `blurb` fields in `GameState.WEAPONS`. Replace the effect type entirely if you want something other than reach (damage, hearts, boss damage).
