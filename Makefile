.PHONY: test lint format help pre-commit

help:
	@echo "incremental-backup Makefile targets:"
	@echo "  test            - Run all tests"
	@echo "  lint            - Run shellcheck on the backup script"
	@echo "  format          - Format backup script with shfmt"
	@echo "  pre-commit      - Run pre-commit hooks on all files"

test:
	docker run --rm -v "$$PWD:/code" -w /code alpine:latest sh -c "apk add --no-cache bash bats rsync && bats /code/tests/backup.bats"

lint:
	docker run --rm -v "$$PWD:/code" koalaman/shellcheck:stable /code/backup /code/tests/backup.bats

format:
	docker run --rm -v "$$PWD:/code" mvdan/shfmt:v3 -i 2 -sr -ci -w /code/backup

pre-commit:
	pre-commit run --all-files

.PHONY: test lint format help pre-commit
