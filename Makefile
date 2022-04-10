.PHONY: help init compile-requirements
.DEFAULT_GOAL := help


DOCS_BUILD_DIR  = ./docs/_build/
DOCS_SOURCE_DIR = ./docs/
DOCS_GIT_BRANCH = gh-pages
PYTHON_DIR      = ./webapp_portefolio

init:
	@python -m pip install --upgrade pip
#	@python -m pip install --upgrade -r dev-reuirements.txt # if pip-tools activated
	@python -m pip install --upgrade -r requirements/dev.txt

compile-requirements:
	@python -m pip install pip-tools
	pip-compile --upgrade requirements/requirements.ini --output-file requirements.txt
	pip-compile --upgrade requirements/requirements-dev.ini --output-file requirements-dev.txt

lint: # Lint the project
	@python -m tox -e lint


CONTAINER_PREFIX=portefolio
DC=docker-compose -p ${CONTAINER_PREFIX}

build: ## Build the containers and pull FROM statements
	${DC} build

rebuild: ## Rebuild containers
	${MAKE} down build up

start: ## Start the containers
	${DC} start

stop: ## Stop the containers
	${DC} stop

up: ## Up the containers
	${DC} up -d

down: ## Down the containers (keep volumes)
	${DC} down

destroy: ## Destroy the containers, volumes, networks…
	${DC} down -v --remove-orphan

# test: # Run tests
# 	@sed -e 's/=.*/=1/' "./config/features.env" > "./config/features-tests.env"
# 	@sed -a && source "./config/features-tests.env" && set +a $$ unset "REQUESTS_CA_BUNDLE" && python -m tox -e test


# functional:
# 	export PYTHONPATH=$PYTHONPATH:.
# 	@sed -e 's/=.*/=1' "./config/features.env" > "./config/features-tests.env"
# 	@sed -a && source "./config/features-tests.env" && set +a $$ unset "REQUESTS_CA_BUNDLE" && python -m tox -   e functional

.PHONY: help
help: ## Display this help
	@IFS=$$'\n'; for line in `grep -E '^[a-zA-Z_#-]+:?.*?## .*$$' $(MAKEFILE_LIST)`; do if [ "$${line:0:2}" = "##" ]; then \
	echo $$line | awk 'BEGIN {FS = "## "}; {printf "\n\033[33m%s\033[0m\n", $$2}'; else \
	echo $$line | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'; fi; \
	done; unset IFS;