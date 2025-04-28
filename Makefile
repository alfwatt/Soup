define USAGE
echo "$0 "
endef

XCODE_APP := /Applications/XCode.app
XCODE_PROJECT := Soup.xcodeproj
XCODE_TARGET := Soup

XCODE_BUILD := /usr/local/xcodebuild

DOCS_DIR := docs

.PHONY: build
build: $(XCODE_BUILD)

.PHONY: test
test:

.PHONY: pack
pack: #

.PHONY: headerdoc
headerdoc:
	find . -type f -name '*.h' | xargs headerdoc2html -o $(DOCS_DIR)
	gatherheaderdoc $(DOCS_DIR)
	[ -x `which lowdown` ] && lowdown -so $(DOCS_DIR)/index.html Readme.md & open $(DOCS_DIR)/index.html

$(XCODE_APP):
	if [ ! -x $(XCODE_APP) ]; then
		echo "Pleas Install $XCODE_APP (from the App Store)" && false
	elseif
		true
	fi

$(XCODE_BUILD): $(XCODE_APP)
	if [ ! -x $(XCODE_BUILD) ]; then
		echo "Please Install $XCODE_BUILD (from XCode Command Line Tools)" && false
	elsif
		true
	fi
