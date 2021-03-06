appname ?= NoVNC Connect
prefix ?= ~/Applications/$(appname).app
bindir ?= $(prefix)/Contents/MacOS
infodir ?= $(prefix)/Contents
rsrcdir ?= $(prefix)/Contents/Resources
versionnumber ?= 1.0.0
versioncode ?= 1

buildconf ?= release
builddir := $(shell swift build --configuration $(buildconf) --show-bin-path)

build:
	swift build --configuration $(buildconf) --static-swift-stdlib

install: build
	install -d "$(bindir)"
	install -m 0755 "$(builddir)/novnc-connect" "$(bindir)"
	install -m 0644 "Info.plist" "$(infodir)"
	/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $(versionnumber)" "$(infodir)/Info.plist"
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $(versioncode)" "$(infodir)/Info.plist"

uninstall:
	rm -f "$(bindir)/novnc-connect"
	rm -f "$(infodir)/Info.plist"

clean:
	rm -rf .build
	rm -rf Build

app: build
	install -d Build/app
	$(MAKE) install prefix="Build/app/$(appname).app"

dmg: app
	install -d Build/dmg
	hdiutil create -srcfolder Build/app -volname "$(appname) $(versionnumber)" "Build/dmg/$(appname) $(versionnumber).dmg"
	cd Build/dmg && md5 "$(appname)"*.dmg > md5sum.txt
	cd Build/dmg && shasum -a 1 "$(appname)"*.dmg > sha1sum.txt
	cd Build/dmg && shasum -a 256 "$(appname)"*.dmg > sha256sum.txt

.PHONY: build install uninstall clean app dmg
