#Set shell to bash, so we can use 'source'
SHELL := /bin/bash

all:
	@echo "Make targets"
	@echo "============"
	@echo "Setup environment: env"
	@echo "Run webserver:     run"

env:
	( \
	virtualenv env; \
	source env/bin/activate; \
	pip install -r requirements.txt; \
	)

run: env
	( \
		source env/bin/activate; \
		python manage.py runserver; \
	)
