#!/bin/bash

MODELS_DIR="../../data/projects/{{ cookiecutter.project_name }}/models"

if [ ! -d $MODELS_DIR ]; then
    echo "Creating an models directory.\n"
    mkdir -p $MODELS_DIR
else
    echo "models directory [$MODELS_DIR] already exists.\n"
fi

LINK_FILE="models"

if [ -L $LINK_FILE ]; then
    echo "Symbolic link [$LINK_FILE] exists already.\n"
else
    echo "Making symbolic link [$LINK_FILE] to [$MODELS_DIR].\n"
    ln -s $MODELS_DIR $LINK_FILE 
fi

