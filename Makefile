.PHONY: help
.SILENT: help
help: ## show make targets
	awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf " \033[36m%-20s\033[0m  %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: install
install: ## install build requisits
	pip3 install bs4 lxml

.PHONY: index
index: ## build index listing
	PYTHONPATH="$$PYTHONPATH$${PYTHONPATH:+:}.github/lib" ./.github/scripts/index.py

.PHONY: checksums
checksums: ## compute file checksums
	find $${GITHUB_WORKSPACE:-.} -maxdepth 1 -type f -name '*???.???*' \
	  $$(printf " ! -name %s" $$(cat excludes.patterns)) -exec ./.github/scripts/digest.py {} \;

.PHONY: clean
clean: ## delete build artifacts
	rm --force *.md5 *.sha256 index.xml index.html
