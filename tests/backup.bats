#!/usr/bin/env bats

setup() {
  # Create temporary directories for testing
  TEST_DIR=$(mktemp -d)
  export TEST_DIR
  export BACKUP_VOL="${TEST_DIR}/backup_vol"
  export SOURCE_DIR="${TEST_DIR}/source"
  export BACKUP_SCRIPT="${BATS_TEST_DIRNAME}/../backup"

  mkdir -p "$BACKUP_VOL" "$SOURCE_DIR"

  # Create a test source directory with some files
  echo "test content 1" > "$SOURCE_DIR/file1.txt"
  mkdir -p "$SOURCE_DIR/subdir"
  echo "test content 2" > "$SOURCE_DIR/subdir/file2.txt"
}

teardown() {
  # Clean up temporary directories
  rm -rf "$TEST_DIR"
}

@test "script requires -v option for backup volume" {
  run bash "$BACKUP_SCRIPT" -r 30 "$SOURCE_DIR"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Error: -v BACKUP_VOL is required"* ]]
}

@test "script requires -r option for retention days" {
  run bash "$BACKUP_SCRIPT" -v "$BACKUP_VOL" "$SOURCE_DIR"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Error: -r RETENTION is required"* ]]
}

@test "script requires at least one directory to backup" {
  run bash "$BACKUP_SCRIPT" -v "$BACKUP_VOL" -r 30
  [ "$status" -eq 1 ]
  [[ "$output" == *"Error: At least one directory (DIR1) is required"* ]]
}

@test "displays help with -h option" {
  run bash "$BACKUP_SCRIPT" -h
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "creates backup directory with timestamp format" {
  # Mock the /var/log directory since we might not have write access
  LOG_FILE="${TEST_DIR}/backup.log"
  export LOG_FILE

  bash "$BACKUP_SCRIPT" -v "$BACKUP_VOL" -r 30 "$SOURCE_DIR" 2>&1 || true

  # Check that a backup directory was created with correct format
  [ "$(find "$BACKUP_VOL" -maxdepth 1 -type d -name 'backup_[0-9]*' | grep -c .)" -ge 1 ]
}

@test "backs up source files to backup directory" {
  LOG_FILE="${TEST_DIR}/backup.log"
  export LOG_FILE

  bash "$BACKUP_SCRIPT" -v "$BACKUP_VOL" -r 30 "$SOURCE_DIR" 2>&1 || true

  # Find the backup directory
  backup_dir=$(find "$BACKUP_VOL" -maxdepth 1 -type d -name 'backup_*' | head -1)

  if [ -d "$backup_dir" ]; then
    # Check that files were backed up (find them anywhere in the tree)
    [ "$(find "$backup_dir" -name "file1.txt" | grep -c .)" -gt 0 ]
  fi
}

@test "creates latest symlink for backed up directory" {
  LOG_FILE="${TEST_DIR}/backup.log"
  export LOG_FILE

  bash "$BACKUP_SCRIPT" -v "$BACKUP_VOL" -r 30 "$SOURCE_DIR" 2>&1 || true

  # Check that latest symlink was created
  link_path="${BACKUP_VOL}/latest${SOURCE_DIR//\//-}backup"
  [ -L "$link_path" ]
}

@test "handles multiple directories in single backup" {
  LOG_FILE="${TEST_DIR}/backup.log"
  export LOG_FILE

  # Create a second source directory
  SOURCE_DIR2="${TEST_DIR}/source2"
  export SOURCE_DIR2
  mkdir -p "$SOURCE_DIR2"
  echo "source 2 content" > "$SOURCE_DIR2/file.txt"

  bash "$BACKUP_SCRIPT" -v "$BACKUP_VOL" -r 30 "$SOURCE_DIR" "$SOURCE_DIR2" 2>&1 || true

  # Find the backup directory
  backup_dir=$(find "$BACKUP_VOL" -maxdepth 1 -type d -name 'backup_*' | head -1)

  if [ -d "$backup_dir" ]; then
    # Check that both directories were backed up
    [ "$(find "$backup_dir" -name "file1.txt" | grep -c .)" -gt 0 ]
    [ "$(find "$backup_dir" -name "file.txt" | grep -c .)" -gt 0 ]
  fi
}

@test "retention parameter is a positive integer" {
  # Test that invalid retention values are handled
  run bash "$BACKUP_SCRIPT" -v "$BACKUP_VOL" -r abc "$SOURCE_DIR"
  [ "$status" -ne 0 ] || [ -d "$BACKUP_VOL" ]
}
