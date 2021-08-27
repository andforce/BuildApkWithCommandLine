export PATH=$PATH:"${ANDROID_HOME}/build-tools/30.0.2/"

SDK_30="${ANDROID_HOME}/platforms/android-23/android.jar"
echo "$SDK_30"

rm -rf build/

mkdir -p build/{outputs/{apk,aab},intermediates/{res,classes,staging/{manifest,dex}},generated/source}
aapt2 compile --dir app/src/main/res/ -o build/intermediates/res/res.zip
aapt2 link --proto-format -o build/intermediates/res/link_res_id_res.zip -I "$SDK_30" build/intermediates/res/res.zip --manifest app/src/main/AndroidManifest.xml --min-sdk-version 21 --target-sdk-version 23 --auto-add-overlay --java build/generated/source
unzip build/intermediates/res/link_res_id_res.zip -d build/intermediates/staging/
# 移动资源文件
mv build/intermediates/staging/AndroidManifest.xml build/intermediates/staging/manifest/
javac -source 1.8 -target 1.8 -bootclasspath "$JAVA_HOME"/jre/lib/rt.jar -classpath "$SDK_30" -d build/intermediates/classes/ build/generated/source/com/andforce/build/*.java app/src/main/java/com/andforce/build/*.java
dx --dex --output=build/intermediates/staging/dex/classes.dex build/intermediates/classes/
# shellcheck disable=SC2164
cd build/intermediates/staging/ && zip -r ../../outputs/base.zip ./* && cd -
java -jar bundletool-all-0.10.2.jar build-bundle --modules=build/outputs/base.zip --output=build/outputs/aab/bundle.aab
java -jar bundletool-all-0.10.2.jar build-apks --bundle=build/outputs/aab/bundle.aab --output=build/outputs/out.apks --mode=universal
unzip -o build/outputs/out.apks -d build/outputs/apk/

jarsigner -verbose -keystore ~/.android/debug.keystore -storepass android -keypass android build/outputs/apk/universal.apk androiddebugkey

# rename
mv build/outputs/apk/universal.apk build/outputs/apk/signed.apk

# 安装
adb install -r -d build/outputs/apk/signed.apk
