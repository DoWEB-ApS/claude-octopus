# ⚠️ PLUGIN NAME LOCK

## CRITICAL: DO NOT CHANGE THE PLUGIN NAME

The plugin name in `plugin.json` **MUST remain "doweb"**.

### Why?

```json
// ✅ CORRECT - plugin.json
{
  "name": "doweb"  // This produces /doweb:setup-enterprise, /doweb:run-project, etc.
}
```

```json
// ❌ WRONG - DO NOT DO THIS
{
  "name": "claude-octopus"  // This produces /claude-octopus:discover (too long!)
}
```

### Package vs Plugin Name

These are **different** and serve **different purposes**:

| File | Name | Purpose |
|------|------|---------|
| `package.json` | `"claude-octopus"` | Marketplace/repository identity |
| `.claude-plugin/plugin.json` | `"doweb"` | Command prefix (`/doweb:*`) |

### Command Path Formation

Command paths are formed as: `/[plugin-name]:[command-name]`

- Plugin name: `"doweb"` + Command: `run-project` = `/doweb:run-project` ✅
- Plugin name: `"claude-octopus"` + Command: `run-project` = `/claude-octopus:run-project` ❌

### Historical Context

**Fork policy:**
- This enterprise fork intentionally standardizes on `doweb` namespace.
- Do not rename plugin without coordinated migration of command docs and tests.

**Why it broke:**
Someone changed the plugin name thinking it should match the package name. It shouldn't.

### Tests

Run `make test-plugin-name` to verify the plugin name is correct.

### If You Need to Change It

**Don't.** But if you absolutely must:
1. Update all documentation showing `/doweb:*` commands
2. Update README.md examples
3. Update all skill files with command references
4. Notify all users about the breaking change
5. Consider providing migration script
6. Update this documentation

**Estimated impact:** 100+ command references across docs, skills, and user workflows.

---

**Last verified:** 2026-01-21
**Status:** ✅ Plugin name is "doweb" and LOCKED
