# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a professional bash script project that automates the installation and configuration of Neofetch and Starship prompt on Linux (Debian/Ubuntu) and macOS systems. The project supports multiple installation modes (system-wide vs local) and includes comprehensive logging, verification, and uninstallation capabilities.

## Common Commands

### Testing & Development

```bash
# Run installation in dry-run mode (no actual changes)
cd scripts && ./setup_terminal.sh --dry-run

# Run installation locally (without sudo)
cd scripts && ./setup_terminal.sh --local --yes

# Verify installation
cd scripts && ./verify.sh

# Run verbose verification for debugging
cd scripts && ./verify.sh --verbose

# Test uninstallation
cd scripts && ./uninstall.sh --dry-run
```

### Code Quality

```bash
# Run ShellCheck on all scripts
shellcheck scripts/*.sh scripts/lib/*.sh

# Validate Starship config
export STARSHIP_CONFIG=./config/starship.toml
starship print-config > /dev/null
```

### CI/CD

The project uses GitHub Actions for continuous integration. Tests run automatically on:
- Ubuntu 24.04 (local installation)
- macOS latest (Homebrew installation)
- ShellCheck validation
- Configuration validation

## Architecture

### Modular Library System

The codebase uses a modular architecture with reusable libraries in `scripts/lib/`:

- **colors.sh**: Terminal color codes and styling constants
- **logger.sh**: Multi-level logging system (DEBUG, INFO, WARN, ERROR) with timestamped log files
- **utils.sh**: Shared utility functions for OS detection, command existence checks, and version management

All main scripts (`setup_terminal.sh`, `verify.sh`, `uninstall.sh`) source these libraries for consistent behavior.

### Installation Modes

The setup script supports two distinct installation modes:

1. **System Installation** (with sudo): Installs to `/usr/local/bin`, accessible system-wide
2. **Local Installation** (without sudo): Installs to `~/.local/bin`, user-specific

The script intelligently detects privileges and adapts installation paths accordingly. On macOS, Homebrew is the preferred installation method.

### Dual Execution Support

`setup_terminal.sh` is designed to work in two modes:
- **Repository mode**: When run from cloned repo, loads libraries from `scripts/lib/`
- **Standalone mode**: When piped via curl, uses inline fallback functions

This dual-mode design allows both local development and remote one-line installation.

### Shell Integration

The scripts detect the user's shell (bash or zsh) and modify the appropriate RC file:
- Bash: `~/.bashrc`
- Zsh: `~/.zshrc`

Both Neofetch and Starship are integrated into shell startup, with configuration files placed in `~/.config/`.

### Configuration Management

Configuration files in `config/`:
- **starship.toml**: Custom Starship prompt with Git status, language versions, cloud providers
- **neofetch.conf**: Customized system information display

The setup script copies these to `~/.config/` and creates backups of existing configs before overwriting.

## Critical Implementation Details

### Error Handling

- Main scripts use `set -euo pipefail` for strict error checking
- `setup_terminal.sh` uses `set -eo pipefail` (without `-u`) to support piped execution
- All operations log to `/tmp/setup_terminal_YYYYMMDD_HHMMSS.log`
- Failed operations should call `log_error` and exit with non-zero status

### Command Existence Checks

IMPORTANT: When checking if commands exist, use the approach in `scripts/lib/utils.sh:command_exists()`:

```bash
command_exists() {
    command -v "$1" >/dev/null 2>&1 || type "$1" >/dev/null 2>&1
}
```

This pattern is critical for compatibility across different environments. Use the direct approach with fallback, NOT complex PATH manipulation.

### PATH Management

When adding directories to PATH in shell RC files:
- Use proper quoting: `export PATH="$HOME/.local/bin:$PATH"`
- Check if entry already exists to avoid duplicates
- Use `get_shell_rc_file()` from utils.sh to get the correct RC file path

### macOS Homebrew Handling

On macOS:
- Homebrew is the preferred installation method
- Script checks for Homebrew and offers to install if missing
- Homebrew path is automatically added to PATH based on architecture:
  - Apple Silicon: `/opt/homebrew/bin`
  - Intel: `/usr/local/bin`

### Dry-Run Mode

All modification operations must respect the `DRY_RUN` variable:
```bash
if [[ "$DRY_RUN" == false ]]; then
    # actual operation
else
    log_info "[DRY-RUN] Would execute: operation"
fi
```

### Version Management

Version is managed through:
1. Git tags (primary source)
2. `VERSION` file at root (fallback)
3. Function `get_project_version()` in utils.sh handles version detection

When bumping versions, use `scripts/bump-version.sh`.

## Shell Scripting Standards

### Code Style
- Use 4 spaces for indentation (NO tabs)
- Maximum line length: 100 characters
- Variable names: `UPPER_CASE` for globals, `lower_case` for locals
- Function names: `snake_case`

### Function Documentation
Complex functions should have header comments:
```bash
# ==============================================================================
# Function Description
# Arguments:
#   $1 - Description
# Returns:
#   0 on success, 1 on error
# ==============================================================================
```

### Logging
Always use the logging system instead of bare echo:
- `log_info` - General information
- `log_success` - Successful operations
- `log_warn` - Warnings (non-fatal)
- `log_error` - Errors (usually fatal)
- `log_step` - Major workflow steps
- `log_debug` - Debug information (only shown when verbose)

### Guards and Sourcing
Library files use guards to prevent multiple loading:
```bash
[[ -n "${__LIBRARY_NAME_LOADED__:-}" ]] && return 0
__LIBRARY_NAME_LOADED__=1
```

## Platform-Specific Considerations

### Linux (Debian/Ubuntu)
- Uses `apt-get` for package installation
- Requires sudo for system installation
- Supports both system (`/usr/local/bin`) and local (`~/.local/bin`) installation

### macOS
- Prefers Homebrew for package management
- Automatically adds Homebrew to PATH if not present
- Architecture detection for Apple Silicon vs Intel paths
- Does not require sudo when using Homebrew

## Testing Strategy

### Local Testing
1. Run dry-run first: `./scripts/setup_terminal.sh --dry-run`
2. Test local installation: `./scripts/setup_terminal.sh --local --yes`
3. Verify: `./scripts/verify.sh --verbose`
4. Test uninstall: `./scripts/uninstall.sh --dry-run`

### CI/CD Pipeline
- ShellCheck runs on all bash scripts for static analysis
- Ubuntu 24.04 tests local installation path
- macOS tests Homebrew installation path
- Configuration validation ensures configs are syntactically valid

## Common Pitfalls

1. **Do NOT use sudo with --local**: Local installation explicitly avoids requiring sudo
2. **Do NOT modify PATH directly in scripts**: Let the RC file modifications handle PATH updates
3. **Do NOT use `which`**: Use `command -v` or the `command_exists()` function
4. **Do NOT assume bash 4+**: macOS ships with bash 3.2, code must be compatible
5. **Always quote variables**: Use `"$variable"` not `$variable` to handle spaces
6. **Test piped execution**: `curl -fsSL ... | bash` has different behavior than local execution

## File Locations

### User Installations
- Binaries: `~/.local/bin/` or via Homebrew
- Configs: `~/.config/starship.toml`, `~/.config/neofetch/`
- RC modifications: `~/.bashrc` or `~/.zshrc`
- Log files: `/tmp/setup_terminal_*.log`

### System Installations
- Binaries: `/usr/local/bin/`
- Configs: Still in user's `~/.config/` (per-user)
