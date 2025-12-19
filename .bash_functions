# -----------------------------------------------------------------------------

# Remove .DS_Store files. Useful if you share drives with Mac.
function rmdsstore() {
    find . -name ".DS_Store" -print0 | xargs -0 rm -rf
    find . -name "._*" -print0 | xargs -0 rm -rf
}

# -----------------------------------------------------------------------------

# Add SSH private keys into the SSH authentication agent
function addPKeys() {
    eval $(ssh-agent -s)
    ssh-add $HOME/.ssh/*.ppk
}


# -----------------------------------------------------------------------------

# Auto-extract based on type
function extract() {
  if [ -f $1 ] ; then
    if [ $2 ] ; then
        case $1 in
            *.tar.bz2)    mkdir $2 && tar xvjf $1 -C $2 --strip-components 1     ;;
            *.tar.gz)     mkdir $2 && tar xvzf $1 -C $2 --strip-components 1     ;;
            *.tar.xz)     mkdir $2 && tar xvfJ $1 -C $2 --strip-components 1     ;;
            *.bz2)        mkdir $2 && bunzip2 $1      ;;
            *.rar)        mkdir $2 && rar x $1        ;;
            *.gz)         mkdir $2 && gunzip $1       ;;
            *.tar)        mkdir $2 && tar xvf $1 -C $2 --strip-components 1      ;;
            *.tbz2)       mkdir $2 && tar xvjf $1 -C $2 --strip-components 1     ;;
            *.tgz)        mkdir $2 && tar xvzf $1 -C $2 --strip-components 1     ;;
            *.zip)        mkdir $2 && unzip $1        ;;
            *.Z)          mkdir $2 && uncompress $1   ;;
            *.7z)         mkdir $2 && 7z x $1         ;;
            *)            echo "Unrecognized archive $1" ;;
        esac
    else
        case $1 in
            *.tar.bz2)    tar xvjf $1     ;;
            *.tar.gz)     tar xvzf $1     ;;
            *.tar.xz)     tar xvfJ $1     ;;
            *.bz2)        bunzip2 $1      ;;
            *.rar)        rar x $1        ;;
            *.gz)         gunzip $1       ;;
            *.tar)        tar xvf $1      ;;
            *.tbz2)       tar xvjf $1     ;;
            *.tgz)        tar xvzf $1     ;;
            *.zip)        unzip $1        ;;
            *.Z)          uncompress $1   ;;
            *.7z)         7z x $1         ;;
            *)            echo "Unrecognized archive $1" ;;
        esac
    fi
  else
      echo "$1 is not an extractable file"
  fi
}

# -----------------------------------------------------------------------------

# Creates an archive (*.tar.gz) from given directory.
function maketar() {
    tar cvzf "${1%%/}.tar.gz" "${1%%/}/";
}

# -----------------------------------------------------------------------------

# Create a ZIP archive of a file or folder.
function makezip() {
    zip -r "${1%%/}.zip" "$1";
}

# Adds, commits, and pushes to git with one command.
#   --------------------------------------------------------
function gitgo() {
    # Are we in a directory under source control?
    if [[ ! -d .git ]]; then
        echo "Not a git repository."
    else
        echo "You are in ${PWD}"
        # Are there any changes that need to be committed?
        if git diff-index --quiet HEAD --; then
            echo "Repository is up to date."
        else
            # Prompt user for commit message
            echo "Enter commit message:"
            read _msg

            # Was a commit message passed?
            if [[ ! "$_msg" ]]; then
                echo "You must include a commit message."
            else
                git add .
                git commit -m "$_msg"
                git push
            fi
        fi
    fi
}

# -----------------------------------------------------------------------------

# Function to check if PHP is installed and return the version number
# in the format: PHP7.4
parse_php_version() {
    # Check if PHP is installed using the "command -v" command
    if [[ -n "$(command -v php)" ]]; then
        # Get the version number by running "php -v" and extracting the version
        # using "awk" and "cut" commands
        local php_version=$(php -v | head -n 1 | awk '{print $2}' | cut -d "-" -f 1)

        # Output the PHP version in the desired format: [PHP7.4
        echo "PHP v$php_version"
    else
        # If PHP is not installed, output an empty string
        echo ""
    fi
}

# Add git branch if its present to PS1| dr
parse_git_branch() {
  if command -v git >/dev/null 2>&1; then
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
  else
    echo ""
  fi
}
 # Add git reop name if it's present to PS1
parse_git_repo() {
  if command -v git >/dev/null 2>&1; then
    git config --get remote.origin.url | sed -e 's/^git@.*:\([[:graph:]]*\).git/\1/'
  else
    echo ""
  fi
}

# -----------------------------------------------------------------------------
#  RSync Functions
#  GENERIC Server Sync
# -----------------------------------------------------------------------------

# Defines a function named "pushSync" that takes three arguments ($1, $2, and $3).
# This function synchronizes files from the local system to a remote system using rsync over SSH.
# Supports file patterns (e.g., config/sync/core.entity_view_display.*) in the local path.
# The arguments are used as follows:
# - $1: the remote server address
# - $2: the local file/directory path (source, supports wildcards)
# - $3: the remote file/directory path (destination)
function pushSync() {
    # Default SSH key file (use environment variable if set, else fallback to standard id_rsa.ppk)
    DEFAULT_SSH_KEY="${DEFAULT_SSH_KEY:-${HOME}/.ssh/id_rsa.ppk}"

    # Initialize variables
    local identity_file=""
    local server_alias=""
    local local_path=""
    local remote_path=""
    local verbose=0

    # Check if the first argument is a known server alias
    if grep -q "Host $1" ~/.ssh/config 2>/dev/null; then
        server_alias="$1"
        shift
    fi

    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--identity_file)
                identity_file="$2"
                shift 2
                identity_file="${identity_file/#\~/$HOME}" # Expand ~ in user-provided key file
                [[ $verbose -eq 1 ]] && printf "\e[34mDEBUG: identity_file='%s'\e[0m\n" "$identity_file"
                if [[ ! -f "$identity_file" ]]; then
                    printf "\e[31mERROR: The specified key file '%s' does not exist.\e[0m\n" "$identity_file"
                    return 1
                fi
                ;;
            -h|--help)
                cat << EOF
Usage: pushSync [-i identity_file] [-v] <remote_server> <local_path> <remote_path>
Options:
  -h, --help                      Display this help message
  -i identity_file                Specify the SSH identity file
  -v, --verbose                   Enable verbose debugging output

Remote Server Format:
  user@example.com                Standard SSH format
  remote_server_alias             SSH config file alias

SSH Key File:
  If a server alias is provided and no identity file is specified, the function checks the SSH config file for the key.
  If no key file is found or a standard SSH format is provided, it uses the default key file from \$DEFAULT_SSH_KEY or falls back to a standard location (e.g., ~/.ssh/id_rsa).
  The -i option takes precedence over the SSH config file and the default key file.

Examples:
  pushSync user@example.com config/sync /remote/path
  pushSync server_alias config/sync/core.entity_view_display.* /remote/path
  pushSync -i ~/.ssh/id_rsa.ppk server_alias config/sync /remote_path
  pushSync -v server_alias config/sync /remote_path
EOF
                return 0
                ;;
            -v|--verbose)
                verbose=1
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    # Extract server alias, local path, and remote path
    if [[ -z $server_alias ]]; then
        server_alias="$1"
        shift
    fi
    local_path="$1"
    remote_path="${2%/}" # Trim trailing slash

    # Validate inputs
    if [[ -z $server_alias || -z $local_path || -z $remote_path ]]; then
        printf "\e[31mERROR: Missing required arguments.\e[0m\n"
        printf "Usage: pushSync [-i identity_file] [-v] <remote_server> <local_path> <remote_path>\n"
        return 1
    fi

    # Debug: Print DEFAULT_SSH_KEY if verbose
    [[ $verbose -eq 1 ]] && printf "\e[34mDEBUG: DEFAULT_SSH_KEY='%s'\e[0m\n" "$DEFAULT_SSH_KEY"

    # Determine SSH key file
    local key_file=""
    if grep -qF "Host $server_alias" ~/.ssh/config 2>/dev/null; then
        # Extract IdentityFile from ~/.ssh/config
        key_file=$(awk -v host="$server_alias" '
            BEGIN { in_host=0 }
            /^Host / { if ($2 == host) in_host=1; else in_host=0 }
            in_host && /IdentityFile/ { print $2 }
        ' ~/.ssh/config)
        [[ $verbose -eq 1 ]] && printf "\e[34mDEBUG: key_file from SSH config='%s'\e[0m\n" "$key_file"
        key_file="${key_file/#\~/$HOME}" # Expand ~ in SSH config key file
        [[ $verbose -eq 1 ]] && printf "\e[34mDEBUG: key_file after ~ expansion='%s'\e[0m\n" "$key_file"

        if [[ -z $key_file && -z $identity_file ]]; then
            printf "\e[33mWARNING: No SSH identity file found for server alias '%s' in ~/.ssh/config.\e[0m\n" "$server_alias"
            while true; do
                printf "Please choose one of the following options:\n"
                printf "  1. Use the default key file (%s)\n" "$DEFAULT_SSH_KEY"
                printf "  2. Specify a different key file now\n"
                printf "  3. Exit\n"
                read -p "Enter your choice (1/2/3): " choice
                case $choice in
                    1)
                        key_file="$DEFAULT_SSH_KEY"
                        break
                        ;;
                    2)
                        read -p "Enter the path to the key file: " key_file
                        key_file="${key_file/#\~/$HOME}" # Expand ~ to $HOME
                        [[ $verbose -eq 1 ]] && printf "\e[34mDEBUG: key_file from user input='%s'\e[0m\n" "$key_file"
                        if [[ ! -f "$key_file" ]]; then
                            printf "\e[31mERROR: The specified key file '%s' does not exist.\e[0m\n" "$key_file"
                        else
                            break
                        fi
                        ;;
                    3)
                        printf "\e[31mExiting. Please specify the key file with -i option.\e[0m\n"
                        return 1
                        ;;
                    *)
                        printf "\e[31mERROR: Invalid choice. Please enter 1, 2, or 3.\e[0m\n"
                        ;;
                esac
            done
        else
            key_file="${identity_file:-$key_file}"
        fi
    else
        key_file="${identity_file:-$DEFAULT_SSH_KEY}"
    fi

    # Debug: Print final key_file if verbose
    [[ $verbose -eq 1 ]] && printf "\e[34mDEBUG: Final key_file='%s'\e[0m\n" "$key_file"

    # Validate key file
    if [[ ! -f "$key_file" ]]; then
        printf "\e[31mERROR: SSH key file '%s' does not exist.\e[0m\n" "$key_file"
        return 1
    fi

    # Portable SSH agent handling
    if ! pgrep ssh-agent > /dev/null 2>&1; then
        eval "$(ssh-agent -s)"
    fi
    fingerprint=$(ssh-keygen -lf "$key_file" | cut -d ' ' -f 2)
    if ! ssh-add -l | grep -q "$fingerprint"; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            ssh-add --apple-use-keychain "$key_file"
        else
            ssh-add "$key_file"
        fi
    fi

    # Ensure remote directory exists
    ssh -i "$key_file" "$server_alias" "mkdir -p \"$remote_path\"" || {
        printf "\e[31mERROR: Failed to create remote directory '%s'.\e[0m\n" "$remote_path"
        return 1
    }

    # Conditionally quote remote path if it contains spaces
    local remote_path_quoted="$remote_path"
    if [[ $remote_path = *' '* ]]; then
        remote_path_quoted="\"$remote_path\""
    fi

    # Construct remote destination
    local remote_dest="$server_alias:$remote_path_quoted"

    # Debug: Print rsync command if verbose
    [[ $verbose -eq 1 ]] && printf "\e[34mDEBUG: Running rsync -arvz -e \"ssh -i '%s'\" '%s' '%s'\e[0m\n" "$key_file" "$local_path" "$remote_dest"

    # Construct and run the rsync command
    rsync -arvz -e "ssh -i \"$key_file\"" "$local_path" "$remote_dest"
}

# Defines a function named "pullSync" that synchronizes files from a remote system to the local system using rsync over SSH.
# Supports file patterns (e.g., config/sync/core.entity_view_display.*) in the remote path.
# Arguments:
#   - $1: remote server address or alias
#   - $2: remote file/directory path (source, supports wildcards)
#   - $3: local file/directory path (destination)
# Options:
#   -i: specify SSH identity file
#   -h: display help
#   -v: enable verbose debugging output
function pullSync() {
    # Default SSH key file (use environment variable if set, else fallback to standard.ppk)
    DEFAULT_SSH_KEY="${DEFAULT_SSH_KEY:-${HOME}/.ssh/id_rsa.ppk}"

    # Initialize variables
    local identity_file=""
    local server_alias=""
    local remote_path=""
    local local_path=""
    local verbose=0

    # Check if the first argument is a known server alias
    if grep -q "Host $1" ~/.ssh/config 2>/dev/null; then
        server_alias="$1"
        shift
    fi

    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--identity_file)
                identity_file="$2"
                shift 2
                identity_file="${identity_file/#\~/$HOME}" # Expand ~ in user-provided key file
                [[ $verbose -eq 1 ]] && printf "\e[34mDEBUG: identity_file='%s'\e[0m\n" "$identity_file"
                if [[ ! -f "$identity_file" ]]; then
                    printf "\e[31mERROR: The specified key file '%s' does not exist.\e[0m\n" "$identity_file"
                    return 1
                fi
                ;;
            -h|--help)
                cat << EOF
Usage: pullSync [-i identity_file] [-v] <remote_server> <remote_path> <local_path>
Options:
  -h, --help                      Display this help message
  -i identity_file                Specify the SSH identity file
  -v, --verbose                   Enable verbose debugging output

Remote Server Format:
  user@example.com                Standard SSH format
  remote_server_alias             SSH config file alias

SSH Key File:
  If a server alias is provided and no identity file is specified, the function checks the SSH config file for the key.
  If no key file is found or a standard SSH format is provided, it uses the default key file from \$DEFAULT_SSH_KEY or falls back to a standard location (e.g., ~/.ssh/id_rsa.ppk).
  The -i option takes precedence over the SSH config file and the default key file.

Examples:
  pullSync user@example.com /remote/path /local/path
  pullSync server_alias config/sync/core.entity_view_display.* config/sync
  pullSync -i ~/.ssh/id_rsa.ppk server_alias /remote/path /local_path
  pullSync -v server_alias config/sync /remote_path
EOF
                return 0
                ;;
            -v|--verbose)
                verbose=1
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    # Extract server alias, remote path, and local path
    if [[ -z $server_alias ]]; then
        server_alias="$1"
        shift
    fi
    remote_path="$1"
    local_path="${2%/}" # Trim trailing slash

    # Validate inputs
    if [[ -z $server_alias || -z $remote_path || -z $local_path ]]; then
        printf "\e[31mERROR: Missing required arguments.\e[0m\n"
        printf "Usage: pullSync [-i identity_file] [-v] <remote_server> <remote_path> <local_path>\n"
        return 1
    fi

    # Debug: Print DEFAULT_SSH_KEY if verbose
    [[ $verbose -eq 1 ]] && printf "\e[34mDEBUG: DEFAULT_SSH_KEY='%s'\e[0m\n" "$DEFAULT_SSH_KEY"

    # Determine SSH key file
    local key_file=""
    if grep -qF "Host $server_alias" ~/.ssh/config 2>/dev/null; then
        # Extract IdentityFile from ~/.ssh/config
        key_file=$(awk -v host="$server_alias" '
            BEGIN { in_host=0 }
            /^Host / { if ($2 == host) in_host=1; else in_host=0 }
            in_host && /IdentityFile/ { print $2 }
        ' ~/.ssh/config)
        [[ $verbose -eq 1 ]] && printf "\e[34mDEBUG: key_file from SSH config='%s'\e[0m\n" "$key_file"
        key_file="${key_file/#\~/$HOME}" # Expand ~ in SSH config key file
        [[ $verbose -eq 1 ]] && printf "\e[34mDEBUG: key_file after ~ expansion='%s'\e[0m\n" "$key_file"

        if [[ -z $key_file && -z $identity_file ]]; then
            printf "\e[33mWARNING: No SSH identity file found for server alias '%s' in ~/.ssh/config.\e[0m\n" "$server_alias"
            while true; do
                printf "Please choose one of the following options:\n"
                printf "  1. Use the default key file (%s)\n" "$DEFAULT_SSH_KEY"
                printf "  2. Specify a different key file now\n"
                printf "  3. Exit\n"
                read -p "Enter your choice (1/2/3): " choice
                case $choice in
                    1)
                        key_file="$DEFAULT_SSH_KEY"
                        break
                        ;;
                    2)
                        read -p "Enter the path to the key file: " key_file
                        key_file="${key_file/#\~/$HOME}" # Expand ~ to $HOME
                        [[ $verbose -eq 1 ]] && printf "\e[34mDEBUG: key_file from user input='%s'\e[0m\n" "$key_file"
                        if [[ ! -f "$key_file" ]]; then
                            printf "\e[31mERROR: The specified key file '%s' does not exist.\e[0m\n" "$key_file"
                        else
                            break
                        fi
                        ;;
                    3)
                        printf "\e[31mExiting. Please specify the key file with -i option.\e[0m\n"
                        return 1
                        ;;
                    *)
                        printf "\e[31mERROR: Invalid choice. Please enter 1, 2, or 3.\e[0m\n"
                        ;;
                esac
            done
        else
            key_file="${identity_file:-$key_file}"
        fi
    else
        key_file="${identity_file:-$DEFAULT_SSH_KEY}"
    fi

    # Debug: Print final key_file if verbose
    [[ $verbose -eq 1 ]] && printf "\e[34mDEBUG: Final key_file='%s'\e[0m\n" "$key_file"

    # Validate key file
    if [[ ! -f "$key_file" ]]; then
        printf "\e[31mERROR: SSH key file '%s' does not exist.\e[0m\n" "$key_file"
        return 1
    fi

    # Portable SSH agent handling
    if ! pgrep ssh-agent > /dev/null 2>&1; then
        eval "$(ssh-agent -s)"
    fi
    fingerprint=$(ssh-keygen -lf "$key_file" | cut -d ' ' -f 2)
    if ! ssh-add -l | grep -q "$fingerprint"; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            ssh-add --apple-use-keychain "$key_file"
        else
            ssh-add "$key_file"
        fi
    fi

    # Ensure local directory exists
    mkdir -p "$local_path" || {
        printf "\e[31mERROR: Failed to create local directory '%s'.\e[0m\n" "$local_path"
        return 1
    }

    # Conditionally quote remote path if it contains spaces
    local remote_path_quoted="$remote_path"
    if [[ $remote_path = *' '* ]]; then
        remote_path_quoted="\"$remote_path\""
    fi

    # Construct remote source
    local remote_source="$server_alias:$remote_path_quoted"

    # Debug: Print rsync command if verbose
    [[ $verbose -eq 1 ]] && printf "\e[34mDEBUG: Running rsync -arvz -e \"ssh -i '%s'\" '%s' '%s'\e[0m\n" "$key_file" "$remote_source" "$local_path"

    # Construct and run the rsync command
    rsync -arvz -e "ssh -i \"$key_file\"" "$remote_source" "$local_path"
}

