# Peninsula

A lightweight shell hook that sandboxes directly executed scripts and binaries.

## What It Does

Peninsula intercepts local script and binary executions (anything with a `/` in the path) and runs them in a sandboxed environment. This provides isolation and control over commands executed within your development workspace.

## Usage

### Option 1: Source directly in your shell

For Zsh:
```zsh
source /path/to/peninsula/peninsula-hook.zsh
```

For Bash:
```bash
source /path/to/peninsula/peninsula-hook.bash
```

### Option 2: Launch an interactive shell

```bash
./test-shell.sh bash  # For bash
./test-shell.sh zsh   # For zsh
```

This creates a new shell session with `DEVENV_ROOT` set to your current directory and the hook pre-loaded.

## Features

- **Automatic sandboxing**: Local scripts and binaries are automatically sandboxed
- **Smart detection**: Only affects commands containing paths (e.g., `./script.sh`, `bin/tool`)
- **Shell-aware**: Respects environment variables, pipes, redirects, and command chaining
- **Zero configuration**: Works out of the box with Zsh or Bash

## How It Works

Peninsula uses shell-specific mechanisms to intercept commands before execution:
- **Zsh**: Uses ZLE (Zsh Line Editor) widgets to intercept the accept-line action
- **Bash**: Uses readline bindings with `bind -x` to intercept command execution

When you run a local script or binary, Peninsula wraps it in a sandboxing context scoped to your `$DEVENV_ROOT`.

## Example

```zsh
$ ./test-script.sh
sandboxing -- ./test-script.sh
Test script executed successfully!
```

## Requirements

- Zsh or Bash shell

## Credits

Inspired by [island](https://github.com/landlock-lsm/island)

## Disclaimer

⚠️ This project was vibe-coded. Use at your own risk.
