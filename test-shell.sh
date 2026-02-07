#!/usr/bin/env bash
# Start an interactive shell (zsh or bash) with devenv-hook loaded

show_help() {
    cat <<EOF
Usage: $0 <shell>

Start an interactive shell with peninsula hook loaded.

Arguments:
  shell    The shell to use (bash or zsh)

Examples:
  $0 bash
  $0 zsh
EOF
    exit 1
}

# Check if argument is provided
if [[ $# -ne 1 ]]; then
    echo "Error: Missing shell argument" >&2
    echo >&2
    show_help
fi

SHELL_TO_USE="$1"

# Validate shell argument
if [[ "$SHELL_TO_USE" != "bash" && "$SHELL_TO_USE" != "zsh" ]]; then
    echo "Error: Invalid shell '$SHELL_TO_USE'" >&2
    echo >&2
    show_help
fi

# Verify the shell is available
if ! command -v "$SHELL_TO_USE" >/dev/null 2>&1; then
    echo "Error: $SHELL_TO_USE is not installed or not in PATH" >&2
    exit 1
fi

export DEVENV_ROOT=$PWD

if [[ "$SHELL_TO_USE" == "zsh" ]]; then
    # Create a temporary ZDOTDIR with a .zshrc that sources the devenv hook
    TEMP_ZDOTDIR=$(mktemp -d)
    trap "rm -rf '$TEMP_ZDOTDIR'" EXIT

    cat > "$TEMP_ZDOTDIR/.zshrc" <<'ZSHRC'
# Source the peninsula hook first
source "$DEVENV_ROOT/peninsula-hook.zsh"

# Then source the user's regular .zshrc if it exists
[[ -f ~/.zshrc ]] && source ~/.zshrc
ZSHRC

    # Start zsh with the temporary ZDOTDIR
    ZDOTDIR="$TEMP_ZDOTDIR" exec zsh -i
else
    # Create a temporary .bashrc that sources the devenv hook
    TEMP_BASHRC=$(mktemp)
    trap "rm -f '$TEMP_BASHRC'" EXIT

    cat > "$TEMP_BASHRC" <<'BASHRC'
# Source the peninsula hook first
source "$DEVENV_ROOT/peninsula-hook.bash"

# Then source the user's regular .bashrc if it exists
[[ -f ~/.bashrc ]] && source ~/.bashrc
BASHRC

    # Start bash with the temporary .bashrc
    exec bash --rcfile "$TEMP_BASHRC" -i
fi
