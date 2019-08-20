.PHONY: clean data lint requirements sync_data_to_s3 sync_data_from_s3

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
BUCKET = {{ cookiecutter.s3_bucket }}
PROFILE = {{ cookiecutter.aws_profile }}
PROJECT_NAME = {{ cookiecutter.repo_name }}
PYTHON_INTERPRETER = {{ cookiecutter.python_interpreter }}
GITHUB_USERNAME = {{ cookiecutter.github_username }}
GCLOUD_INSTANCE_NAME = {{ cookiecutter.gcloud_instance_name }}
GCLOUD_COMPUTE_ZONE = {{ cookiecutter.gcloud_compute_zone }}
GCLOUD_BUCKET = {{ cookiecutter.gcloud_storage_bucket }}
GCLOUD_BUCKET_ZONE = {{ cookiecutter.gcloud_storage_zone }}

ifeq (,$(shell which conda))
	HAS_CONDA=False
else
	HAS_CONDA=True
endif

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Install Python Dependencies
install_reqs: test_env
	$(PYTHON_INTERPRETER) -m pip install -U pip setuptools wheel
	$(PYTHON_INTERPRETER) -m pip install -r requirements.txt

## Make Dataset
data: install_reqs
	$(PYTHON_INTERPRETER) src/data/make_dataset.py data/raw data/processed

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using flake8
lint:
	flake8 src

## Launch Jupyter Notebook
start_jupyter:
	nohup jupyter notebook --no-browser --port=8080 --allow-root > .jupyter_error.log & echo $! > .jupyter_pid

## Stop Jupyter Notebook
stop_jupyter:
	ps aux | grep jupyter
	kill -9 $(cat .jupyter_pid)

## Create a new repository on GitHub and set the remote as upstream
init_github:
	hub create -p ${PROJECT_NAME}
	git push -u origin master

## Initialize git repository and make the fist commit
init_git:
	git init
	git add --all
	git commit -m "initial commit"

## Bind remote repository to the local repository:
bind_github:
	git remote add origin git@github.com:${GITHUB_USERNAME}/${PROJECT_NAME}.git
	git push -u origin master

## Start Google Cloud Instance
start_gcloud:
	gcloud compute instances start $(GCLOUD_INSTANCE_NAME) --zone=${GCLOUD_COMPUTE_ZONE}

## Stop Google Cloud Instance
stop_gcloud:
	gcloud compute instances stop $(GCLOUD_INSTANCE_NAME) --zone=${GCLOUD_COMPUTE_ZONE}

## Connect to Google Cloud Instance
connect_gcloud:
	gcloud compute ssh --zone=${GCLOUD_COMPUTE_ZONE} jupyter@$(GCLOUD_INSTANCE_NAME) -- -L 8080:localhost:8080

## List Google Compute instances
list_gcloud:
	gcloud compute instances list

## Create a bucket on Google Storage
create_gs:
	gsutil mb -l ${GCLOUD_BUCKET_ZONE} gs://$(GCLOUD_BUCKET)/

## Clean up the bucket on Google Storage
cleanup_gs:
	gsutil rm -r gs://$(GCLOUD_BUCKET)/

## Upload Data to Google Storage
sync_data_to_gs:
	gsutil rsync -d -r data gs://$(GCLOUD_BUCKET)/data

## Download Data from Google Storage
sync_data_from_gs:
	gsutil rsync -d -r gs://$(GCLOUD_BUCKET)/data data

## Upload Data to S3
sync_data_to_s3:
ifeq (default,$(PROFILE))
	aws s3 sync data/ s3://$(BUCKET)/data/
else
	aws s3 sync data/ s3://$(BUCKET)/data/ --profile $(PROFILE)
endif

## Download Data from S3
sync_data_from_s3:
ifeq (default,$(PROFILE))
	aws s3 sync s3://$(BUCKET)/data/ data/
else
	aws s3 sync s3://$(BUCKET)/data/ data/ --profile $(PROFILE)
endif

## Set up python interpreter environment
create_env:
ifeq (True,$(HAS_CONDA))
		@echo ">>> Detected conda, creating conda environment."
ifeq (3,$(findstring 3,$(PYTHON_INTERPRETER)))
	conda create --name $(PROJECT_NAME) python=3
else
	conda create --name $(PROJECT_NAME) python=2.7
endif
		@echo ">>> New conda env created. Activate with:\nconda activate $(PROJECT_NAME)"
else
	$(PYTHON_INTERPRETER) -m pip install -q virtualenv virtualenvwrapper
	@echo ">>> Installing virtualenvwrapper if not already intalled.\nMake sure the following lines are in shell startup file\n\
	export WORKON_HOME=$$HOME/.virtualenvs\nexport PROJECT_HOME=$$HOME/Devel\nsource /usr/local/bin/virtualenvwrapper.sh\n"
	@bash -c "source `which virtualenvwrapper.sh`;mkvirtualenv $(PROJECT_NAME) --python=$(PYTHON_INTERPRETER)"
	@echo ">>> New virtualenv created. Activate with:\nworkon $(PROJECT_NAME)"
endif

## Remove python interpreter environment
remove_env:
ifeq (True,$(HAS_CONDA))
	@echo ">>> Detected conda, removing conda environment."
	conda remove --name $(PROJECT_NAME) --all
	@echo ">>> Conda env $(PROJECT_NAME) removed."
else
	@bash -c "rmvirtualenv $(PROJECT_NAME)"
	@echo ">>> Virtualenv $(PROJECT_NAME) removed."
endif

## Test python environment is setup correctly
test_env:
	$(PYTHON_INTERPRETER) test_environment.py

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
		-v indent=19 \
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
