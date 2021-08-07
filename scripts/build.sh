#!/bin/bash

dir=$(pwd)/void-packages

./$dir/xbps-src -m $dir/masterdir-musl binary-bootstrap x86_64-musl
ls -la $dir/masterdir-musl
# $dir/xbps-src -m $dir/masterdir-musl pkg neovim-nightly
