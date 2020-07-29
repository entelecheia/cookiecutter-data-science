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

## Run Byobu (terminal multiplexer, F6 - Detach from session) 
byobu:
	@echo ">>> Byobu installation command is given below:\n   sudo apt install byobu"
	byobu

## Set up python interpreter environment
nvset:
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
nvrmv:
ifeq (True,$(HAS_CONDA))
	@echo ">>> Detected conda, removing conda environment."
	conda remove --name $(PROJECT_NAME) --all
	@echo ">>> Conda env $(PROJECT_NAME) removed."
else
	@bash -c "rmvirtualenv $(PROJECT_NAME)"
	@echo ">>> Virtualenv $(PROJECT_NAME) removed."
endif

## Export python interpreter environment
nvexp:
ifeq (True,$(HAS_CONDA))
	@echo ">>> Detected conda, exporting conda environment."
	conda env export --name $(PROJECT_NAME) --file environment.yml
	@echo ">>> Conda env $(PROJECT_NAME) exported."
endif

## Update python interpreter environment
nvupd:
ifeq (True,$(HAS_CONDA))
	@echo ">>> Detected conda, updating conda environment."
	conda env update --name $(PROJECT_NAME) --file environment.yml --prune
	@echo ">>> Conda env $(PROJECT_NAME) updated."
endif

## Test python environment is setup correctly
nvtest:
	$(PYTHON_INTERPRETER) test_environment.py

## Install Python Dependencies
pyrq: nvtest
	# $(PYTHON_INTERPRETER) -m pip install -U pip setuptools wheel
	$(PYTHON_INTERPRETER) -m pip install -r requirements.txt

## Make Dataset
data: nvtest
	# $(PYTHON_INTERPRETER) src/data/make_dataset.py data/raw data/processed
	sh main/data/make_dataset.sh

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using flake8
lint:
	flake8 src

## Add Virtual Environment to Jupyter Notebook
jadd:
	pip install --user ipykernel
	python -m ipykernel install --user --name=$(PROJECT_NAME)

## Launch Jupyter Notebook
jon:
	@echo "nohup jupyter notebook --no-browser --port=8080 --allow-root > .jupyter_error.log &"
	@bash -c "nohup jupyter notebook --no-browser --port=8080 --allow-root > .jupyter_error_$(shell hostname).log &"

## Stop Jupyter Notebook
joff:
	ps aux | grep jupyter
	@echo "kill -9 #jupyter_pid"
	
## Initialize direnv
direnv:
	@echo ">>> Install direnv if not already intalled.\n	Ubuntu: sudo apt-get install direnv\n	Mac: brew install direnv\n"
	direnv allow .

## Create a new repository on GitHub and set the remote as upstream
ghnew:
	hub create -p ${PROJECT_NAME}
	git push -u origin master

## Initialize git repository and make the fist commit
git1:
	git init
	git add --all
	git commit -m "Make the first commit"

## Bind remote repository to the local repository:
ghbind:
	git remote add origin git@github.com:${GITHUB_USERNAME}/${PROJECT_NAME}.git
	git push -u origin master

## Start Google Cloud Instance
gcon:
	gcloud compute instances start $(GCLOUD_INSTANCE_NAME) --zone=${GCLOUD_COMPUTE_ZONE}

## Stop Google Cloud Instance
gcoff:
	gcloud compute instances stop $(GCLOUD_INSTANCE_NAME) --zone=${GCLOUD_COMPUTE_ZONE}

## Connect to Google Cloud Instance
gcssh:
	gcloud compute ssh --zone=${GCLOUD_COMPUTE_ZONE} jupyter@$(GCLOUD_INSTANCE_NAME) -- -L 8080:localhost:8080

## List Google Compute instances
gcls:
	gcloud compute instances list
	
## Create a bucket on Google Storage
gsmb:
	gsutil mb -l ${GCLOUD_BUCKET_ZONE} gs://$(GCLOUD_BUCKET)/

## Clean up the bucket on Google Storage
gsrm:
	gsutil rm -r gs://$(GCLOUD_BUCKET)/

## Upload Data to Google Storage
gsup:
	gsutil rsync -d -r data gs://$(GCLOUD_BUCKET)/data

## Download Data from Google Storage
gsdn:
	gsutil rsync -d -r gs://$(GCLOUD_BUCKET)/data data

## Upload Data to S3
s3up:
ifeq (default,$(PROFILE))
	aws s3 sync data/ s3://$(BUCKET)/data/
else
	aws s3 sync data/ s3://$(BUCKET)/data/ --profile $(PROFILE)
endif

## Download Data from S3
s3dn:
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
		-v indent=10 \
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
