.PHONY: help
.SILENT: help
help: ## show make targets
	awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf " \033[36m%-20s\033[0m  %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: install
install: ## install build requisits
	curl --fail --location --output /tmp/saxon.zip 'https://downloads.sourceforge.net/project/saxon/Saxon-HE/9.9/SaxonHE9-9-1-6J.zip'
	unzip -d /tmp/saxon /tmp/saxon.zip

.PHONY: index
index: ## build index listing
	python3 .github/scripts/index.py
	CLASSPATH="$${CLASSPATH}$${CLASSPATH:+:}/tmp/saxon/saxon9he.jar" \
	  java net.sf.saxon.Transform -s:index.xml -xsl:index.xsl -o:index.html

.PHONY: checksums
checksums: ## compute file checksums
	find $${GITHUB_WORKSPACE:-.} -maxdepth 1 -type f -name '*???.???*' \
	  $$(printf " ! -name %s" $$(cat excludes.patterns)) -exec ./.github/scripts/digest.py {} \;

.PHONY: clean
clean: ## delete build artifacts
	rm --force *.md5 *.sha256 index.xml index.html
