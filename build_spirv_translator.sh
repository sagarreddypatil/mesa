#!/usr/bin/env arch -x86_64 bash

set -e

is_rosetta=$(sysctl -n sysctl.proc_translated)
if [ "$is_rosetta" -eq 1 ]; then
  echo "Running under Rosetta"
else
  echo "Error: running natively on Apple silicon"
  exit -1
fi

export PATH="/usr/local/opt/llvm@21/bin:/usr/local/opt/bison/bin:$PATH"
export SDKROOT=$(xcrun --show-sdk-path)

cd ~/Documents/SPIRV-LLVM-Translator

cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$HOME/spirv-llvm-translator-21" \
  -DLLVM_DIR="$(/usr/local/bin/brew --prefix llvm@21)/lib/cmake/llvm" \
  -DCMAKE_PREFIX_PATH="$(/usr/local/bin/brew --prefix llvm@21)"

cmake --build build
cmake --install build
