.PHONY: test lint format help

help:
	@echo "incremental-backup Makefile targets:"
	@echo "  test      - Run all tests"
	@echo "  lint      - Run shellcheck on the backup script"
	@echo "  format    - Format backup script with shfmt"

test:
	bats tests/backup.bats

lint:
	shellcheck backup tests/backup.bats

format:
	shfmt -i 2 -sr -ci -w backup

.PHONY: test lint format help
