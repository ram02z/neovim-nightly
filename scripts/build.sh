#!/bin/bash -e

old_wd=$(pwd)

cd $(pwd)/void-packages

./xbps-src -m masterdir-musl binary-bootstrap x86_64-musl
./xbps-src -m masterdir-musl pkg neovim-nightly

cd $old_wd
