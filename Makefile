.PHONY: test lint format help install-hooks pre-commit

help:
	@echo "incremental-backup Makefile targets:"
	@echo "  test            - Run all tests"
	@echo "  lint            - Run shellcheck on the backup script"
	@echo "  format          - Format backup script with shfmt"
	@echo "  install-hooks   - Install pre-commit hooks"
	@echo "  pre-commit      - Run pre-commit hooks on all files"

test:
	bats tests/backup.bats

lint:
	shellcheck backup tests/backup.bats

format:
	shfmt -i 2 -sr -ci -w backup

install-hooks:
	uv tool install pre-commit
	pre-commit install

pre-commit:
	pre-commit run --all-files

.PHONY: test lint format help install-hooks pre-commit
