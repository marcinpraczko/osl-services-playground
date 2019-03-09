#!/usr/bin/env bash

# OSL_OLC:SCRIPT | CMD: Tmuxp: load configuration for project: osl-services-playground
PROJECT_ROOT="$(git rev-parse --show-toplevel)" tmuxp load -y main.yml
