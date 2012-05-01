#! /bin/bash

cd `dirname $0` && \

xcodebuild -project Objective-Chipmunk.xcodeproj -sdk iphoneos4.3 -configuration Release -target Objective-Chipmunk && \
xcodebuild -project Objective-Chipmunk.xcodeproj -sdk iphoneos4.3 -configuration Release-Trial -target Objective-Chipmunk && \
xcodebuild -project Objective-Chipmunk.xcodeproj -sdk iphonesimulator4.3 -configuration Debug -target Objective-Chipmunk && \

#build iPhone version
rm -rf Objective-Chipmunk-iPhone && \

mkdir Objective-Chipmunk-iPhone && \
cp *.h Objective-Chipmunk-iPhone && \
rsync -r --exclude=".*" ../Chipmunk/include/chipmunk/ Objective-Chipmunk-iPhone/chipmunk && \

lipo build/Debug-iphonesimulator/libObjectiveChipmunk.a build/Release-iphoneos/libObjectiveChipmunk.a -create -output Objective-Chipmunk-iPhone/libObjectiveChipmunk-iPhone.a  && \
#tar -czf Objective-Chipmunk-iPhone.tgz Objective-Chipmunk-iPhone

# build trial version
rm -rf Objective-Chipmunk-trial && \

mkdir Objective-Chipmunk-trial && \
cp *.h Objective-Chipmunk-trial && \
rsync -r --exclude=".*" ../Chipmunk/include/chipmunk/ Objective-Chipmunk-trial/chipmunk && \

lipo build/Debug-iphonesimulator/libObjectiveChipmunk.a build/Release-Trial-iphoneos/libObjectiveChipmunk.a -create -output Objective-Chipmunk-trial/libObjectiveChipmunk-iPhone.a  && \
#tar -czf Objective-Chipmunk-simulator.tgz Objective-Chipmunk-simulator

# Wait for user input
echo Build complete. Press return to exit. && \
read
