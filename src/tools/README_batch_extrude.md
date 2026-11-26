# Batch extrude sprites to 2.5D meshes

`tools/batch_extrude.gd` turns every `.png` in a folder into an extruded 3D slab and saves each one as a `.tres` mesh. The mesh uses the sprite's own pixels, so the art style is unchanged. The slabs cast 3D shadows and take 3D lights through a `MeshInstance3D`.

## Run it

1. In the Godot editor, open `tools/batch_extrude.gd` in the Script Editor.
2. Open **File > Run** (or press **Ctrl+Shift+X**).
3. The Output panel prints `batch_extrude: wrote N mesh(es) to res://assets/meshes_25d`.

To change the source or output folder, depth, or pixel size, edit the constants at the top of the script and run it again.

## Settings

| Constant | Default | Meaning |
|---|---|---|
| `SOURCE_DIR` | `res://assets/art/characters/breaker/parts` | Folder scanned for `.png` files (not recursive). |
| `OUTPUT_DIR` | `res://assets/meshes_25d` | Where `.tres` meshes are saved. Created if missing. |
| `DEPTH` | `0.12` | Slab thickness in world units. |
| `PIXEL_SIZE` | `0.01` | World units per sprite pixel. |
| `ALPHA_THRESHOLD` | `0.5` | Alpha above this counts as solid. |
| `SIMPLIFY_EPSILON` | `2.0` | Outline simplification in pixels. Larger means fewer side walls. |

## Using a mesh

Drag a `.tres` from `assets/meshes_25d/` into a 3D scene as a `MeshInstance3D`. Give it a `StandardMaterial3D` with the sprite as the albedo texture and enable alpha scissor or transparency, so the cut-out edges show.

## Limits

- Holes in a sprite are filled. The outline is traced per island, and holes are not subtracted.
- The `SpriteMesh` plugin is not used. This script builds the mesh directly with built-in APIs.
- The script changes nothing in the 2D game. Its output is only read by 3D scenes.
