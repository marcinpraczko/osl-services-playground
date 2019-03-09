#!/usr/bin/env bash

# ==============================================================
# 2019 by Marcin Praczko
#
# Script for running ansible playbook
# This allow export some variables which can't be configured
# via `ansible.cfg` or `Makefile` as quickly as in BASH script.
# ==============================================================

set -e

# -- Global variables --
LCD=$(pwd)
PROJECT_SCRIPT="$(basename $0)"
PROJECT_DIR_GIT_ROOT="$(git rev-parse --show-toplevel)"

# -- Ansible configuration for profile_tasks action callback --
ANSIBLE_ROOT="${PROJECT_DIR_GIT_ROOT}/provisioning/ansible"
export PROFILE_TASKS_SORT_ORDER="none"
export PROFILE_TASKS_TASK_OUTPUT_LIMIT="all"

# -- Functions --
function usage() {
    cat << EOF

Usage: ${PROJECT_SCRIPT} ansible_arguments

Simple script to running ansible-playbooks always in the same way
(Environment variables, different commands such us --list-hosts, etc)

Where:

  ansible_arguments - normal ansible arguments

Example:

  ${PROJECT_SCRIPT} -i inventory/path playbooks/some_playbook.yml

EOF
}

# Run ansible-playbook with arguments (display custom message)
function run_ansible_playbook() {
    local msg="$1"
    shift
    local args="$@"

    echo ""
    echo "[*] Action: ${msg}"
    echo "[*] Run 'ansible-playbook' with args:"
    echo "[+]  ${args}"
	ansible-playbook ${args}
}

# Define what commands should run before real ansible-playbook
# For example: list-hosts list-tags list-tasks, etc
function run_ansible_playbook_pipeline() {
    local args="$@"
    local args_list_hosts="${args} --list-hosts"

    echo "[*] Ansible directory: ${ANSIBLE_ROOT}"
    cd ${ANSIBLE_ROOT}

    run_ansible_playbook "Display hosts details" "${args_list_hosts}"
    run_ansible_playbook "Run playbooks" "${args}"

	cd "${LCD}"
}

# -- MAIN CODE --
if [[ $# == 0 ]]; then
    usage
    exit 2
fi

run_ansible_playbook_pipeline "$@"

exit 0
