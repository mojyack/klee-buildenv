SHELL = /bin/zsh
NEWLIB_SRC = "ftp://sourceware.org/pub/newlib/newlib-4.2.0.20211231.tar.gz"
FREETYPE_SRC="https://download.savannah.gnu.org/releases/freetype/freetype-2.12.1.tar.xz"
LLVM_VERSION=15.0.6
TARGET = x86_64-elf
COMMON_FLAGS = -I/usr/lib/clang/${LLVM_VERSION}/include -nostdlibinc -O3 -march=x86-64-v2 -mlong-double-64# -D__ELF__ -D_POSIX_TIMERS

.PHONY: all

all: ${TARGET}/lib/libc.a ${TARGET}/lib/libc++.a ${TARGET}/libfreetype.a

cache/newlib.tar.gz:
	mkdir -p cache
	curl -o $@ "${NEWLIB_SRC}"

cache/.newlib: cache/newlib.tar.gz
	tar xf $^ -C cache
	mv cache/newlib-* cache/newlib
	touch $@

build/newlib/cross:
	mkdir -p $@
	for e (/usr/bin/x86_64-pc-linux-gnu*) { ln -s $$e "$@/$${$$(basename $$e)//pc-linux-gnu/elf}" }

${TARGET}/lib/libc.a: build/newlib/cross cache/.newlib
	cd build/newlib; \
	../../cache/newlib/configure --target ${TARGET} CC_FOR_TARGET=clang CFLAGS_FOR_TARGET="${COMMON_FLAGS}" --disable-multilib --disable-newlib-multithread --prefix="" --exec-prefix=""; \
	PATH="$$PATH:$${PWD}/cross"; ${MAKE}; ${MAKE} DESTDIR="$${PWD}"/../.. install

cache/llvm:
	git clone --depth 1 --branch llvmorg-${LLVM_VERSION} https://github.com/llvm/llvm-project.git cache/llvm
	#patch -p1 -d cache/llvm < files/llvm${LLVM_VERSION}-newlib.patch

${TARGET}/lib/libc++.a: cache/llvm ${TARGET}/lib/libc.a
	scripts/build-libcxx.sh ${TARGET} "${COMMON_FLAGS} -I$(abspath ${TARGET}/include) -U__linux__ -D_GNU_SOURCE -D_XOPEN_SOURCE=700"

cache/freetype.tar.xz:
	mkdir -p cache
	curl -L -o $@ "${FREETYPE_SRC}"

cache/.freetype: cache/freetype.tar.xz
	xz -dc $^ | tar xf - -C cache
	mv cache/freetype-* cache/freetype
	touch $@

${TARGET}/libfreetype.a: cache/.freetype ${TARGET}/lib/libc.a
	scripts/build-freetype.sh ${TARGET} "${COMMON_FLAGS} -I$(abspath ${TARGET}/include)"
