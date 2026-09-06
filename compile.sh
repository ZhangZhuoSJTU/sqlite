#!/bin/bash
# ProgramBench-style build: must produce ./executable at the repo root.
set -e
cd "$(dirname "$0")"
./configure
make sqlite3
cp sqlite3 executable
# Build the loadable extensions the test suite `.load`s at runtime (func4 uses
# totype, spellfix/nextchar tests use theirs). The benchmark eval pre-built these
# as .so in the workspace; on macOS the tests `.load <path>/<name>` and sqlite
# appends .dylib, so build them here. test.sh copies them into each run dir.
# Tests load these two ways: `.load <path>/<name>` (sqlite appends .dylib) and
# `.load <path>/<name>.so` (sqlite appends .dylib -> <name>.so.dylib). Provide
# both filenames so either form resolves on macOS.
for e in totype spellfix nextchar; do
    cc -O2 -fPIC -dynamiclib -I. -Isrc "ext/misc/$e.c" -o "$e.dylib"
    cp "$e.dylib" "$e.so.dylib"
done
