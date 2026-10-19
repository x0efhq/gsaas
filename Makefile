HUGO ?= $(shell command -v hugo 2>/dev/null || echo $(HOME)/go/bin/hugo)

.PHONY: run build clean update

run: ## local preview at localhost:1313/gsaas/
	$(HUGO) server

build:
	$(HUGO) --minify

clean:
	rm -rf public resources .hugo_build.lock

update: ## bump hugo-book theme
	$(HUGO) mod get -u && $(HUGO) mod tidy
