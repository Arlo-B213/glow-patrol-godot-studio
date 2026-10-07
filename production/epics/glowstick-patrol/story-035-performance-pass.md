# Story 035: Performance pass (visual upgrade fallout)

> **Epic**: glowstick-patrol
> **Status**: Ready
> **Layer**: Feature
> **Type**: UI/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal)
> **Last Updated**: 2026-10-07

## Context

The Story 031-034 visual upgrade made several scenes slow on the dev GPU (Quadro K610M, Compatibility, debug build). Target: average <= 16.6 ms and no spike > 33 ms in every scene, with no visual downgrade at normal sizes.

## Acceptance Criteria

- [ ] (a) Every scene averages <= 16.6 ms over 300 frames (benchmark below)
- [ ] (b) No frame > 33 ms in any scene; Sfx music render does not hitch gameplay
- [ ] (c) No gameplay, balance, save-format or public API change
- [ ] (d) Retained screenshots in `production/qa/evidence/story-035-performance-pass/`

## Baseline (measured 2026-10-07, 720x1280 windowed, vsync off, 300 frames after 30 warm-up)

| Scene | avg ms | worst ms | frames >33 | draws | prims |
|---|---|---|---|---|---|
| HQ | 14.4 | 23.5 | 0 | 824 | 40.7k |
| Club closet | 24.8 | 38.4 | 12 | 2949 | 88k |
| Club lounge | 22.0 | 44.8 | 7 | 1023 | 39k |
| Club style | 14.1 | 22.6 | 0 | 861 | 48k |
| Battle hub | 4.3 | 7.9 | 0 | 362 | 21k |
| Games hub | 5.3 | 9.7 | 0 | 513 | 30k |
| Study | 4.3 | 8.0 | 0 | 388 | 25k |
| Pets den | 6.6 | 10.0 | 0 | 491 | 30k |
| Brawl, 6 enemies | 38.4 | 55.0 | 299 | 1408 | 51k |
| Brawl, King | 27.0 | 54.9 | 21 | 1105 | 46k |
| Brawl, Hydra | 28.0 | 40.2 | 26 | 1231 | 51k |
| Star Catch | 19.3 | 39.0 | 3 | 826 | 36k |
| Zap Patrol | 27.6 | 55.4 | 85 | 1521 | 50k |
| Rhythm | 7.8 | 13.6 | 0 | 367 | 22k |
| Bubbles | 23.2 | 35.0 | 2 | 898 | 43k |
| Lantern | 9.3 | 20.4 | 0 | 437 | 29k |
| Memory | 19.6 | 29.8 | 0 | 898 | 52k |
| Scramble | 8.0 | 13.9 | 0 | 366 | 26k |

## Findings (profiled)

- Brawl `_draw` split (6 enemies): back scenery 1.7 ms, actors ~16 ms, fore 1.0 ms. Actors: mossback ~2.5 ms (116 draw calls), gloomling ~1.0 ms (46), blinker ~0.9 ms (45), hunter ~4.5 ms. The rest of the 38 ms is render-side cost of ~1400 draws / 51k primitives.
- Scenery and FX are NOT the main cost; the per-frame GDScript art of characters is.
- `env_brawl.gd:179` (FxLight.shaft in fore_extras, from `brawl_scenery.gd:201`) logs "Invalid polygon data, triangulation failed" (degenerate shaft polygon); also seen in Memory Match.

## Landed (round 2)

- Measured: draw_circle / draw_arc / draw_polyline / draw_colored_polygon / draw_polygon cost ~30 us per call (renderer builds a buffer each time); draw_mesh / draw_primitive / draw_line / draw_multiline / draw_rect cost 3-7 us.
- New `src/scripts/fast_draw.gd` (`FD`): drop-in helpers with the same arguments (circle, ellipse, arc, polyline, poly, gpoly). Circles/ellipses use cached disc meshes, convex polygons use draw_primitive quads, thin arcs/polylines use draw_multiline (concave polygons and very thick strokes fall back to the engine call). 65 art/UI/game scripts now call FD instead of the CanvasItem methods.
- `FD.gpoly` replaces draw_polygon for quads, which also removes the shaft "triangulation failed" error in Brawl.
- `gloom_kit.gd`: detail (crescents/highlights) threshold raised from 80 to 110 px; `hunter_fx.aura` uses ellipse meshes.
- Not done: sprite-bake cache, 20-30 Hz ambient layers, Sfx music-render threading, hunter detail LOD, Club closet.

## Status of work (original, superseded by Landed)

No optimisation has landed yet. An experimental sprite-sheet cache (bake characters to a SubViewport, draw as textured quads on a premultiplied-alpha layer) was designed but not finished and was removed to leave the tree clean. Benchmark: see `Implementation Notes`.

## Implementation Notes (plan, in payoff order)

1. Cache character art (enemies by type/colour/facing/walk-phase bucket; hunter by look/facing/walk or idle bucket) as baked sprites. Baked pixels are premultiplied, so they need a PREMULT_ALPHA layer; direct draws (hit flash, punch, pop-in) go on a normal layer above. Bake max 1 cell per frame; show nearest ready cell meanwhile. Same cache helps Club (hunter portraits, 2949 draws), pets, Lanternboys.
2. Fix the shaft triangulation error.
3. Star Catch / Zap / Bubbles / Memory: not yet profiled; apply 30 Hz redraw for ambient layers.
4. Move Sfx music render to WorkerThreadPool / incremental generation; preload additive material and first-use resources.

## After round 2 (avg / worst ms)

HQ 13.7/25, Closet 21.6/35.8, Lounge 13.8/25.8, Style 11.2/17.6, Pets 6.4/9.8, Brawl6 19.7/30.9, King 16.8/28.6, Hydra 17.7/26.6, Star Catch 12.8/24.1, Zap 12.5/27.0, Bubbles 13.3/20.3, Memory 9.7/15.4. Still over 16.6 avg: Club closet, Brawl6, Hydra, King (marginal).

## Benchmark

Script lived in the session scratchpad (loads main.tscn, `GameState.persist_saves=false`, per-scene setup, measures `process_frame` deltas). Re-create from the description above before closing this story.
