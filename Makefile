# Run commands much faster

LCD=$(shell pwd)
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

# -- Core services --
TARGET_DEPS := core-services-create-vagrant
.PHONY: all-services-init-all
all-services-init-all: ## INIT: All Services: Create and provision all VMs with services
all-services-init-all: $(TARGET_DEPS)

TARGET_DEPS := core-services-destroy-vagrant
.PHONY: core-services-done-all
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
