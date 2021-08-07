#!/bin/bash

cd void-packages
ls -la
./xbps-src -m masterdir-musl binary-bootstrap x86_64-musl

# $dir/xbps-src -m $dir/masterdir-musl pkg neovim-nightly
