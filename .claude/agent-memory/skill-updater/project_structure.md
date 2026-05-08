---
name: PantryPal project structure
description: 三个子项目的路径、Skill 文件位置及 CHANGELOG 路径
type: project
---

PantryPal 项目根目录：`E:\workspace\PantryPal\code\`

**Skill 文件路径**
- 设计 Skill: `pen_pantry_pal/.claude/skills/pantrypal-design/SKILL.md`
- 前端 Skill: `flutter_pantry_pal/.claude/skills/pantrypal-development/SKILL.md`
- 后端 Skill: `fastapi_pantry_pal/.claude/skills/pantrypal-backend/SKILL.md`

**CHANGELOG**: `CHANGELOG.md`（项目根目录，最新记录在文件最前面）

**Why:** 项目分三个子目录，每个子目录有独立的 `.claude/skills/` 目录，便于各领域 Agent 独立维护。

**How to apply:** 更新 Skill 前先读取对应文件，CHANGELOG 永远在文件开头插入新记录。
