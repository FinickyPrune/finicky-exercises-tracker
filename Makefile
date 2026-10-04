# Single entry point for humans, Claude agents and CI.
# Override the simulator: make test SIMULATOR="iPhone 18 Pro"

PROJECT      := ExercisesTracker.xcodeproj
SCHEME       := ExercisesTracker
SIMULATOR    ?= iPhone 17
DESTINATION  := platform=iOS Simulator,name=$(SIMULATOR)
DERIVED_DATA := .build/DerivedData

XCODEBUILD := xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
	-destination '$(DESTINATION)' -derivedDataPath $(DERIVED_DATA) -quiet

# SwiftFormat is pinned: Homebrew and the CI runner image ship different versions,
# and their rules disagree. The release binary is downloaded once and checksum-verified.
SWIFTFORMAT_VERSION := 0.63.1
SWIFTFORMAT_SHA256  := 385ef1a263ba28685157b98c5536b9c9105e124518f28b7ef8a2bee4b167eaeb
TOOLS_DIR           := .build/tools
SWIFTFORMAT         := $(TOOLS_DIR)/swiftformat-$(SWIFTFORMAT_VERSION)

.PHONY: bootstrap gen open build test lint format format-check check clean

bootstrap: $(SWIFTFORMAT) ## Install command-line tools
	brew bundle --file=Brewfile

$(SWIFTFORMAT):
	@mkdir -p $(TOOLS_DIR)
	curl -fsSL -o $(TOOLS_DIR)/swiftformat.zip \
		https://github.com/nicklockwood/SwiftFormat/releases/download/$(SWIFTFORMAT_VERSION)/swiftformat.zip
	echo "$(SWIFTFORMAT_SHA256)  $(TOOLS_DIR)/swiftformat.zip" | shasum -a 256 -c -
	unzip -o -q $(TOOLS_DIR)/swiftformat.zip swiftformat -d $(TOOLS_DIR)
	mv $(TOOLS_DIR)/swiftformat $@
	rm $(TOOLS_DIR)/swiftformat.zip

gen: ## Generate the Xcode project from project.yml
	xcodegen generate --quiet

open: gen ## Generate and open in Xcode
	open $(PROJECT)

build: gen ## Build the app for the simulator
	$(XCODEBUILD) build

test: gen ## Run unit tests on the simulator
	$(XCODEBUILD) test

lint: ## SwiftLint, warnings are errors
	swiftlint lint --strict --quiet

format: $(SWIFTFORMAT) ## Format all Swift sources in place
	$(SWIFTFORMAT) .

format-check: $(SWIFTFORMAT) ## Fail if any file is not formatted
	$(SWIFTFORMAT) --lint .

check: lint test ## Dev loop: lint + tests (formatting is checked before PR)

clean:
	rm -rf .build $(PROJECT)
