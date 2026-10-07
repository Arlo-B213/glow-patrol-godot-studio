# Story 012: Game and app icon

> **Epic**: glowstick-patrol
> **Status**: In Review
> **Layer**: Feature
> **Type**: UI
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Visual polish: an icon that makes kids want to open the game (currently Godot's default)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (**Who it's for**: kids ~6–11; **Art & audio direction**: neon purple/pink/gold, glowing lanterns, portrait touch UI), scoped to this story. Everything is drawn in code or built with Godot's own Theme and built-in font; no downloaded assets.*

- [ ] An original icon design — a stylised hunter with a glowing glowstick against a star or lantern glow in the pink, violet and gold palette — is readable at 16, 32, 64, 128, 256 and 512 px.
- [ ] The icon is rendered from the shared hunter art by a script and saved as PNG files in the project; the generator script is kept so the icon can be regenerated.
- [ ] `config/icon` is set so the window, taskbar and exports use it, and a web favicon-size version is provided.
- [ ] The icon has no small text and keeps a clear silhouette on both dark and light backgrounds (checked on both).
- [ ] A contact sheet of the icon at all sizes on dark and light backgrounds is captured.

---

## Implementation Notes

- Render into a `SubViewport` or an `Image` and `save_png` from a throwaway script; keep the final PNGs under `src/` (for example `src/icon.png`, `src/icon_512.png`) and the generator under `src/tools/` or `tools/`.
- Set `config/icon` in `src/project.godot`; for web export presets (not created yet) note the favicon path for when they are.
- Use the improved hunter art from Story 015 so the icon matches the final look.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Export presets and platform store art.
- Splash screen.

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are **waived**, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-012-game-app-icon/`: the icon contact sheet at all sizes on dark and light backgrounds, and the window/taskbar showing the icon. Automated tests waived at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 015
- Unlocks: None

---

## Implementation Notes (autonomous run, 2026-10-07)
Built while the author was away; **not closed** — run `/story-done` to verify and close. Generator: `src/tools/make_icon.gd` (run windowed: `godot --path src --windowed -s res://tools/make_icon.gd`) with art in `src/tools/icon_art.gd` (rounded violet-to-pink square, gold halo, spotlight, the shared hunter bust with twin tails and a star clip, sparkles). Wrote `src/icon.png` (256 px, set as `config/icon` in `project.godot`), `icon_512/256/128/64/32/16.png` (32 px doubles as the web favicon size). Evidence: 512 px icon and a sheet of all sizes on dark and light backgrounds (the sheet's layout overlaps larger icons — a test-layout flaw, not the art; each size is still legible; the 16 px version is a small pink blob with a face). Not verified: the window/taskbar actually showing the icon at runtime (only the import step ran), export presets. The glow rings show faintly through the face at 512 px.
