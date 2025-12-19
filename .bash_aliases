# Quickly jump to parent directores
alias cd..='cd ../'                                               # Go back 1 directory level (for fast typers)
alias ..='cd ../'                                                 # Go back 1 directory level
alias ...='cd ../../'                                             # Go back 2 directory levels
alias .3='cd ../../../'                                           # Go back 3 directory levels
alias .4='cd ../../../../'                                        # Go back 4 directory levels
alias .5='cd ../../../../../'                                     # Go back 5 directory levels
alias .6='cd ../../../../../../'                                  # Go back 6 directory levels


# === ls base alias with color support ===
# Use --color=auto only if GNU ls is available (Pair.com FreeBSD, Linux)
if ls --color=auto >/dev/null 2>&1; then
    alias ls='ls --color=auto'
else
    # Fallback for BSD ls (macOS, pure FreeBSD) — use -G if available
    if ls -G >/dev/null 2>&1; then
        alias ls='ls -G'
    fi
fi

# Generic List aliases (builded upon the alias set in the OS specific .bash file)
alias la='ls -A'                    # Preferred 'la' implementation
alias ll='ls -FlAhp'                # Preferred 'll' implementation
alias l='ls -CF'                    # Columnar classified

# List the commands you use most often
alias freq='cut -f1 -d" " ~/.bash_history | sort | uniq -c | sort -nr | head -n 30'

# List top ten largest files or directories in current directory
alias lga='du -ah . | sort -rh | head -40'

# List top ten largest files in current directory
alias lgf='ls -1Rhs | sed -e "s/^ *//" | grep "^[0-9]" | sort -hr | head -n40'

# mkdir with flags: -p = make parents as needed, -v = verbose
alias mkdir='mkdir -p -v'

# Ping 5 times by default
alias ping='ping -c 5'

# Show disk space
alias df='df -h'

# Running processes
alias ps="ps auxf"

# Show bin paths
alias paths='echo -e ${PATH//:/\\n}'

# Search for a specific proces. Ex: psg conky
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"

# Userlist
alias userlist="cut -d: -f1 /etc/passwd"

# Show local weather
alias weather="curl http://wttr.in/"

# Get week number
alias week='date +%V'

# Alias more to less so we can use arrow keys for navigation
alias more='less'

# Shows the dimensions of the current terminal
# For more info on tput: http://linuxcommand.org/lc3_adv_tput.php
alias termsize='echo "Rows=$(tput lines) Cols=$(tput cols)"'

#   lr:  Full Recursive Directory Listing
#   ------------------------------------------
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'

#   mans:   Search manpage given in agument '1' for term given in argument '2' (case insensitive)
#           displays paginated result with colored search terms and two lines surrounding each hit.            Example: mans mplayer codec
#   --------------------------------------------------------------------
    mans () {
        man $1 | grep -iC2 --color=always $2 | less
    }

#   showa: to remind yourself of an alias (given some part of it)
#   ------------------------------------------------------------
    showa () { /usr/bin/grep --color=always -i -a1 $@ ~/Library/init/bash/aliases.bash | grep -v '^\s*$' | less -FSRXc ; }

