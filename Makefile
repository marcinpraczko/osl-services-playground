# Run commands much faster

LCD=$(shell pwd)
PROJECT_ROOT=$(shell git rev-parse --show-toplevel)
ANSIBLE_ROOT=provisioning/ansible
VAGRANT_FOR_CORE_SERVICES=infrastructure/vagrant/core

# Settings for colourful output
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
CYAN=$(shell tput setaf 6)
NC=$(shell tput sgr0)

.PHONY: help
help: ## HELP: None: Show this help message
	@echo 'usage: make [target] ...'
	@echo
	@echo 'Targets:'
	@echo '========'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# -- Helpers --
.PHONY: help-deps-info
help-deps-info: ## HELP: None: Display details about dependency of configuration
help-deps-info:
	$(MAKE) -f Makefile.deps-info

# -- Core services --
TARGET_DEPS := core-services-create-vagrant
.PHONY: all-services-init
all-services-init-all: ## INIT: All Services: Create and provision all VMs with services
all-services-init-all: $(TARGET_DEPS)

TARGET_DEPS := core-services-destroy-vagrant
.PHONY: all-services-done
all-services-done-all: ## DONE: All Services: Destroy all VMs and stacks (All data will be lost)
all-services-done-all: $(TARGET_DEPS)

.PHONY: core-services-status-vagrant
core-services-status-vagrant: ## VAGRANT: Core Services: Status for VMs
	@echo "Starting vagrant: Core Services"
	cd $(VAGRANT_FOR_CORE_SERVICES) && vagrant status

.PHONY: core-services-create-vagrant
core-services-create-vagrant: ## VAGRANT: Core Services: Create VMs
	@echo "Starting vagrant: Core Services"
	cd $(VAGRANT_FOR_CORE_SERVICES) && vagrant up

.PHONY: core-services-destroy-vagrant
core-services-destroy-vagrant: ## VAGRANT: Core Services: Destroy VMs
	@echo "Destroing vagrant: Core Services"
	cd $(VAGRANT_FOR_CORE_SERVICES) && vagrant destroy -f

.PHONY: core-services-halt-vagrant
core-services-halt-vagrant: ## VAGRANT: Core Services: Stop VMs
	@echo "Destroing vagrant: Core Services"
	cd $(VAGRANT_FOR_CORE_SERVICES) && vagrant halt

TARGET_DEPS := core-services-destroy-vagrant
TARGET_DEPS += core-services-create-vagrant
.PHONY: core-services-recreate-vagrant
core-services-recreate-vagrant: ## VAGRANT: Core Services: Recreate VMs (destroy / create)
core-services-recreate-vagrant: $(TARGET_DEPS)

# --- Ansible ---
TARGET_DEPS := ansible-generate-inventories
.PHONY: ansible-ping-core-services
ansible-ping-core-services: ## ANSIBLE: Core Services: Use ansible to ping VMs
ansible-ping-core-services: $(TARGET_DEPS)
	cd $(ANSIBLE_ROOT) && \
		ansible-playbook -i inventories/vagrant/ playbooks/ping_all_hosts.yml --list-hosts
	cd $(ANSIBLE_ROOT) && \
		ansible-playbook -i inventories/vagrant/ playbooks/ping_all_hosts.yml

TARGET_DEPS := ansible-generate-inventories
.PHONY: ansible-provision-core-services
ansible-provision-core-services: ## ANSIBLE: Core Services: Use ansible to provision VMs
ansible-provision-core-services: $(TARGET_DEPS)
	cd $(ANSIBLE_ROOT) && \
		ansible-playbook -i inventories/vagrant/ playbooks/configure_full_stack.yml --list-hosts
	cd $(ANSIBLE_ROOT) && \
		ansible-playbook -i inventories/vagrant/ playbooks/configure_full_stack.yml

# TODO: Migrate this to seperate script
.PHONY: ansible-generate-inventories
ansible-generate-inventories: ## ANSIBLE: Core Services: Generate ansible inventory from Vagrant
	@echo "Generate Vagrant Inventory for ansible..."
	cd $(VAGRANT_FOR_CORE_SERVICES) && $(PROJECT_ROOT)/scripts/ansible-vagrant-update-hosts.sh
	cd $(VAGRANT_FOR_CORE_SERVICES) && \
		mv -vf hosts_vagrant $(PROJECT_ROOT)/provisioning/ansible/inventories/vagrant/hosts
	cd $(ANSIBLE_ROOT) && cat inventories/vagrant/inventory.txt >> inventories/vagrant/hosts
	@echo "== Inventories / Vagrant hosts =="
	cd $(ANSIBLE_ROOT) && ansible-inventory -i inventories/vagrant/ --list -y
	@echo ""

# TODO: Migrate this to seperate script
.PHONY: ansible-update-galaxy-roles
ansible-update-galaxy-roles: ## ANSIBLE: All Services: Update all galaxy roles
	@echo "Updating roles from Ansible-Galaxy..."
	cd $(ANSIBLE_ROOT) && rm -Rf roles-galaxy/marcinpraczko.named
	cd $(ANSIBLE_ROOT) && ansible-galaxy install -p roles-galaxy -r requirements.yml
