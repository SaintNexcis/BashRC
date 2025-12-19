# Local Environment Overrides

This directory is intentionally empty in the public repository.

It serves as a **placeholder** for private, machine-specific or project-specific Bash configuration overrides.

## Purpose

- Keep the main BashRC repository clean, universal, and safe to share publicly.
- Allow sensitive or environment-specific customizations (e.g., internal server sync wrappers, SSH key paths, project-specific functions, credentials hints) to be loaded **only** on designated machines.
- Prevent accidental exposure of confidential information.
- Support loading **multiple environments** on a single machine (e.g., for local development) via subdirectories.

## Required Setup: Use Subdirectories

All private overrides **must** be placed in subdirectories within `local_environment/`.

Example structure:
```

local_environment/
├── my_project/
│   ├── aliases.bash
│   ├── sync_wrappers.bash
│   └── local_env.bash
├── personal/
│   └── mac_extras.bash
└── client-xyz/
    └── wrappers.bash

```

### Why subdirectories only?

- Prevents file name conflicts when loading multiple environments.
- Makes it immediately clear which project/environment is being loaded.
- Scales cleanly for complex setups (multiple projects/clients on one machine).

## How it works

- The public repository tracks this empty directory (via `.gitkeep`).
- On specific machines, you create subdirectories and clone **separate private Git repositories** into them.
- Any files ending in `.bash` inside subdirectories will be **automatically sourced** during shell startup (thanks to the loader in `.bash_local_env`).
- The loader announces each subdirectory as it loads:
  ```

  Loading overrides from my_project...
  Loading overrides from personal...

  ```
- If the directory is empty or has no subdirectories with `.bash` files → silent operation.

## Setting up a new private environment

1. Create a new **private** Git repository (e.g., on GitHub, GitLab, Bitbucket — set visibility to **Private**):
   Suggested name: `bashrc-[project-name]`
   Examples:
     - bashrc-my_project
     - bashrc-client-xyz
     - bashrc-internal-tools

2. Add your sensitive files using clean, generic names (no project name in filename for extra obscurity):
   Recommended:
     - `sync_wrappers.bash`     → rsync/pushSync wrappers with internal servers
     - `functions.bash`         → project-specific functions
     - `local_env.bash`         → exports, variables, key paths
     - `aliases.bash`           → project-only aliases (optional)

3. Commit and push to your private repo.

4. On the target machine(s), install the overrides:
   ```bash
   cd ~/BashRC/local_environment
   mkdir [environment-name]   # e.g., my_project, personal, client-xyz
   cd [environment-name]
   git clone git@github.com:yourusername/bashrc-[project-name].git .
   ```

1. Reload your shell:

   ```bash
   source ~/.bash_profile
   ```

   You should see a message for each subdirectory containing `.bash` files.

## Security notes

- **Never** commit sensitive files to the public `BashRC` repository.
- Keep all confidential configuration in private repositories only.
- Use SSH keys or deploy keys for cloning private repos on servers.
- The loader is silent when no overrides are present.

## Future environments

Repeat the process for any new project or client — create a new private repo and clone it into a new subdirectory on the relevant machines.

Enjoy a clean public setup with powerful private extensions where needed!
