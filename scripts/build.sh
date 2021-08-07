#!/bin/bash

sudo cd packages
./xbps-src -m masterdir-musl binary-bootstrap x86_64-musl

# $dir/xbps-src -m $dir/masterdir-musl pkg neovim-nightly
