#!/usr/bin/env zsh
#
# # Usage
#
# Add this to your ~/.zshrc:
#
#   source /path/to/peninsula-hook.zsh
#
# # Goal
#
# Wrap script/binary executions under $DEVENV_ROOT with echo for visibility.
# Only handles commands with paths (e.g., ./script.sh, bin/tool).
#
# # How it works
#
# - Use the accept-line ZLE widget to intercept the Enter key.
# - Parse the command line to identify path-based commands (containing /).
# - For executables under $DEVENV_ROOT, prepend echo to show the command.

# Ensure clean state if re-sourced.
if functions _peninsula_unhook >/dev/null; then
    _peninsula_unhook
fi

function _peninsula_accept_line() {
    emulate -L zsh

    # Skip if DEVENV_ROOT is not set.
    if [[ -z "$DEVENV_ROOT" ]]; then
        zle _peninsula_orig_accept_line
        return
    fi

    local word expecting=1 modified=0
    local -a new_buffer_words

    # (z) splits the buffer into words respecting shell quoting rules.
    for word in "${(z)BUFFER}"; do
        if (( expecting )); then
            if [[ "$word" == *=* ]]; then
                new_buffer_words+=("$word")
                continue
            fi

            # Handle paths (containing /)
            if [[ "$word" == */* ]]; then
                local resolved_path="${(Q)word}"

                # Resolve to absolute path if it's a relative path
                if [[ "$resolved_path" != /* ]]; then
                    resolved_path="${PWD}/${resolved_path}"
                fi

                # Check if executable and under DEVENV_ROOT
                if [[ -x "${(Q)word}" && "$resolved_path" == "$DEVENV_ROOT"/* ]]; then
                    new_buffer_words+=("echo" "sandboxing --" "$word")
                    modified=1
                else
                    new_buffer_words+=("$word")
                fi
            else
                new_buffer_words+=("$word")
            fi
            expecting=0
        elif [[ "$word" == ("|"|"|&"|";"|"&"|"&&"|"||") ]]; then
            new_buffer_words+=("$word")
            expecting=1
        else
            new_buffer_words+=("$word")
        fi
    done

    if (( modified )); then
        BUFFER="${new_buffer_words}"
    fi

    zle _peninsula_orig_accept_line
}

# User helper to unhook Peninsula integration.
function _peninsula_unhook() {
    emulate -L zsh

    zle -A _peninsula_orig_accept_line accept-line
    zle -D _peninsula_orig_accept_line

    unfunction _peninsula_accept_line 2>/dev/null || :
    unfunction _peninsula_unhook 2>/dev/null || :
}

# Wrap the accept-line widget to intercept commands.
if ! zle -l _peninsula_orig_accept_line; then
    zle -A accept-line _peninsula_orig_accept_line
fi
zle -N accept-line _peninsula_accept_line
