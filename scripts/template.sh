#!/bin/bash -e

dir=$(pwd)/void-packages
mkdir -p $dir/srcpkgs/neovim-nightly
ndir=$dir/srcpkgs/neovim-nightly
mkdir -p $dir/tmp
tmp=$dir/tmp

case "$ARCH" in
    *musl* ) LIBC="musl" ;;
    * ) LIBC="glibc" ;;
esac

# NOTE: xbps-query doesn't seem to want to work
curl \
  -f -o $tmp/index.html \
  https://ram02z.github.io/neovim-nightly/$LIBC/index.html

oldpkg=$(xmllint --html --xpath "//html/body/pre/a[2]" $tmp/index.html | cut -d">" -f2 | cut -d "<" -f1)
oldversion=${oldpkg%%.*}
oldversion=${oldversion##*-}

curl \
  -H "Accept: application/vnd.github.v3+json" \
  -s -o $tmp/release.json \
  https://api.github.com/repos/neovim/neovim/git/ref/tags/nightly
if [ "$(jq -r '.message' $tmp/release.json)" = "Not Found" ]; then
  echo "Nightly tag removed?"
  exit 1
fi
version=$(jq -r '.object.sha' $tmp/release.json)
version="g${version:0:9}"
# This might fail if no release, might need to change the template logic
url="https://api.github.com/repos/neovim/neovim/tarball/nightly"

echo "old version: $oldversion"
echo "new version: ${version}_1"
echo "url: $url"

cmpver=$(xbps-uhelper cmpver "$oldversion" "${version}_1")
cmpver=$?

if [ "$cmpver" -eq 0 ]; then
    echo "Same version. Canceling build."
    exit 2
fi

if [ "$cmpver" -eq 255 ]; then
    echo "No revert."
    oldversion=""
fi

builddir=$tmp/build
tarfile=$builddir/neovim-nightly-$version.tar.gz
mkdir -p $builddir
echo "tarfile: $tarfile"

wget $url -O $tarfile
sha=$(sha256sum $tarfile | awk '{print $1;}')
tar xfz $tarfile -C $builddir
wrksrc=$(ls $builddir | grep -v '\.')

echo "sha: $sha"
echo "wrksrc: $wrksrc"

cat << EOF > $ndir/template
# Template file for 'neovim-nightly', the nightly build of 'neovim'
pkgname=neovim-nightly
reverts="$oldversion"
version="$version"
revision=1
build_style=cmake
build_helper="qemu"
configure_args="-DCMAKE_BUILD_TYPE=RelWithDebInfo"
hostmakedepends="pkg-config gettext gperf LuaJIT lua51-lpeg lua51-mpack"
makedepends="libtermkey-devel libuv-devel libvterm-devel msgpack-devel LuaJIT-devel
 libluv-devel tree-sitter-devel"
depends="libvterm>=0.1.0"
short_desc="Fork of Vim aiming to improve user experience, plugins and GUIs. Nightly version"
maintainer="Omar Zeghouani <omarzeghouanii@gmail.com>"
license="Apache-2.0, custom:Vim"
homepage="https://neovim.io"
distfiles="$url>neovim-nightly-$version.tar.gz"
checksum=$sha
wrksrc=$wrksrc
alternatives="
 vi:vi:/usr/bin/nvim
 vi:vi.1:/usr/share/man/man1/nvim.1
 vi:view:/usr/bin/nvim
 vi:view.1:/usr/share/man/man1/nvim.1
 vim:vim:/usr/bin/nvim
 vim:vim.1:/usr/share/man/man1/nvim.1"
pre_configure() {
	vsed -i runtime/CMakeLists.txt \
		-e "s|\".*/bin/nvim|\${CMAKE_CROSSCOMPILING_EMULATOR} &|g"
}
post_install() {
	vlicense LICENSE
}
EOF
