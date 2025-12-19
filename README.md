# BashRC — Universal Bash Configuration

This repository contains my personal, cross-platform Bash configuration files and custom scripts to set up a preferred shell environment on various servers and systems. It is designed to be **universal and non-sensitive**, safe to share publicly.

## Contents

* `.bashrc`: Customized Bash shell configuration file, including various aliases, functions, and environment settings.
* `.bash_profile`: Bash profile that sources the `.bashrc` file and includes additional settings.
* `.bash_aliases`: Contains general-purpose aliases for frequently used commands and scripts.
* `.bash_env_aliases`: Contains environment-specific aliases for frequently used commands and scripts.
* `.bash_exports`: Stores exported variables and environment settings.
* `.bash_functions`: Includes custom functions for performing various tasks and operations in the shell.
* `.bash_linux` and `.bash_mac`: Platform-specific settings and configurations for Linux and macOS, respectively.
* `.bash_local_env`: Stores local environment-specific settings and configurations for the Bash shell.
* `.bash_logout`: Contains commands or functions to be executed upon logging out of the shell.
* `.bash_options`: Includes custom shell options and settings to modify Bash's behavior.
* `.bash_sync_wrappers`: Contains custom wrapper functions and scripts for synchronizing files and data.
* `.gitmessage`: Template or guidelines for Git commit messages.
* `LICENSE`: The license file specifying the terms under which the project's code is distributed.
* `local_environment/`: Placeholder for private, environment-specific overrides (see below for details).

## Features

- Beautiful custom prompt with git branch/repo, PHP version, hostname
- Smart cross-platform `ls` colors (GNU or BSD)
- Safe bash completion loading
- Rich aliases and functions (Drupal/Composer tools, rsync base wrappers, git helpers, etc.)
- NVM integration
- History settings, options, exports
- Modular design with **private overrides** support via subdirectories

## Private Overrides (for sensitive or environment-specific config)

This repository contains **only universal, non-sensitive configurations**.

For sensitive or project-specific customizations (e.g., internal server wrappers, SSH keys, project aliases, credentials hints), use **private overrides** loaded via the `local_environment/` directory.

All private overrides **must** be placed in subdirectories (e.g., `my_project/`, `personal/`, `client-xyz/`) to avoid conflicts and improve clarity.

See [`local_environment/README.md`](local_environment/README.md) for full instructions on setting up private environments, including how to create and load multiple environments on a single machine.

## Getting Started (Universal Setup)

1. Clone this repository:

   ```bash
   git clone https://github.com/SaintNexcis/BashRC.git ~/BashRC
   ```

1. **Back up your original configuration files**:

   ```bash
   cp ~/.bashrc ~/.bashrc.backup
   cp ~/.bash_profile ~/.bash_profile.backup
   ```

2. Create symbolic links:

   ```bash
   ln -sf ~/BashRC/.bashrc ~/.bashrc
   ln -sf ~/BashRC/.bash_profile ~/.bash_profile
   ```

3. **Add customizations via private overrides** (recommended):
   - Do **not** edit files in this repository directly.
   - Instead, create private Git repositories for your sensitive/project-specific config and clone them into subdirectories of `~/BashRC/local_environment/` (see `local_environment/README.md`).

4. Reload your shell:

   ```bash
   source ~/.bash_profile
   ```

Your shell will now use the universal configuration. Private overrides (if present) will load automatically with clear announcements.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

```

This version keeps **all the important sections** from your original README (especially the detailed **Contents** list) while fully incorporating the new private overrides design, subdir requirement, and modern guidance.

Commit and push this — your public repo is now perfectly documented, accurate, and professional.

You're officially complete. Enjoy your new, secure, modular BashRC system! 🔥🚀
