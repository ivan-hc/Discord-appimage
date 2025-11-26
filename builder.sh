#!/bin/sh

APP=discord

ARCH="x86_64"

# DEPENDENCIES

dependencies="tar"
for d in $dependencies; do
	if ! command -v "$d" 1>/dev/null; then
		echo "ERROR: missing command \"d\", install the above and retry" && exit 1
	fi
done

_appimagetool() {
	if ! command -v appimagetool 1>/dev/null; then
		[ ! -f ./appimagetool ] && curl -#Lo appimagetool https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-"$ARCH".AppImage && chmod a+x ./appimagetool
		./appimagetool "$@"
	else
		appimagetool "$@"
	fi
}

DOWNLOAD_URL=$(curl -I "https://discord.com/api/download?platform=linux&format=tar.gz" 2>/dev/null | grep -Eoi "https.*linux.*tar.gz")
VERSION=$(echo "$DOWNLOAD_URL" | tr '/' '\n' | grep "^[0-9]" | head -1)
[ ! -f "$APP".tar.gz ] && curl -#Lo "$APP".tar.gz "$DOWNLOAD_URL"
mkdir -p "$APP".AppDir || exit 1

# Extract the package
tar fx ./*tar* && mv ./Discord/* "$APP".AppDir/ || exit 1

_appimage_basics() {
	# AppRun
	printf '#!/bin/sh\nHERE="$(dirname "$(readlink -f "${0}")")"\nexec "${HERE}"/Discord "$@"' > ./"$APP".AppDir/AppRun && chmod a+x ./"$APP".AppDir/AppRun
}

_appimage_basics

# CONVERT THE APPDIR TO AN APPIMAGE
ARCH=x86_64 VERSION="$VERSION" _appimagetool -s ./"$APP".AppDir 2>&1
if ! test -f ./*.AppImage; then
	echo "No AppImage available."; exit 1
fi
