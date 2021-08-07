#!/bin/bash

./void-packages/xbps-src -m $dir/masterdir-musl binary-bootstrap x86_64-musl
ls -la void-packages/masterdir-musl
# $dir/xbps-src -m $dir/masterdir-musl pkg neovim-nightly
