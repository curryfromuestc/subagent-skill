# Shared Assets Layout

This repository keeps **one source of truth** for skill scripts/docs at:

- `skills/spawn-coding-worker/`

To keep Claude plugin and repository-level scripts in sync, we use symlinks.

## Symlink Map

- `scripts/spawn-coding-worker.sh` -> `../skills/spawn-coding-worker/scripts/spawn-coding-worker.sh`
- `scripts/cc_env.sh` -> `../skills/spawn-coding-worker/scripts/cc_env.sh`
- `plugin/spawn-coding-worker/skills/spawn-coding-worker/SKILL.md` -> `../../../../skills/spawn-coding-worker/SKILL.md`
- `plugin/spawn-coding-worker/skills/spawn-coding-worker/scripts` -> `../../../../skills/spawn-coding-worker/scripts`
- `plugin/spawn-coding-worker/skills/spawn-coding-worker/references` -> `../../../../skills/spawn-coding-worker/references`
- `plugin/spawn-coding-worker/skills/spawn-coding-worker/agents` -> `../../../../skills/spawn-coding-worker/agents`

## Update Workflow

1. Edit shared files under `skills/spawn-coding-worker/`.
2. Refresh links:

```bash
./scripts/sync-shared-assets.sh
```

3. Run validation:

```bash
./scripts/validate-subagent-skill.sh
```

## Standalone Plugin Sync (Important)

`plugin/spawn-coding-worker` now contains symlinks to shared files.  
When copying plugin files to another directory, use `rsync` with `-L` (copy symlink targets):

```bash
rsync -aL --delete plugin/spawn-coding-worker/ /path/to/output/spawn-coding-worker/
```

Without `-L`, copied symlinks may become broken outside this repository.
