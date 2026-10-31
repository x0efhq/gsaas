HUGO ?= $(shell command -v hugo 2>/dev/null || echo $(HOME)/go/bin/hugo)

.PHONY: run build clean update changelog

run: ## local preview at localhost:1313/gsaas/
	$(HUGO) server

build:
	$(HUGO) --minify

clean:
	rm -rf public resources .hugo_build.lock

update: ## bump hugo-book theme
	$(HUGO) mod get -u && $(HUGO) mod tidy

changelog: ## fetch CHANGELOG.md from the private code repo (needs gh auth or GH_TOKEN)
	{ printf -- '---\ntitle: Changelog\nweight: 110\n---\n\n'; \
	  gh api -H 'Accept: application/vnd.github.raw' repos/x0efhq/gsaas-template/contents/CHANGELOG.md; \
	} > content/docs/changelog.md.tmp && mv content/docs/changelog.md.tmp content/docs/changelog.md
