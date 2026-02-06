# Peninsula

A lightweight Zsh hook that sandboxes directly executed scripts and binaries.

## What It Does

Peninsula intercepts local script and binary executions (anything with a `/` in the path) and runs them in a sandboxed environment. This provides isolation and control over commands executed within your development workspace.

## Usage

### Option 1: Source directly in your shell

```bash
source /path/to/peninsula/devenv-hook.zsh
```

### Option 2: Launch an interactive shell

```bash
./devenv-shell.sh
```

This creates a new Zsh session with `DEVENV_ROOT` set to your current directory and the hook pre-loaded.

## Features

- **Automatic sandboxing**: Local scripts and binaries are automatically sandboxed
- **Smart detection**: Only affects commands containing paths (e.g., `./script.sh`, `bin/tool`)
- **Shell-aware**: Respects environment variables, pipes, redirects, and command chaining
- **Reversible**: Disable anytime with `_devenv_unhook` function
- **Zero configuration**: Works out of the box with any Zsh environment

## How It Works

Peninsula uses a Zsh Line Editor (ZLE) widget to intercept commands before execution. When you run a local script or binary, Peninsula wraps it in a sandboxing context scoped to your `$DEVENV_ROOT`.

## Example

```zsh
$ ./test-script.sh
sandboxing -- ./test-script.sh
Test script executed successfully!
```

## Requirements

- Zsh shell

## Credits

Inspired by [island](https://github.com/landlock-lsm/island)

## Disclaimer

⚠️ This project was vibe-coded. Use at your own risk.
