# BuildApkWithCommandLine

```bash
/Users/diyuanwang/Library/Android/sdk/build-tools/28.0.3/aapt2 compile --dir res/ -o res.zip

/Users/diyuanwang/Library/Android/sdk/build-tools/28.0.3/aapt2 link --proto-format -o tmp.apk -I /Users/diyuanwang/Library/Android/sdk/platforms/android-28/android.jar res.zip --manifest AndroidManifest.xml --auto-add-overlay --java gen

unzip tmp.apk -d staging

mkdir -p staging/{manifest,dex} && mv staging/AndroidManifest.xml staging/manifest

javac -source 1.8 -target 1.8 -bootclasspath $JAVA_HOME/jre/lib/rt.jar -classpath /Users/diyuanwang/Library/Android/sdk/platforms/android-28/android.jar -d classes gen/com/andforce/buildapkwithcommandline/*.java java/com/andforce/buildapkwithcommandline/*.java

/Users/diyuanwang/Library/Android/sdk/build-tools/28.0.3/dx --dex --output=staging/dex/classes.dex classes/

cd staging && zip -r ../base.zip * && cd -

java -jar bundletool-all-0.10.2.jar build-apks --bundle=bundle.aab --output=out.apks --mode=universal
```

```bash
rm -rf obj && rm -rf bin && mkdir obj && mkdir bin

aapt package -v -f -m -S app/src/main/res -J app/src/main/java/ -M app/src/main/AndroidManifest.xml -I /home/dy/android-sdk/platforms/android-28/android.jar -I /home/dy/Desktop/aapt/smartisanos.jar

javac -verbose -d ./obj -classpath /home/dy/android-sdk/platforms/android-28/android.jar -sourcepath app/src/main/java/ app/src/main/java/com/andforce/buildapkwithcommandline/*.java


~/android-sdk/build-tools/28.0.3/dx --dex --output=./bin/classes.dex ./obj


aapt package -v -f -M app/src/main/AndroidManifest.xml -S app/src/main/res -I /home/dy/android-sdk/platforms/android-28/android.jar -I /home/dy/Desktop/aapt/smartisanos.jar -F ./bin/unsigned.apk ./bin



jarsigner -verbose -keystore ~/.android/debug.keystore -storepass android -keypass android bin/unsigned.apk androiddebugkey

adb install -r -d bin/unsigned.apk
```