#
#    /$$$$$$            /$$             /$$     /$$   /$$                               /$$
#   /$$__  $$          |__/            | $$    | $$$ | $$                              |__/
#  | $$  \__/  /$$$$$$  /$$ /$$$$$$$  /$$$$$$  | $$$$| $$  /$$$$$$  /$$   /$$  /$$$$$$$ /$$  /$$$$$$$
#  |  $$$$$$  |____  $$| $$| $$__  $$|_  $$_/  | $$ $$ $$ /$$__  $$|  $$ /$$/ /$$_____/| $$ /$$_____/
#   \____  $$  /$$$$$$$| $$| $$  \ $$  | $$    | $$  $$$$| $$$$$$$$ \  $$$$/ | $$      | $$|  $$$$$$
#   /$$  \ $$ /$$__  $$| $$| $$  | $$  | $$ /$$| $$\  $$$| $$_____/  >$$  $$ | $$      | $$ \____  $$
#  |  $$$$$$/|  $$$$$$$| $$| $$  | $$  |  $$$$/| $$ \  $$|  $$$$$$$ /$$/\  $$|  $$$$$$$| $$ /$$$$$$$/
#   \______/  \_______/|__/|__/  |__/   \___/  |__/  \__/ \_______/|__/  \__/ \_______/|__/|_______/
#
#
#
#   /$$                           /$$
#  | $$                          | $$
#  | $$$$$$$   /$$$$$$   /$$$$$$$| $$$$$$$   /$$$$$$   /$$$$$$$
#  | $$__  $$ |____  $$ /$$_____/| $$__  $$ /$$__  $$ /$$_____/
#  | $$  \ $$  /$$$$$$$|  $$$$$$ | $$  \ $$| $$  \__/| $$
#  | $$  | $$ /$$__  $$ \____  $$| $$  | $$| $$      | $$
#  | $$$$$$$/|  $$$$$$$ /$$$$$$$/| $$  | $$| $$      |  $$$$$$$
#  |_______/  \_______/|_______/ |__/  |__/|__/       \_______/
#
#
#
#

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

# If not running interactively exit
[[ $- != *i* ]] && return

# === SAFE BASH COMPLETION LOADING (updated for FreeBSD/Linux/macOS compatibility) ===
# Enable bash completion safely — only source regular readable files, suppress errors
if [ -d /etc/bash_completion.d ]; then
    for file in /etc/bash_completion.d/*; do
        [[ -f "$file" && -r "$file" ]] && source "$file" 2>/dev/null
    done
fi

# Also load main completion script if available (common locations)
if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion 2>/dev/null
elif [[ -r /etc/bash_completion ]]; then
    source /etc/bash_completion 2>/dev/null
elif [[ -r /opt/homebrew/etc/bash_completion ]]; then  # macOS Homebrew
    source /opt/homebrew/etc/bash_completion 2>/dev/null
fi
# ===========================================================================

# Source additional user specific aliases, functions, etc.
source ~/BashRC/.bash_local_env

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
