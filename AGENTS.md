# AGENTS.md - Autonomous Agent Guide

This document provides essential information for autonomous AI agents working with the incremental-backup project.

## Project Overview

**incremental-backup** is a bash script that performs space-efficient incremental backups using rsync with hard links. The script is fully tested, linted, and ready for agent-driven development.

## Quick Start

### Prerequisites

- bash
- rsync
- find
- (Optional) GNU make for running commands via Makefile
- (Optional) bats for running tests locally

### Single Command Setup

Get the project running with:

```bash
git clone https://github.com/chorrell/incremental-backup.git
cd incremental-backup
make test  # Verify everything works
```

Or manually:

```bash
git clone https://github.com/chorrell/incremental-backup.git
cd incremental-backup
bats tests/backup.bats  # Run tests
```

## Available Commands

### Build & Development

| Command | Purpose |
| --- | --- |
| `make test` | Run all bats tests |
| `make lint` | Run ShellCheck on all shell scripts |
| `make format` | Format shell scripts with shfmt (2-space indent) |
| `./backup -h` | Display help and usage information |

### Running Backups

```bash
./backup -v BACKUP_VOL -r RETENTION DIR1 [DIR2] ...
```

**Parameters:**

- `-v BACKUP_VOL`: Destination backup volume path (required)
- `-r RETENTION`: Days to retain backups (required)
- `DIR1 [DIR2] ...`: One or more source directories (required)
- `-h`: Show help message

**Examples:**

```bash
# Single directory backup with 30-day retention
./backup -v /mnt/backups -r 30 /home/user/documents

# Multiple directories in one backup run
./backup -v /mnt/backups -r 90 /root /opt/ghost /var/www

# With custom log file (for testing)
LOG_FILE=/tmp/test.log ./backup -v /tmp/backup_vol -r 30 /path/to/dir
```

## Project Structure

```text
incremental-backup/
├── backup                          # Main backup script
├── Makefile                        # Task runner with test/lint/format targets
├── README.md                       # User documentation
├── AGENTS.md                       # This file - Agent documentation
├── LICENSE                         # Mozilla Public License 2.0
├── tests/
│   └── backup.bats                # Comprehensive bats test suite (9 tests)
└── .github/
    └── workflows/
        ├── shellcheck.yml         # Linting CI workflow
        └── test.yml               # Test CI workflow
```

## Development Workflow

### Before Making Changes

1. **Run tests** to establish baseline:

   ```bash
   make test
   ```

2. **Review existing tests** in `tests/backup.bats` to understand expected behavior

3. **Check code style** with make lint:

   ```bash
   make lint
   ```

### Making Changes

1. **Create a feature branch:**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Modify the `backup` script** as needed

3. **Run tests after each change:**

   ```bash
   make test
   ```

4. **Fix any linting issues:**

   ```bash
   make lint        # Check for issues
   make format      # Auto-fix formatting
   ```

5. **Add tests** for new functionality in `tests/backup.bats`

### Before Creating a PR

Ensure all checks pass:

```bash
make test   # All 9 tests pass
make lint   # No ShellCheck or shfmt violations
```

## Code Style & Conventions

### Bash Script Standards

- **Indentation:** 2 spaces (enforced by shfmt)
- **Shebang:** `#!/usr/bin/env bash`
- **Error handling:** Use `set -euo pipefail` for strict mode
- **Quoting:** Always quote variables (`"$var"` not `$var`)
- **Comments:** Use `#` for inline comments, document functions above their definition

### Test Conventions

- **Test file:** `tests/backup.bats` uses bats framework
- **Test naming:** Use descriptive `@test "description"` blocks
- **Naming pattern:** Test names describe behavior, not implementation
- **Environment setup:** Use `setup()` function to initialize test data
- **Cleanup:** Use `teardown()` function to remove test artifacts

Example test structure:

```bash
@test "feature does X with Y input" {
  # Arrange
  export VAR="value"

  # Act
  bash "$BACKUP_SCRIPT" -v "$BACKUP_VOL" -r 30 "$SOURCE_DIR"

  # Assert
  [ -d "$backup_dir" ]
}
```

## Important Files & Their Purposes

| File | Purpose | Modifications |
| --- | --- | --- |
| `backup` | Main script - implements incremental backup logic | Core logic changes go here |
| `tests/backup.bats` | Test suite - validates backup script behavior | Add tests for new features |
| `Makefile` | Task automation - provides test/lint/format targets | Rarely needs changes |
| `README.md` | User documentation - how to use the script | Update with new user-facing features |
| `AGENTS.md` | Agent documentation (this file) | Update when development workflow changes |

## Testing Guide

### Running Tests

```bash
# Run all tests
make test

# Or directly with bats
bats tests/backup.bats

# Run with verbose output
bats tests/backup.bats --verbose
```

### What the Tests Cover

The 9 tests in `tests/backup.bats` validate:

1. ✅ Script requires `-v` option for backup volume
2. ✅ Script requires `-r` option for retention days
3. ✅ Script requires at least one directory to backup
4. ✅ Script displays help with `-h` option
5. ✅ Backup directory created with correct timestamp format
6. ✅ Source files backed up correctly
7. ✅ Latest symlink created for each directory
8. ✅ Multiple directories handled in single backup run
9. ✅ Retention parameter validation

### Adding New Tests

When adding new features:

1. Add a test case in `tests/backup.bats`
2. Use `BACKUP_SCRIPT` variable to reference the backup script
3. Use `$TEST_DIR`, `$BACKUP_VOL`, `$SOURCE_DIR` for test files/directories
4. Tests automatically clean up via `teardown()` function

Example:

```bash
@test "new feature description" {
  LOG_FILE="${TEST_DIR}/backup.log"
  export LOG_FILE

  bash "$BACKUP_SCRIPT" -v "$BACKUP_VOL" -r 30 "$SOURCE_DIR" 2>&1 || true

  # Your assertions here
  [ "$(find "$BACKUP_VOL" -name "*.txt" | wc -l)" -gt 0 ]
}
```

## CI/CD Workflows

### Linting Workflow (`.github/workflows/shellcheck.yml`)

Triggers on:

- Changes to `backup` script
- Changes to `tests/**` files
- Changes to `.github/workflows/shellcheck.yml`

Runs:

- ShellCheck on `backup` and `tests/backup.bats`
- shfmt formatting check (2-space indent, spaces around redirects)

**Action:** PR will fail if ShellCheck finds issues or shfmt detects formatting violations

### Test Workflow (`.github/workflows/test.yml`)

Triggers on:

- Changes to `backup` script
- Changes to `tests/**` files
- Changes to `.github/workflows/test.yml`
- Changes to `Makefile`

Runs:

- Sets up bats and bats libraries (support, assert, detik, file)
- Runs `bats tests/backup.bats`

**Action:** PR will fail if any test fails

## Common Tasks

### Add a Command-line Option

1. Update argument parsing in `backup` script
2. Add validation logic
3. Write test in `tests/backup.bats`
4. Update README.md with new option
5. Run `make test && make lint`

### Fix a Bug

1. Write a failing test that reproduces the bug
2. Fix the bug in `backup` script
3. Verify test passes with `make test`
4. Run `make lint` to ensure code style
5. Create PR with the test and fix

### Improve Documentation

1. Update README.md (for users) or AGENTS.md (for agents)
2. No tests needed, but CI will still validate shell scripts
3. Create PR with documentation changes

## Environment Variables

Key environment variables:

| Variable | Purpose | Default |
| --- | --- | --- |
| `LOG_FILE` | Location for backup logs | `/var/log/incremental-backup.log` |
| `BATS_LIB_PATH` | Path to bats libraries (tests only) | Set by bats-action |

## Resources

- **Bats Documentation:** [https://github.com/bats-core/bats-core](https://github.com/bats-core/bats-core)
- **ShellCheck Reference:** [https://www.shellcheck.net](https://www.shellcheck.net)
- **shfmt Options:** [https://github.com/mvdan/sh](https://github.com/mvdan/sh)
- **Project License:** Mozilla Public License 2.0 (see LICENSE file)

## Support for AI Agents

This project is designed to be agent-friendly:

- ✅ **Reproducible environment:** All dependencies are documented
- ✅ **Comprehensive tests:** 9 tests with clear pass/fail criteria
- ✅ **Automated validation:** CI checks prevent broken commits
- ✅ **Clear conventions:** Naming, style, and workflow documented
- ✅ **Single-command setup:** `make test` validates everything
- ✅ **Relative paths:** Tests work from any checkout location

Agents should:

- Always run `make test` after changes
- Always run `make lint` before creating PRs
- Write tests for new functionality
- Follow the 2-space indentation standard
- Reference `BACKUP_SCRIPT` variable instead of hardcoded paths
