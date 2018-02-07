# Build tool for Factorio Server Manager

NODE_ENV:=production

#TODO add support for a mac build maybe?
UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
	release := build/factorio-server-manager-linux.zip
else
	release := build/factorio-server-manager-windows.zip
endif

build: $(release)

$(shell mkdir -p build)
build/factorio-server-manager-%.zip: app/bundle.js factorio-server-manager-%
	@echo "Packaging Build - $@"
	@cp -r app/ factorio-server-manager/
	@cp conf.json.example factorio-server-manager/conf.json
	@zip -r $@ factorio-server-manager > /dev/null
	@rm -r factorio-server-manager

app/bundle.js:
	@echo "Building Frontend"
	@cd ui && npm install && npm run build

ensure_gopath:
	@echo Checking '$$GOPATH'
	@if [[ "${PWD}" != *src/factorio-server-manager ]]; then \
		echo You must locate this project in '$$GOPATH/src/factorio-server-manager' && exit 1;\
	fi

factorio-server-manager-linux: godeps ensure_gopath
	@echo "Building Backend - Linux"
	@mkdir -p factorio-server-manager
	@GOOS=linux GOARCH=amd64 go build -o factorio-server-manager/factorio-server-manager ./src

factorio-server-manager-windows: godeps ensure_gopath
	@echo "Building Backend - Windows"
	@mkdir -p factorio-server-manager
	@GOOS=windows GOARCH=386 go build -o factorio-server-manager/factorio-server-manager.exe ./src

godeps:
	@echo "Installing Packages"
	@cat gopkglist | xargs go get

gen_release: build/factorio-server-manager-linux.zip build/factorio-server-manager-windows.zip
	@echo "Done"

clean:
	@echo "Cleaning"
	@rm -r build/
	@rm app/bundle.js
