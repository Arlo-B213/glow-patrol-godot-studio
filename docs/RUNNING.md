# Running, testing and exporting Glowstick Patrol

Godot 4.7.2 (mono build is fine; the game is GDScript only). The Godot project is in `src/`.

## Run
```bash
godot --path src --windowed --resolution 720x1280
```
Debug flag for the boss fight: `-- --brawl-boss` (add `--brawl-boss-health=N`).

## Smoke tests
Headless logic checks live in `tests/smoke/`. They never write to the real save.
```bash
godot --headless --path src -s ../tests/smoke/logic_smoke.gd
```
Exit code 0 means all checks passed.

## Export
Presets for Web and Android are in `src/export_presets.cfg`. Install Godot export templates first
(Editor → Manage Export Templates), then:
```bash
godot --headless --path src --export-release "Web" ../build/web/index.html
godot --headless --path src --export-release "Android" ../build/android/glowstick-patrol.apk
```
Web uses the Compatibility renderer and no threads, so it runs on any static host.
Android needs the Android SDK/JDK set in Editor Settings and a keystore for signed release builds.
Not yet verified: no export templates were installed when these presets were written.

## Where saves live
`%APPDATA%/Godot/app_userdata/Glowstick Patrol/glowstick_patrol_save.json` (Windows).
