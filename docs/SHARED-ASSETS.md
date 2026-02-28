# Shared Assets Layout

This repository keeps **one source of truth** for skill scripts/docs at:

- `skills/spawn-coding-worker/`

To keep repository-level scripts in sync, we use symlinks.

## Symlink Map

- `scripts/spawn-coding-worker.sh` -> `../skills/spawn-coding-worker/scripts/spawn-coding-worker.sh`
- `scripts/cc_env.sh` -> `../skills/spawn-coding-worker/scripts/cc_env.sh`

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
