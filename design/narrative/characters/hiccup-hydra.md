---
status: draft
canon: Provisional
date: 2026-11-14
---

# The Hiccup Hydra

## Role and canon
- **Role:** the second boss of the Alley Brawl. A fused gloom creature with three kid heads on one body. Chosen by the boss rotation (`BOSS_KINDS` in `src/scripts/brawl_enemies.gd`, alternating with the Grumble King per session run). (Established, code)
- **Story role:** the Hydra is three Gloomlings that got tangled together while chasing a hiccup of stolen light. Each head keeps the mood of the Gloomling it was. (Provisional, author confirmed the proposal 2026-11-14)
- **Pronouns:** not given. Each head is a kid, so refer to them by head: the angry one, the sleepy one, the giggly one. (Provisional)
- **Relationship to the King:** the Hydra is not his servant. It is a creature that drifts toward the cold, like the Gloomlings. (Provisional)

## Backstory and motivation
- Three Gloomlings that drifted together under a dim lantern and never found their way apart. (Provisional)
- Its hiccups are sparks of stolen light coming back out. Each sneeze is a small leak of the glow it carries. (Provisional, matches the sneeze code)
- Motivation: each head wants something different. The angry head wants to be noticed. The sleepy head wants the lights to stay low. The giggly head wants to dance. (Provisional)

## Personality and speech
- No spoken lines in the fight. The heads show mood through expression and sound, like the Gloomlings hum. (Provisional)
- The angry head (orange hair, orange shirt) scowls and sneezes first. The sleepy head (lavender hair, violet shirt, nightcap) wakes up when the Hydra is low on health. The giggly head (pink hair, pigtails, pink shirt) bounces with each hiccup. (Established, `gloom_hydra.gd`)
- Sample lines for a future cutscene, under 120 characters each:
  - "HIC! Who turned the lights down? Not me. Maybe him." (angry head, provisional)
  - "Mmm, five more minutes... the lantern is warm, go away." (sleepy head, provisional)
  - "Hehe! Do the hiccup dance with me! Hic-hic-hic!" (giggly head, provisional)
- Lines it would never say: any line that is cruel to the patrol, or any line that mocks a Lanternboy. It is a silly creature, never a scary one.

## Visual design
- **Build:** one fluffy teal body with three humanoid kid heads and torsos fused at the shoulders. Each head has its own hair, shirt and eye colour. (Established, `gloom_hydra.gd`)
- **Body colour:** teal `#2FC6A8`, with a fluff highlight `#7FF0D4`. Skin `#FFC7D6`. (Established, code)
- **Heads:**
  - Left (angry): orange shirt `#E8742F`, hair `#FF6A3C`, eyes `#FFB347`, spiky hair. (Established)
  - Centre (sleepy): violet shirt `#7C6AE8`, hair `#C9B8FF`, eyes `#C9A8FF`, nightcap. (Established)
  - Right (giggly): pink shirt `#E85BA0`, hair `#FF5FA2`, eyes `#FF9EC8`, pigtails. (Established)
- **Expression:** every ~2.5 s one head sneezes sparkles (visual only) and the body hiccups. (Established, code)
- **Health 34% or less:** the sleepy head wakes up. (Established, code)
- **Look rule:** kid-friendly, round and bouncy. Never gory or sharp. Dark purple is the neon backdrop, not the creature. (Provisional, art bible pillar 4)

## Gameplay role
- Second Alley Brawl boss. Its pattern is a lane sneeze: a blob flies along a telegraphed lane, and the player changes lane to dodge. (Established, `brawl_boss.gd`)
- Only hit by the player's punches and the Lanternboys' moves. (Provisional, matches the King's rules; confirm in code)
- Readability: the lane sneeze must be visible at phone size. (Provisional, needs a playtest)

## Open questions
1. What is the Hydra's story reason to exist? The proposal above is one option. (Under Review)
2. Should the three heads keep their names, or stay unnamed kids? (Under Review)
3. Is the Hydra allowed a gentle ending, the way the player learns to be gentle with the King? (Under Review)
4. Does the Hydra appear only in the brawl, or also in a story chapter? (Under Review)
