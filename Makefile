appname ?= NoVNC Connect
prefix ?= ~/Applications/$(appname).app
bindir ?= $(prefix)/Contents/MacOS
infodir ?= $(prefix)/Contents
rsrcdir ?= $(prefix)/Contents/Resources

buildconf ?= release
builddir := $(shell swift build --configuration $(buildconf) --show-bin-path)

build:
	swift build -c $(buildconf)

install: build
	install -d "$(bindir)"
	install -m 0755 "$(builddir)/novnc-connect" "$(bindir)"
	install -m 0644 "Info.plist" "$(infodir)"

uninstall:
	rm -f "$(bindir)/novnc-connect"
	rm -f "$(infodir)/Info.plist"

clean:
	rm -rf .build
	rm -rf Build

app: build
	install -d Build
	$(MAKE) install prefix="Build/$(appname).app"

.PHONY: build install uninstall clean

