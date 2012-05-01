#! /bin/bash

cd `dirname $0` && \

xcodebuild -project Objective-Chipmunk.xcodeproj -sdk macosx10.6 -configuration Debug -target Objective-Chipmunk-Mac && \
xcodebuild -project Objective-Chipmunk.xcodeproj -sdk macosx10.6 -configuration Release -target Objective-Chipmunk-Mac && \

rm -rf Objective-Chipmunk-mac && \

mkdir Objective-Chipmunk-mac && \
cp *.h Objective-Chipmunk-mac && \
rsync -r --exclude=".*" ../Chipmunk/include/chipmunk/ Objective-Chipmunk-mac/chipmunk && \

cp build/Debug/libObjectiveChipmunk-Mac-Debug.a Objective-Chipmunk-mac/libObjectiveChipmunk-Mac-Debug.a && \
cp build/Release/libObjectiveChipmunk-Mac.a Objective-Chipmunk-mac/libObjectiveChipmunk-Mac.a
