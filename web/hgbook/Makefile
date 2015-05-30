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

#If you don't setup settings yourself: copy from the template
hgbook/settings.py: gensettings

.PHONY: gensettings
gensettings:
	cp hgbook/settings.py.template hgbook/settings.py

.PHONY: syncdb
syncdb: db.sqlite3
db.sqlite3: hgbook/settings.py env
	( \
		source env/bin/activate; \
		python manage.py syncdb; \
	)
        
run: env hgbook/settings.py db.sqlite3
	( \
		source env/bin/activate; \
		python manage.py runserver; \
	)
