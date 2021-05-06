.PHONY: clean data lint requirements sync_data_to_s3 sync_data_from_s3

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
BUCKET = {{ cookiecutter.s3_bucket }}
PROFILE = {{ cookiecutter.aws_profile }}
PROJECT_NAME = {{ cookiecutter.project_name }}
REPO_NAME = {{ cookiecutter.repo_name }}
PROJECT_DESC = {{ cookiecutter.description }}
LICENSE = {{ cookiecutter.open_source_license }}
PYTHON_INTERPRETER = {{ cookiecutter.python_interpreter }}
PYTHON_VERSION = {{ cookiecutter.python_version }}
VENV_NAME = {{ cookiecutter.repo_name }}-{{ cookiecutter.python_version }} 
GITHUB_USERNAME = {{ cookiecutter.github_username }}
GCLOUD_INSTANCE_NAME = {{ cookiecutter.gcloud_instance_name }}
GCLOUD_COMPUTE_ZONE = {{ cookiecutter.gcloud_compute_zone }}
GCLOUD_BUCKET = {{ cookiecutter.gcloud_storage_bucket }}
GCLOUD_BUCKET_ZONE = {{ cookiecutter.gcloud_storage_zone }}

ifeq (,$(shell which pyenv))
	HAS_PYENV=False
else
	HAS_PYENV=True
endif

ifeq (,$(shell which poetry))
	HAS_POETRY=False
else
	HAS_POETRY=True
endif

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Symbolic to to data folder
lns-data:
	sh .symlink-to-data.sh

## Run Byobu (terminal multiplexer, F6 - Detach from session) 
byobu:
	@echo ">>> Byobu installation command is given below:\n   sudo apt install byobu\n    brew install byobu"
	byobu

## Set up python interpreter environment
venv-create:
ifeq (True,$(HAS_PYENV))
	@echo ">>> Detected pyenv, creating virtual environment."
	pyenv virtualenv $(PYTHON_VERSION) $(VENV_NAME)
	pyenv local $(VENV_NAME)
	pip install --upgrade pip
	@echo ">>> New virtual env created. Activate with:\npyenv activate $(VENV_NAME)"
else
	@echo ">>> pyenv does not exist. install pyenv first."
endif

## Remove python interpreter environment
venv-delete:
ifeq (True,$(HAS_PYENV))
	@echo ">>> Detected pyenv, removing virtual environment."
	pyenv uninstall $(VENV_NAME)
	@echo ">>> Virtual env $(VENV_NAME) removed."
else
	@echo ">>> pyenv does not exist. install pyenv first."
endif

## Initiate poetry
poetry-init:
ifeq (True,$(HAS_POETRY))
	@echo ">>> Detected poetry, initiate poetry project."
	poetry init --description="$(PROJECT_DESC)" --license="$(LICENSE)"
else
	@echo ">>> poetry does not exist. install poetry first."
endif

## Install dotevn
poetry-add-dotenv:
ifeq (True,$(HAS_POETRY))
	@echo ">>> Detected poetry, initiate poetry project."
	poetry add python-dotenv --dev
else
	@echo ">>> poetry does not exist. install poetry first."
endif

## Export python interpreter environment 
poetry-export:
ifeq (True,$(HAS_POETRY))
	@echo ">>> Detected poetry, exporting virtual environment."
	poetry export -f requirements.txt --output requirements-poetry.txt --without-hashes
	@echo ">>> Virtual env $(VENV_NAME) exported."
else
	@echo ">>> poetry does not exist. install poetry first."
endif

## Update python interpreter environment
poetry-install:
ifeq (True,$(HAS_POETRY))
	@echo ">>> Detected poetry, install poetry packages from pyproject.toml."
	poetry install
	@echo ">>> Virtual env $(VENV_NAME) updated."
else
	@echo ">>> poetry does not exist. install poetry first."
endif

## Test python environment is setup correctly
py-test:
	$(PYTHON_INTERPRETER) test_environment.py

## Install Python Dependencies
pip-req: py-test
	# $(PYTHON_INTERPRETER) -m pip install -U pip setuptools wheel
	$(PYTHON_INTERPRETER) -m pip install -r requirements.txt

## Make Dataset
data-make: py-test
	# $(PYTHON_INTERPRETER) {{ cookiecutter.repo_name }}/data/make_dataset.py data/raw data/processed
	sh {{ cookiecutter.repo_name }}/data/make_dataset.sh

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using flake8
lint:
	flake8 src

## Add Virtual Environment to Jupyter Notebook
ipykernel:
	@echo "After run following commands, check pyenv venv path in kernel.json\n"
ifeq (True,$(HAS_POETRY))
	poetry add ipykernel --dev 
else
	pip install ipykernel
endif
	python -m ipykernel install --user --name=$(VENV_NAME)

## Launch Jupyter Notebook
nb-run:
	@echo "nohup jupyter notebook --no-browser --port=8080 --allow-root > .jupyter_error.log &"
	@bash -c "nohup jupyter notebook --no-browser --port=8080 --allow-root > .jupyter_error_$(shell hostname).log &"

## Stop Jupyter Notebook
nb-kill:
	ps aux | grep jupyter
	@echo "kill -9 #jupyter_pid"
	
## Create a new repository on GitHub and set the remote as upstream
github-create:
	hub create -p ${PROJECT_NAME}
	git push -u origin main

## Initialize git repository and make the fist commit
git-init:
	git init
	git add --all
	git commit -m "Make the first commit"

## Bind remote repository to the local repository:
github-bind:
	git remote add origin https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}.git
	git push -u origin main

## Start Google Cloud Instance
gc-on:
	gcloud compute instances start $(GCLOUD_INSTANCE_NAME) --zone=${GCLOUD_COMPUTE_ZONE}

## Stop Google Cloud Instance
gc-off:
	gcloud compute instances stop $(GCLOUD_INSTANCE_NAME) --zone=${GCLOUD_COMPUTE_ZONE}

## Connect to Google Cloud Instance
gc-ssh:
	gcloud compute ssh --zone=${GCLOUD_COMPUTE_ZONE} jupyter@$(GCLOUD_INSTANCE_NAME) -- -L 8080:localhost:8080

## List Google Compute instances
gc-ls:
	gcloud compute instances list
	
## Create a bucket on Google Storage
gs-mb:
	gsutil mb -l ${GCLOUD_BUCKET_ZONE} gs://$(GCLOUD_BUCKET)/

## Clean up the bucket on Google Storage
gs-rm:
	gsutil rm -r gs://$(GCLOUD_BUCKET)/

## Upload Data to Google Storage
gs-up:
	gsutil rsync -d -r data gs://$(GCLOUD_BUCKET)/data

## Download Data from Google Storage
gs-dn:
	gsutil rsync -d -r gs://$(GCLOUD_BUCKET)/data data

## Upload Data to S3
s3-up:
ifeq (default,$(PROFILE))
	aws s3 sync data/ s3://$(BUCKET)/data/
else
	aws s3 sync data/ s3://$(BUCKET)/data/ --profile $(PROFILE)
endif

## Download Data from S3
s3-dn:
ifeq (default,$(PROFILE))
	aws s3 sync s3://$(BUCKET)/data/ data/
else
	aws s3 sync s3://$(BUCKET)/data/ data/ --profile $(PROFILE)
endif


#################################################################################
# PROJECT RULES                                                                 #
#################################################################################



#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=20 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
