CLI_NAME := eli
APP_NAME := elcp
BUILD_VERSION := 0.1.0
BASEPATH := $(shell pwd)
REVISION := $(shell git rev-parse --short HEAD)
BRANCH := $(shell git rev-parse --abbrev-ref HEAD | tr -d '\040\011\012\015\n')
BUILD_PATH = $(BASEPATH)/target/release
DEBUG_PATH = $(BASEPATH)/target/debug

PACKAGE := github.com/riipandi/elisacp/cmd/eli

LDFLAG_INFO = \
  -X $(PACKAGE).commit=$(REVISION) \
  -X $(PACKAGE).version=$(BUILD_VERSION)

BUILD_CMD = go build -ldflags "-s -w $(LDFLAG_INFO)"
BUILD_ENV = GOOS=linux GOARCH=amd64

all: clean build_cli build_elcp compile

compile: compile_cli compile_elcp

release:
	@goreleaser release

pre_release:
	@goreleaser --snapshot --skip-publish --rm-dist

clean:
	@rm -fr cmd/elcp/static/public/*
	@touch cmd/elcp/static/public/.gitkeep
	@rm -fr $(BASEPATH)/target/*

# ------------------------------------------------------------------------------
# ElisaCP cli app
# ------------------------------------------------------------------------------
build_cli:
	@cd cmd/eli && $(BUILD_CMD) -i -o $(DEBUG_PATH)/$(CLI_NAME)
	@cd cmd/eli && go install
	@echo "Elisa CLI (dev) has been compiled and installed."

compile_cli:
	@cd cmd/eli && $(BUILD_ENV) $(BUILD_CMD) -i -o $(BUILD_PATH)/$(CLI_NAME)-$(REVISION)-x64
	@ls -lh $(BUILD_PATH) && echo "Elisa CLI compiled with production environment."

# --------------------------------------------------------------------------------
# ElisaCP control panel
# --------------------------------------------------------------------------------
build_elcp: build_frontend
	@cd cmd/elcp && $(BUILD_CMD) -i -o $(DEBUG_PATH)/$(APP_NAME)
	@cd cmd/elcp && go install
	@echo "ElisaCP (dev) has been compiled and installed."

build_frontend: clean
	@cd web ; npm install --silent && npm run build
	@cp assets/favicon.* cmd/elcp/static/public/.
	@cp -r web/dist/* cmd/elcp/static/public/.

compile_elcp:
	@cd cmd/elcp && $(BUILD_ENV) $(BUILD_CMD) -i -o $(BUILD_PATH)/$(APP_NAME)-$(REVISION)-x64
	@ls -lh $(BUILD_PATH) && echo "ElisaCP compiled with production environment."

runweb:
	@cd web && npm install --silent && npm run dev

runapi:
	@air -c cmd/elcp/.air.conf

rundev: build_frontend runapi

# --------------------------------------------------------------------------------
# ElisaCP website
# --------------------------------------------------------------------------------
build_website:
	@cd website && npm install --silent && npm run build

runsite:
	@cd website && npm run dev
