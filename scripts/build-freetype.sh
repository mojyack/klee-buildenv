#!/bin/zsh
# build-freetype.sh TARGET CFLAGS

build="${PWD}/build/freetype"
prefix="${PWD}/$1"

#mkdir -p "$build"

CC=clang CFLAGS="$2" meson setup cache/freetype build/freetype \
--prefix="$prefix" \
--libdir="lib" \
--buildtype=release \
-Ddefault_library=static \
-Dbrotli=disabled \
-Dbzip2=disabled \
-Dharfbuzz=disabled \
-Dmmap=disabled \
-Dpng=disabled \
-Dzlib=disabled && \
ninja install -C "$build"
