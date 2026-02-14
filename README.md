# Incremental Backup Script

A bash script for performing incremental backups using rsync with hard links
for space efficiency.

## Features

- Incremental backups using rsync with `--link-dest` for space efficiency
- Automatic retention policy to delete old backups
- Symlink tracking of latest backups per directory
- Comprehensive logging to `/var/log/incremental-backup.log`
- Shellcheck validated

## Requirements

- bash
- rsync
- find

## Usage

```bash
./backup -v BACKUP_VOL -r RETENTION DIR1 [DIR2] ...
```

### Options

- `-v BACKUP_VOL`: Backup volume path (required)
- `-r RETENTION`: Number of days to retain backups (required)
- `-h`: Display help message
- `DIR1 [DIR2] ...`: One or more directories to backup (required)

### Examples

Backup `/root/` and `/opt/ghost/` to `/mnt/ghost_backup` with 90-day retention:

```bash
./backup -v /mnt/ghost_backup -r 90 /root/ /opt/ghost/
```

Backup a single directory with 30-day retention:

```bash
./backup -v /backup/volume -r 30 /home/user/documents/
```

## How It Works

1. Creates a timestamped backup directory in the format `backup_YYYY-MM-DD_HH-MM-SS`
2. For each specified directory:
   - Uses rsync to create an incremental backup
   - Links unchanged files to the previous backup using `--link-dest` (saves space)
   - Updates a "latest" symlink for easy access to the most recent backup
3. Removes backups older than the specified retention period

## Backup Structure

```text
BACKUP_VOL/
├── backup_2026-02-06_10-30-00/
│   ├── root/
│   └── opt/ghost/
├── backup_2026-02-07_10-30-00/
│   ├── root/
│   └── opt/ghost/
├── latest-root--backup -> backup_2026-02-07_10-30-00/root
└── latest-opt-ghost--backup -> backup_2026-02-07_10-30-00/opt/ghost
```

## Logging

All backup operations are logged to `/var/log/incremental-backup.log` with timestamps.

## Testing

The project includes comprehensive tests using [bats](https://github.com/bats-core/bats-core) (Bash Automated Testing System).

### Running Tests Locally

First, install bats:

```bash
# macOS with Homebrew
brew install bats-core

# Ubuntu/Debian
apt-get install bats
```

Then run the tests:

```bash
make test
```

### Running Linting and Formatting

Check the script with ShellCheck:

```bash
make lint
```

Format the script with shfmt:

```bash
make format
```

### Testing with Custom Log File

For testing purposes, you can override the log file location using the `LOG_FILE` environment variable:

```bash
LOG_FILE=/tmp/backup.log ./backup -v /tmp/backup_vol -r 30 /path/to/dir
```

## License

Mozilla Public License 2.0
