#!/usr/bin/env arch -x86_64 bash

set -e

is_rosetta=$(sysctl -n sysctl.proc_translated)
if [ "$is_rosetta" -eq 1 ]; then
  echo "Running under Rosetta"
else
  echo "Error: running natively on Apple silicon"
  exit -1
fi

export SDKROOT=$(xcrun --show-sdk-path)
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
  -Ddefault_library=static \
  -Dprefer_static=true \
  -Dshared-llvm=disabled \
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

sudo rm -f $PREFIX/lib/libvulkan.1.dylib
sudo rm -f $PREFIX/lib/libzstd.1.dylib

cp /usr/local/lib/libvulkan.1.dylib $PREFIX/lib/
cp /usr/local/lib/libzstd.1.dylib $PREFIX/lib/
