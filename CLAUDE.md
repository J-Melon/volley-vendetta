<!-- GODOTIQ RULES START -->
<!-- godotiq-rules-version: 0.4.0 -->
# GodotIQ — AI-Assisted Godot Development

Use GodotIQ MCP tools over raw file operations. Do NOT read `.tscn`/`.gd`/`.tres` files directly — GodotIQ parses them with cross-references and spatial data. Do NOT grep for signals/callers — use `dependency_graph`/`signal_map`. Do NOT guess positions/scales — use `placement`/`suggest_scale`.

---

## Core Principles

- **Build in .tscn, not code.** Static world (terrain, decorations, structures) goes in `.tscn` via `build_scene`/`node_ops`. Runtime code is for game logic only (movement, damage, scoring).
- **Prefer .tscn scenes** for game objects. Use `build_scene` to create them. Runtime `Node3D` creation is only for genuinely dynamic systems (bullet pools, particles).
- **UI in .tscn too.** Define Control nodes in `.tscn`, use scripts only for data binding and theme overrides.
- **No rebuild from scratch.** Fix individual nodes with `node_ops`, don't delete and recreate entire groups.
- **Test-driven completion.** "Done" means every feature works during gameplay, not just compiles.

## Screenshots & Verification

- **Describe what you see** in screenshots. Cross-verify with `spatial_audit`/`state_inspect`.
- **Evidence-based completion:** screenshot + `state_inspect`/`spatial_audit` confirming values. "Looks correct" is insufficient — describe specifics.
- **Escalation:** Only ask user for help after 3 genuinely different failed fix strategies on the same issue.
- **Screenshots are expensive** (thousands of tokens). Use `state_inspect` for data, `verify_motion` for movement. Screenshots only for visual verification, limit 2-3 per session.

## Creation Workflow — `build_scene`

Use `build_scene` instead of individual `node_ops` calls for multiple nodes. Modes: `grid` (tile maps), `scatter` (handpicked), `line` (paths), `nodes` (mixed types). Max 256 nodes per call.

1. **Setup:** `nodes` mode for containers, camera, lights → `save_scene` → verify
2. **Terrain:** `grid` mode with `overrides` for special tiles → `save_scene` → verify
3. **Decorations:** `scatter` mode → `save_scene` → verify
4. **Key objects:** `placement` to find positions, then `scatter`
5. **Scripts:** `script_ops` for game logic only
6. **Verify:** `spatial_audit` + `signal_map` + `save_scene` + `explore`

### Tile Grid Rules
- Use `asset_registry` for tile dimensions — don't guess spacing
- Override keys are `"row,col"` (row=Z, col=X, matrix notation)
- Test rotations with ONE tile first, then derive others
- Never scale tiles beyond 1.02 to hide gaps — fix spacing/rotation instead

## Mandatory Final QA

Before declaring "done", run ALL checks:
0. **Visual sweep** — `explore(mode="tour")`, analyze screenshots, fix issues
1. **Spatial coherence** — `spatial_audit(detail="brief")`, 0 critical/warnings
2. **Grid connectivity** — check `warnings` in build_scene response
3. **Code quality** — `validate` every modified `.gd` file
4. **Signal wiring** — `signal_map(find="orphans")`, 0 orphans
5. **Gameplay test** — `check_errors` → `run` → `state_inspect` → `ui_map` → `input` (test every interactive element) → `state_inspect` (verify changes) → wait for cycle → check `recent_errors` → `stop`
6. **Report** — summarize what was built and QA results

## Testing Input

Use `godotiq_input` to simulate real player interactions, not `exec` to set properties directly.
- UI buttons: `{"tap": "ButtonName"}`
- Viewport: `{"click_at": [640, 360]}` (supports `"button": "right"/"middle"`)
- World: `{"click_at_world": [5.0, 0.0, 3.0]}`

## Token Efficiency

- **Always `detail="brief"`** unless you need more. `asset_registry(detail="full")` can produce 140K chars.
- **Always filter:** `focus`+`radius` on scene_map, `path_filter` on asset_registry, `scope="file:..."` on signal_map.
- **Don't repeat tool calls** — cache results from earlier in the session.
- **Check `_editor_state`** in every bridge response for `open_scene`, `game_running`, `recent_errors`.
- **Batch then verify once.** Group changes in one `node_ops`/`exec` call, one `save_scene`, one verification.
- **Act immediately.** Max 2 paragraphs between tool calls.

## Community vs Pro Tier

Discovered when you first call a Pro tool. If Community: share the preview, name what's locked once, fall back to free tools silently. Never stop working because Pro is locked. Key fallbacks: `scene_tree` for `scene_map`, `script_ops(op="read")` for `file_context`, `check_errors` for `validate`, `screenshot` for `explore`.

## Mandatory Workflows

1. **Session start:** `project_summary(detail="brief")`
2. **Before editing any file:** `file_context(detail="brief")` + `impact_check`
3. **3D scene work:** `scene_map` → `placement` → `build_scene`/`node_ops(validate=true)` → `save_scene` → verify with `explore`/`spatial_audit`
4. **After code changes:** `validate(detail="brief")`
5. **Multi-file refactor:** `impact_check` → baseline `validate` → changes → `validate` again → `check_errors` → `signal_map(find="orphans")`
6. **Testing:** `run` → `state_inspect` (preferred) / `verify_motion` / `screenshot` (expensive) → `stop`

## Known Godot Quirks

- `play_main_scene()` unreliable — use `godotiq_run(action="play")`
- Script cache staleness — `script_ops` auto-reloads; for `exec`, call `EditorInterface.get_resource_filesystem().scan()`
- New `class_name` scripts — use `load("res://path.gd").new()` not `ClassName.new()` during current session
- Timeouts — don't retry `run` immediately; call `stop` first, then retry
- Movement verification — use `verify_motion` or double `state_inspect` with `wait_ms`, not screenshots

## Quick Reference

- **Node paths** in `node_ops`: relative to scene root (`"Sun"` not `"Main/Sun"`)
- **Spatial validation:** `validate: true` on move/scale/add_child. Atomic — if ANY blocked, NONE execute.
- **GDScript:** `snake_case.gd`, `PascalCase` classes, explicit type hints, `@onready` for node refs, `is_instance_valid()` for null checks
- **Error recovery:** `GAME_NOT_RUNNING` → `run(play)` | `NODE_NOT_FOUND` → `scene_tree(brief)` | `ADDON_NOT_CONNECTED` → enable addon | `TIMEOUT` → `stop` then retry | `SCRIPT_ERRORS` → `check_errors` then fix | `BLOCKED` → check `validation` array

## Background Agent Supervision

After background task completion: read every modified file, `check_errors(scope="project")`, `validate` new scripts, launch and verify with `screenshot` + `state_inspect`. Prefer sequential execution for overlapping files.

<!-- GODOTIQ RULES END -->
