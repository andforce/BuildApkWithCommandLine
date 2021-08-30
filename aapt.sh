#!/bin/bash
export PATH=$PATH:"${ANDROID_HOME}/build-tools/30.0.2/" && \

SDK_30="${ANDROID_HOME}/platforms/android-23/android.jar" && \

echo "$SDK_30" && \

rm -rf build/ && \

mkdir -p build/{outputs/apk,intermediates/{classes,dex},generated/source}  && \

aapt package -v -f -m -S app/src/main/res -J build/generated/source/ -M app/src/main/AndroidManifest.xml -I "$SDK_30" && \

javac -verbose -d build/intermediates/classes/ -classpath "$SDK_30" -sourcepath build/generated/source/ app/src/main/java/com/andforce/build/*.java && \

dx --dex --output=build/intermediates/dex/classes.dex build/intermediates/classes/ && \

aapt package -v -f -M app/src/main/AndroidManifest.xml --min-sdk-version 21 --target-sdk-version 23 -S app/src/main/res -I "$SDK_30" -F build/outputs/apk/unsigned.apk build/intermediates/dex/ && \

jarsigner -verbose -keystore ~/.android/debug.keystore -storepass android -keypass android build/outputs/apk/unsigned.apk androiddebugkey && \

mv build/outputs/apk/unsigned.apk build/outputs/apk/signed.apk && \

adb install -r -d build/outputs/apk/signed.apk
