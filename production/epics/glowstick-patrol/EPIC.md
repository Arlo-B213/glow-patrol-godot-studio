# Epic: Glowstick Patrol (MVP)

> **Source**: `design/game-brief.md` (synthesized at `workflow: minimal`; no `/create-epics` run)
> **Engine**: Godot 4.7.2 | **Risk**: HIGH (per `docs/engine-reference/godot/VERSION.md`)

**Goal**: A K-pop idol demon-hunting game for kids, where tapping, brawling, rhythm and study mini-games earn Star Points to dress up your hunter and befriend the Lanternboys.

**Scope**: The brief's MVP list. Items 1 and 2 (shell/save, Zap Patrol) are already built and have no stories. The stories below cover items 3, 4, 5, 6 (Study Hall) and 7. The Mini-Games scene was also wired up inside Story 002. Stories 006–009 finish the characters and costumes (shared hunter renderer, outfits, weapons, Lanternboys), drawn in code. Stories 010–017 are a visual polish block for kids (shared theme and type, icon set, app icon, screen polish, top bar and motion, hunter detail, animation and hero art).

**Ordering** (brief Build order): wire the finished views first, then make gear matter, then rebalance rewards (`/balance-check`), then the story arc.

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Wire Alley Brawl into the Battle hub | Integration | Complete | N/A |
| 002 | Wire Rhythm Tap and Star Catch into Mini-Games | Integration | Ready | N/A |
| 003 | Gear affects battles (PROVISIONAL numbers) | Logic | In Review | N/A |
| 004 | First story arc | Feature | In Review | N/A |
| 005 | Make the Study Hall playable | UI | Ready | N/A |
| 006 | Shared hunter renderer, live preview and style items | UI | Complete | N/A |
| 007 | Distinct outfit designs | UI | Complete | N/A |
| 008 | Weapon visuals | UI | In Review | N/A |
| 009 | Lanternboys character art | UI | In Review | N/A |
| 010 | Shared UI theme and typography | UI | Complete | N/A |
| 011 | UI icon set and tab bar icons | UI | In Review | N/A |
| 012 | Game and app icon | UI | In Review | N/A |
| 013 | Screen, card and button polish | UI | In Review | N/A |
| 014 | Top bar redesign and motion | UI | In Review | N/A |
| 015 | Hunter detail pass: shading, outlines and finer details | UI | In Review | N/A |
| 016 | Hunter animation | UI | In Review | N/A |
| 017 | Large full-body hero portrait | UI | In Review | N/A |
| 018 | Sound effects and music | Logic | In Review | N/A |
| 019 | Reward and balance pass | Config/Data | In Review | N/A |
| 020 | Story arc expansion and finale | Integration | In Review | N/A |
| 021 | Character and battle depth | UI | In Review | N/A |
| 022 | Kid-friendliness and onboarding | UI | In Review | N/A |
| 023 | Export and project hygiene | Config/Data | In Review | N/A |
| 024 | Pets: companions, home and care | UI | In Review | N/A |
| 025 | Battle arena exploration, blocking and movement | UI/Feel | In Review | N/A |
