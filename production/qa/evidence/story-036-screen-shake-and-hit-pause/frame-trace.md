# Story 036 frame trace (2026-10-24)

Captured in a windowed run (1280x720, Godot 4.7.2) with a scripted probe, saving disabled.
Per 60 Hz frame after the first landed hit: `hs` = hit-pause ticks left, `sh` = shake px,
`t` = shake ticks left, `off` = camera shake offset px. Layout scale u = 1.5.

Normal (first jab, 1 damage): pause 4 ticks (~67 ms), shake 3.8 px, at rest after 9 ticks (0.15 s)

    0:hs=3 sh=3.8 t=7 off=2.0 | 1:hs=2 sh=3.8 t=6 off=1.0 | 2:hs=0 sh=3.8 t=4 off=1.7 |
    3:hs=0 t=3 off=1.3 | 4:hs=0 t=2 off=0.4 | 5:hs=0 t=1 off=0.4 | 6:hs=0 sh=0.0 t=0 off=0.0

Finisher (2 damage): shake 7.5 px (scales with damage; cap 6 px at u = 1).

Reduce motion: pause 2 ticks (~33 ms), no shake

    0:hs=2 sh=0.0 t=0 off=0.0 | 1:hs=1 sh=0.0 | 2:hs=0 sh=0.0

No-stacking (several hits in one frame) is covered by tests/smoke/logic_smoke.gd.
Tuning: src/scenes/battle/brawl_hit_feel.tres.
