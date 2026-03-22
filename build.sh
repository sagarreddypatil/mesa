#!/usr/bin/env arch -x86_64 bash

# rm -rf ~/mesa-native
# rm -rf ~/spirv-llvm-translator-21

set -e

export PATH="/usr/local/opt/llvm@21/bin:/usr/local/opt/bison/bin:$PATH"
export SDKROOT=$(xcrun --show-sdk-path)

# cd ~/Documents/SPIRV-LLVM-Translator
# # rm -rf build

# cmake -S . -B build -G Ninja \
#   -DCMAKE_BUILD_TYPE=Release \
#   -DCMAKE_INSTALL_PREFIX="$HOME/spirv-llvm-translator-21" \
#   -DLLVM_DIR="$(/usr/local/bin/brew --prefix llvm@21)/lib/cmake/llvm" \
#   -DCMAKE_PREFIX_PATH="$(/usr/local/bin/brew --prefix llvm@21)"

# cmake --build build
# cmake --install build

cd ~/Documents/mesa
rm -rf build
export LLVM_CONFIG=/usr/local/opt/llvm@21/bin/llvm-config

export PATH="/usr/local/opt/llvm@21/bin:/usr/local/opt/bison/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:$HOME/spirv-llvm-translator-21/lib/pkgconfig"
export LDFLAGS="-L/usr/local/lib"
export CPPFLAGS="-I/usr/local/include"

export PKG_CONFIG_PATH="$HOME/spirv-llvm-translator-21/lib/pkgconfig:$PKG_CONFIG_PATH"
export CMAKE_PREFIX_PATH="$HOME/spirv-llvm-translator-21:$CMAKE_PREFIX_PATH"

source .venv/bin/activate

PREFIX=/opt/wine-gl46
meson setup build --native-file native.ini \
  -Dprefix=$PREFIX \
  -Dbuildtype=release \
  -Dplatforms=macos \
  -Degl-native-platform=surfaceless \
  -Degl=enabled \
  -Dgallium-drivers=zink \
  -Dvulkan-drivers=kosmickrisp \
  -Dgles1=enabled \
  -Dgles2=enabled \
  -Dglx=disabled \
  -Dgbm=disabled \
  -Dmoltenvk-dir=/usr/local/opt/molten-vk

ninja -C build
ninja -C build install

mkdir -p $PREFIX/lib/dri
cd $PREFIX/lib/dri  
ln -sf ../libgallium-26.0.0-devel.dylib zink_dri.so
ln -sf ../libgallium-26.0.0-devel.dylib swrast_dri.so

cp /usr/local/lib/libvulkan.1.dylib $PREFIX/lib/