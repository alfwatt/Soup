
XCODE_PROJECT := IcedHTTP.xcodeproj
XCODE_TARGET := IcedHTTP

DOCS_DIR := docs

.PHONY: headerdoc
headerdoc:
	find . -type f -name '*.h' | xargs headerdoc2html -o $(DOCS_DIR)
	gatherheaderdoc $(DOCS_DIR)
	if [ -x `which lowdown` ]; then lowdown -so $(DOCS_DIR)/index.html Readme.md & open $(DOCS_DIR)/index.html
