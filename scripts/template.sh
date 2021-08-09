#!/bin/bash -e

dir=$(pwd)/void-packages
mkdir -p $dir/srcpkgs/neovim-nightly
ndir=$dir/srcpkgs/neovim-nightly
# mkdir -p $dir/tmp
# tmp=$dir/tmp

# curl \
#   -H "Accept: application/vnd.github.v3+json" \
#   -s -o $tmp/release.json \
#   https://api.github.com/repos/neovim/neovim/releases/tags/nightly
# version=$(jq -r '.name' $tmp/release.json | sed 's/[^ ]* //')
# version=${version##*-}
# url=$(jq -r '.tarball_url' $tmp/release.json)
# long_commit=$(jq -r '.target_commitish' $tmp/release.json)

# echo "version: $version"
# echo "url: $url" echo "long_commit: $url"

# builddir=$tmp/build
# tarfile=$builddir/nvim-$version.tar.gz
# mkdir -p $builddir
# echo "tarfile: $tarfile"

# wget $url -O $tarfile
# sha=$(sha256sum $tarfile | awk '{print $1;}')
# tar xfz $tarfile -C $builddir
# wrksrc=$(ls $builddir | grep -v '\.')

# echo "sha: $sha"
# echo "wrksrc: $wrksrc"

cat << EOF > $ndir/template
# template file for 'neovim-nightly'
pkgname=neovim-nightly
version=0.6.0
revision=1
wrksrc="neovim-nightly"
build_style=cmake
build_helper="qemu"
configure_args="-dcmake_build_type=relwithdebinfo"
hostmakedepends="pkg-config gettext gperf luajit lua51-lpeg lua51-mpack"
makedepends="libtermkey-devel libuv-devel libvterm-devel msgpack-devel
 luajit-devel libluv-devel tree-sitter-devel"
depends="libvterm>=0.1.0"
short_desc="fork of vim aiming to improve user experience, plugins and guis"
maintainer="omar zeghouani <omarzeghouani@gmail.com>"
license="apache-2.0, custom:vim"
homepage="https://neovim.io"
distfiles="https://github.com/neovim/neovim/archive/nightly.tar.gz"
checksum=e64c87dd660d6a0ad5c0798e4c0e5ca2433f4b99450458e0a4c3cd3c283a913f
alternatives="
 vi:vi:/usr/bin/nvim
 vi:vi.1:/usr/share/man/man1/nvim.1
 vi:view:/usr/bin/nvim
 vi:view.1:/usr/share/man/man1/nvim.1
 vim:vim:/usr/bin/nvim
 vim:vim.1:/usr/share/man/man1/nvim.1"
pre_configure() {
	vsed -i runtime/cmakelists.txt \
		-e "s|\".*/bin/nvim|\${cmake_crosscompiling_emulator} &|g"
}
post_install() {
	vlicense license
}
EOF
