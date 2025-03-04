setup: .venv ## prepare the environment

lint: setup
	poetry run flake8 dtcli
	# TODO: reenable those pesky warnings in .flake8
	# TODO: bump CI for entire source code

.venv: poetry.lock
	python -m venv .venv
	poetry install
	touch .venv

type-check: setup
	#poetry run mypy --strict dtcli/scripts/dt.py
	# TODO: enable all errors
	! poetry run mypy --strict dtcli | grep 'Module has no attribute'
	#poetry run mypy --strict dtcli
	# TODO: enable all error all files
	# TODO: bump CI
	# TODO: fix colors!

test: setup
	poetry run pytest -x

ble: setup
	poetry run pyinstaller \
		dtcli/__main__.py \
		--name dt \
		--clean \
		-p "$(poetry env info -p)/lib/python3.9/site-packages" \
		--onefile

ci: lint type-check test

bump-version: setup ## bumps version (sepecified into VERSION)
	poetry run bump2version --no-tag --no-commit --new-version $(VERSION) whatever

.PHONY: help init
init: ## one time setup
	direnv allow .

help: ## print this message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help
