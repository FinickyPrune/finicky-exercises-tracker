# Single entry point for humans, Claude agents and CI.
# Override the simulator: make test SIMULATOR="iPhone 18 Pro"

PROJECT      := ExercisesTracker.xcodeproj
SCHEME       := ExercisesTracker
SIMULATOR    ?= iPhone 17
DESTINATION  := platform=iOS Simulator,name=$(SIMULATOR)
DERIVED_DATA := .build/DerivedData

XCODEBUILD := xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
	-destination '$(DESTINATION)' -derivedDataPath $(DERIVED_DATA) -quiet

.PHONY: bootstrap gen open build test lint format format-check check clean

bootstrap: ## Install command-line tools
	brew bundle --file=Brewfile

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

format: ## Format all Swift sources in place
	swiftformat .

format-check: ## Fail if any file is not formatted
	swiftformat --lint .

check: lint test ## Dev loop: lint + tests (formatting is checked before PR)

clean:
	rm -rf .build $(PROJECT)
