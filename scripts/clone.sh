#!/bin/bash -e

dir=$(pwd)/void-packages

if [ ! -d $dir ] ; then
  git clone --single-branch --branch libluv https://github.com/ram02z/void-packages.git $dir
else
  cd $dir
  git pull
fi
