#!/bin/bash

#https://stackoverflow.com/questions/1226949/biginteger-on-objective-c

TOMMATH_VERSION="0.42.0"


# Setup paths to stuff we need

DEVELOPER="/Applications/Xcode.app/Contents/Developer"

SDK_VERSION="10.2"
MIN_VERSION="10.0"

IPHONEOS_PLATFORM="${DEVELOPER}/Platforms/iPhoneOS.platform"
IPHONEOS_SDK="${IPHONEOS_PLATFORM}/Developer/SDKs/iPhoneOS${SDK_VERSION}.sdk"
IPHONEOS_GCC="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"

IPHONESIMULATOR_PLATFORM="${DEVELOPER}/Platforms/iPhoneSimulator.platform"
IPHONESIMULATOR_SDK="${IPHONESIMULATOR_PLATFORM}/Developer/SDKs/iPhoneSimulator${SDK_VERSION}.sdk"
IPHONESIMULATOR_GCC="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"

# Make sure things actually exist

if [ ! -d "$IPHONEOS_PLATFORM" ]; then
  echo "Cannot find $IPHONEOS_PLATFORM"
  exit 1
fi

if [ ! -d "$IPHONEOS_SDK" ]; then
  echo "Cannot find $IPHONEOS_SDK"
  exit 1
fi

if [ ! -x "$IPHONEOS_GCC" ]; then
  echo "Cannot find $IPHONEOS_GCC"
  exit 1
fi

if [ ! -d "$IPHONESIMULATOR_PLATFORM" ]; then
  echo "Cannot find $IPHONESIMULATOR_PLATFORM"
  exit 1
fi

if [ ! -d "$IPHONESIMULATOR_SDK" ]; then
  echo "Cannot find $IPHONESIMULATOR_SDK"
  exit 1
fi

if [ ! -x "$IPHONESIMULATOR_GCC" ]; then
  echo "Cannot find $IPHONESIMULATOR_GCC"
  exit 1
fi

buildMath()
{
  export ARCH=$1
  export CC="$2 -miphoneos-version-min=${MIN_VERSION}"
  export SDK=$3
  export CFLAGS="-arch ${ARCH} -isysroot ${SDK} -arch ${ARCH} $4"
  export LDFLAGS="-arch ${ARCH}"
  #rm -rf "libtommath-${TOMMATH_VERSION}"
  #tar xf "ltm-${TOMMATH_VERSION}.tar.bz2"

  #pushd .
  #cd "libtommath-${TOMMATH_VERSION}"
  make -j5 | tee "/tmp/libtommath-${TOMMATH_VERSION}-${ARCH}.build-log"
  make INSTALL_USER=`id -un` INSTALL_GROUP=`id -gn` "LIBPATH=/tmp/libtommath-${TOMMATH_VERSION}-${ARCH}/lib" "INCPATH=/tmp/libtommath-${TOMMATH_VERSION}-${ARCH}/include" "DATAPATH=/tmp/libtommath-${TOMMATH_VERSION}-${ARCH}/docs" NODOCS=1 install | tee "/tmp/libtommath-${TOMMATH_VERSION}-${ARCH}.install-log"
  #popd
  #rm -rf "libtommath-${TOMMATH_VERSION}"
}

buildMath "arm64" "${IPHONEOS_GCC}" "${IPHONEOS_SDK}" ""
#buildMath "i386" "${IPHONESIMULATOR_GCC}" "${IPHONESIMULATOR_SDK}" ""
#buildMath "x86_64" "${IPHONESIMULATOR_GCC}" "${IPHONESIMULATOR_SDK}" ""

mkdir build

xcrun -sdk iphoneos lipo \
  "/tmp/libtommath-${TOMMATH_VERSION}-arm64/lib/libtommath.a" \
  -create -output build/libtommath.a
# "/tmp/libtommath-${TOMMATH_VERSION}-i386/lib/libtommath.a" \
 # "/tmp/libtommath-${TOMMATH_VERSION}-x86_64/lib/libtommath.a" \

xcrun -sdk iphoneos ranlib "build/libtommath.a"