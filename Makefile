.PHONY: clean clean-test clean-pyc clean-build clean-venv check-venv check-integration check-unit install-venv develop-venv help
.DEFAULT_GOAL := help

SHELL := /bin/bash
export VIRTUALENVWRAPPER_PYTHON := /usr/bin/python

define BROWSER_PYSCRIPT
import os, webbrowser, sys

try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

check-venv: ## verify that the user is running in a Python virtual environment
	@if [ -z "$(VIRTUALENVWRAPPER_SCRIPT)" ]; then echo 'Python virtualenvwrapper not installed!' && exit 1; fi
	@if [ -z "$(VIRTUAL_ENV)" ]; then echo 'Not running within a virtual environment!' && exit 1; fi

check-integration: ## verify that the environment is configured to run integration tests
	@if [ -z "$(QTEST_API_TOKEN)" ]; then echo 'The QTEST_API_TOKEN environment variable is not present or set!' && exit 1; fi
	@if [ -z "$(QTEST_SANDBOX_PROJECT_ID)" ]; then echo 'The QTEST_SANDBOX_PROJECT_ID environment variable is not present or set!' && exit 1; fi

check-unit: ## verify that the environment is configured to run unit tests
	@if [ -n "$(QTEST_API_TOKEN)" ]; then echo 'The QTEST_API_TOKEN environment variable is set which breaks the unit tests!' && exit 1; fi

clean: clean-test clean-pyc clean-build   ## remove all build, test, coverage, artifacts and wipe virtualenv

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache/

clean-venv: check-venv ## remove all packages from current virtual environment
	@source virtualenvwrapper.sh && wipeenv || echo "Skipping wipe of environment"

lint: ## check style with flake8
	flake8 zigzag setup.py tests

test: check-unit ## run unit tests quickly with the default Python
	py.test tests/unit

test-integration: check-integration ## run integration tests with the default Python
	py.test tests/integration

test-all: ## run lint, unit and integration tests on all supported Python versions
	tox -epy27,py35,flake8,integration_py27,integration_py35,integration_py36

coverage-html: ## check code coverage with an HTML report
	py.test --cov-report html --cov=zigzag tests/
	$(BROWSER) htmlcov/index.html

coverage-term: ## check code coverage with a simple terminal report
	py.test --cov-report term-missing --cov=zigzag tests/

release: clean ## package and upload a release
	python setup.py sdist upload
	python setup.py bdist_wheel upload

dist: clean ## builds source and wheel package
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l dist

install: clean ## install the package to the active Python's site-packages
	python setup.py install

install-editable: ## install the package in editable mode
	if pip list -e | grep 'zigzag'; then echo 'Editable package already installed'; else pip install -e .; fi

install-venv: clean-venv install ## install the package after wiping the vitual environment

develop: clean ## install necessary packages to setup a dev environment
	pip install -r requirements.txt

develop-venv: clean-venv develop ## setup a dev environment after wiping the virtual environment

publish: ## publish package to PyPI
	twine upload dist/*.whl

build: ## build a wheel
	python setup.py bdist_wheel

bump-major: ## bumps the version of by major
	bumpversion major

bump-minor: ## bumps the version of by minor
	bumpversion minor

bump-patch: ## bumps the version of by patch
	bumpversion patch

release-major: develop lint test-all bump-major build publish ## package and upload a major release
	echo 'Successfully released!'
	echo 'Please push the newly created tag and commit to GitHub.'

release-minor: develop lint test-all bump-minor build publish ## package and upload a minor release
	echo 'Successfully released!'
	echo 'Please push the newly created tag and commit to GitHub.'

release-patch: develop lint test-all bump-patch build publish ## package and upload a patch release
	echo 'Successfully released!'
	echo 'Please push the newly created tag and commit to GitHub.'
