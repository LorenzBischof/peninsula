#!/usr/bin/env bash
# Start an interactive zsh shell with devenv-hook loaded

export DEVENV_ROOT=$PWD

# Create a temporary ZDOTDIR with a .zshrc that sources the devenv hook
TEMP_ZDOTDIR=$(mktemp -d)
trap "rm -rf '$TEMP_ZDOTDIR'" EXIT

cat > "$TEMP_ZDOTDIR/.zshrc" <<'ZSHRC'
# Source the devenv hook first
source "$DEVENV_ROOT/devenv-hook.zsh"

# Then source the user's regular .zshrc if it exists
[[ -f ~/.zshrc ]] && source ~/.zshrc
ZSHRC

# Start zsh with the temporary ZDOTDIR
ZDOTDIR="$TEMP_ZDOTDIR" exec zsh -i
