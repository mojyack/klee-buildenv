#!/bin/zsh
# build-libcxx.sh TARGET CFLAGS

build="${PWD}/build/libcxxabi"
prefix="${PWD}/$1"

mkdir -p "$build"
cd cache/llvm
cmake -G Ninja -S runtimes -B "$build" -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" \
-DCMAKE_INSTALL_PREFIX="$prefix" \
-DCMAKE_C_COMPILER=clang \
-DCMAKE_C_FLAGS="$2" \
-DCMAKE_CXX_COMPILER=clang++ \
-DCMAKE_CXX_FLAGS="$2" \
-DCMAKE_CXX_COMPILER_TARGET=$1 \
-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
-DCMAKE_BUILD_TYPE=Release \
-DLIBCXXABI_LIBCXX_INCLUDES="libcxx/include" \
-DLIBCXXABI_ENABLE_EXCEPTIONS=False \
-DLIBCXXABI_ENABLE_THREADS=False \
-DLIBCXXABI_ENABLE_SHARED=False \
-DLIBCXXABI_ENABLE_STATIC=True \
-DLIBCXX_CXX_ABI=libcxxabi \
-DLIBCXX_CXX_ABI_INCLUDE_PATHS="libcxxabi/include" \
-DLIBCXX_ENABLE_EXCEPTIONS=False \
-DLIBCXX_ENABLE_FILESYSTEM=False \
-DLIBCXX_ENABLE_MONOTONIC_CLOCK=False \
-DLIBCXX_ENABLE_RTTI=False \
-DLIBCXX_ENABLE_THREADS=False \
-DLIBCXX_ENABLE_SHARED=False \
-DLIBCXX_ENABLE_STATIC=True

ninja install -C "$build" cxx cxxabi
