#!/bin/bash

# stop script when errors
set -e

# save paths
export BUILD_DIRECTORY=$(pwd)
cd ../
export PROJECT_DIRECTORY=$(pwd)
cd $BUILD_DIRECTORY

# create temp directory
mkdir tempBuild
cd tempBuild

# get depot tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=$BUILD_DIRECTORY/tempBuild/depot_tools:$PATH

# get repo with dependencies
git clone https://github.com/sequenia/mediasoup-ios-client.git
git clone https://github.com/sequenia/libmediasoupclient.git mediasoup-ios-client/mediasoup-client-ios/dependencies/libmediasoupclient

# get the WebRTC iOS code
mkdir webrtc-ios
cd webrtc-ios
fetch --nohooks webrtc_ios
gclient syncs
cd src
git checkout -b m84 refs/remotes/branch-heads/4147
gclient sync

# replace files with correct
cp $BUILD_DIRECTORY/supportFiles/find_sdk.py $BUILD_DIRECTORY/tempBuild/webrtc-ios/src/build/mac/

# without bitcode
python tools_webrtc/ios/build_ios_libs.py --extra-gn-args='is_component_build=false rtc_include_tests=false rtc_enable_protobuf=false use_rtti=true use_custom_libcxx=false'

# build the libwebrtc static libraries (64 bit)
cd out_ios_libs

ninja -C arm64_libs/ webrtc

mkdir universal

# create a FAT libwebrtc static library
lipo -create arm64_libs/obj/libwebrtc.a -output universal/libwebrtc.a

cd $BUILD_DIRECTORY/tempBuild/mediasoup-ios-client/mediasoup-client-ios/dependencies/

mv $BUILD_DIRECTORY/tempBuild/webrtc-ios/src/* $BUILD_DIRECTORY/tempBuild/mediasoup-ios-client/mediasoup-client-ios/dependencies/webrtc/src/

# build iOS arm64
cmake . -Bbuild -DLIBWEBRTC_INCLUDE_PATH=$BUILD_DIRECTORY/tempBuild/mediasoup-ios-client/mediasoup-client-ios/dependencies/webrtc/src -DLIBWEBRTC_BINARY_PATH=$BUILD_DIRECTORY/tempBuild/mediasoup-ios-client/mediasoup-client-ios/dependencies/webrtc/src/out_ios_libs/universal -DMEDIASOUP_LOG_TRACE=ON -DMEDIASOUP_LOG_DEV=ON -DCMAKE_CXX_FLAGS="-fvisibility=hidden" -DLIBSDPTRANSFORM_BUILD_TESTS=OFF -DIOS_SDK=iphone -DIOS_ARCHS="arm64" -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/

make -C build

# create a FAT libmediasoup/libsdptransform library
mkdir $BUILD_DIRECTORY/tempBuild/mediasoup-ios-client/mediasoup-client-ios/dependencies/libmediasoupclient/lib

lipo -create build/libmediasoupclient/libmediasoupclient.a -output libmediasoupclient/lib/libmediasoupclient.a
lipo -create build/libmediasoupclient/libsdptransform/libsdptransform.a -output libmediasoupclient/lib/libsdptransform.a

# copy libraries files
mkdir $PROJECT_DIRECTORY/mediasoup-client-ios/dependencies/libmediasoupclient/lib

cp libmediasoupclient/lib/libmediasoupclient.a $PROJECT_DIRECTORY/mediasoup-client-ios/dependencies/libmediasoupclient/lib/
cp libmediasoupclient/lib/libsdptransform.a $PROJECT_DIRECTORY/mediasoup-client-ios/dependencies/libmediasoupclient/lib/

cp -r $BUILD_DIRECTORY/tempBuild/mediasoup-ios-client/mediasoup-client-ios/dependencies/libmediasoupclient/* $PROJECT_DIRECTORY/mediasoup-client-ios/dependencies/libmediasoupclient/

mv $BUILD_DIRECTORY/tempBuild/mediasoup-ios-client/mediasoup-client-ios/dependencies/webrtc/src/* $PROJECT_DIRECTORY/mediasoup-client-ios/dependencies/webrtc/src/
cp $BUILD_DIRECTORY/supportFiles/byte_order.h $PROJECT_DIRECTORY/mediasoup-client-ios/dependencies/webrtc/src/rtc_base/

# clear temp
# rm -rf $BUILD_DIRECTORY/tempBuild

open $PROJECT_DIRECTORY/mediasoup-client-ios.xcodeproj
