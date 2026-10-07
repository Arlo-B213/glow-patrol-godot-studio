# Adoption Plan

> **Generated**: 2026-10-07
> **Project phase**: Production (inferred: 13 GDScript files + 8 scenes in `src/`; no `project.stage` set)
> **Engine**: Godot 4.7 (Forward Plus) per `src/project.godot` — **not configured** in `project.yaml`
> **Rigor**: minimal (the design record is `design/game-brief.md`)
> **Template version**: v1.1.2

Work through these steps in order. Check off each item as you complete it.
Re-run `/adopt` anytime to check remaining gaps.

Audit summary: 0 GDDs, 0 ADRs, 0 stories. At `minimal`, GDDs/ADRs/stories are not
expected, so none of those count as gaps. No v1.0 config to migrate.

---

## Step 1: Fix Blocking Gaps

None.

---

## Step 2: Fix High-Priority Gaps

### 2a. Configure the engine in `project.yaml`
`project.yaml` has no `engine:` block, so every engine-aware skill and agent has
nothing to read. The project is Godot 4.7 / GDScript / Forward Plus.
Run `/setup-engine godot 4.7`
**Time**: 15 min
- [ ] `engine.name`, `version`, `language`, `rendering`, `physics` set in `project.yaml`

### 2b. Write the design record: `design/game-brief.md`
At `minimal` the brief is the only design document, and it does not exist. The
existing game is the source of truth, so reverse-document it rather than
brainstorming from scratch. Use the web build in
`design/reference/glowstick-patrol-web.html` and the Godot scenes in `src/scenes/`
(HQ, Club, Games, Study, Battle screens; Zap Patrol, Star Catch, Rhythm Tap and
Alley Brawl mini-games).
Run `/reverse-document` (or `/brainstorm` if you want to redesign), then check the
six required brief fields against `.claude/docs/templates/game-brief.md`.
**Time**: 1 session
- [ ] `design/game-brief.md` exists with all six required fields filled

---

## Step 3: Bootstrap Infrastructure

Not on the minimal path — the brief's build order is the plan. Next: `/create-stories`
(or `/dev-story` once stories exist).

---

## Step 4: Medium-Priority Gaps

### 4a. Engine reference pinned to the wrong version
`docs/engine-reference/godot/VERSION.md` pins Godot 4.6 with `Installed at pin time:
NOT DETERMINED`. The project is on 4.7, which the reference does not cover.
`/setup-engine` (step 2a) probes the installed editor and records the result; check
that it pins 4.7 and note any API changes since 4.6 before trusting the reference.
**Time**: 15 min
- [ ] `VERSION.md` shows the installed editor version and pins 4.7

---

## Step 5: Optional Improvements

- [ ] Add `src/addons/godot_ai` (an MCP editor bridge) to the project docs if you
  want agents to use it; it currently failed to connect in this environment.
- [ ] Decide whether to keep `design/reference/glowstick-patrol-web.html` (283 KB) in git.

---

## What to Expect from Existing Stories

There are none yet. When `/create-stories` runs, they are generated in the current
format and need no migration.

---

## Re-run

Run `/adopt` again after completing Step 2 to verify the HIGH gaps are resolved.
