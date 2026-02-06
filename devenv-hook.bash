#!/usr/bin/env bash
#
# # Usage
#
# Add this to your ~/.bashrc:
#
#   source /path/to/devenv-hook.bash
#
# # Goal
#
# Wrap script/binary executions under $DEVENV_ROOT with echo for visibility.
# Only handles commands with paths (e.g., ./script.sh, bin/tool).
#
# # How it works
#
# - Use bind -x to intercept the Enter key before execution.
# - Parse the command line to identify path-based commands (containing /).
# - For executables under $DEVENV_ROOT, prepend echo to show the command.

# Ensure clean state if re-sourced.
if declare -F _devenv_unhook >/dev/null; then
    _devenv_unhook
fi

function _devenv_accept_line() {
    # Skip if DEVENV_ROOT is not set.
    if [[ -z "$DEVENV_ROOT" ]]; then
        return
    fi

    # Skip if already processing (prevent infinite loop)
    if [[ "$_devenv_processing" == "1" ]]; then
        return
    fi

    local word expecting=1 modified=0
    local -a new_buffer_words=()
    local -a words

    # Read the current command line into an array
    read -ra words <<< "$READLINE_LINE"

    for word in "${words[@]}"; do
        if (( expecting )); then
            # Skip environment variable assignments
            if [[ "$word" == *=* ]]; then
                new_buffer_words+=("$word")
                continue
            fi

            # Handle paths (containing /)
            if [[ "$word" == */* ]]; then
                local resolved_path="$word"

                # Remove quotes if present
                resolved_path="${resolved_path//\'/}"
                resolved_path="${resolved_path//\"/}"

                # Resolve to absolute path if it's a relative path
                if [[ "$resolved_path" != /* ]]; then
                    resolved_path="${PWD}/${resolved_path}"
                fi

                # Check if executable and under DEVENV_ROOT
                if [[ -x "$word" && "$resolved_path" == "$DEVENV_ROOT"/* ]]; then
                    new_buffer_words+=("echo" "sandboxing --" "$word")
                    modified=1
                else
                    new_buffer_words+=("$word")
                fi
            else
                new_buffer_words+=("$word")
            fi
            expecting=0
        elif [[ "$word" == "|" || "$word" == "|&" || "$word" == ";" || "$word" == "&" || "$word" == "&&" || "$word" == "||" ]]; then
            new_buffer_words+=("$word")
            expecting=1
        else
            new_buffer_words+=("$word")
        fi
    done

    if (( modified )); then
        _devenv_processing=1
        READLINE_LINE="${new_buffer_words[*]}"
        READLINE_POINT=${#READLINE_LINE}
        _devenv_processing=0
    fi
}

# User helper to unhook DevEnv integration.
function _devenv_unhook() {
    bind -r '\C-x\C-z' 2>/dev/null || :
    bind '"\C-m": accept-line' 2>/dev/null || :

    unset -f _devenv_accept_line 2>/dev/null || :
    unset -f _devenv_unhook 2>/dev/null || :
    unset _devenv_processing 2>/dev/null || :
}

# Bind our function to a hidden key combo
bind -x '"\C-x\C-z": _devenv_accept_line'

# Rebind Enter to: run our function, then accept the line
# We use \C-j (linefeed) which triggers accept-line without recursion
bind '"\C-m": "\C-x\C-z\C-j"'
