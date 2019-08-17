# BuildApkWithCommandLine

```shell
/Users/diyuanwang/Library/Android/sdk/build-tools/28.0.3/aapt2 compile --dir res/ -o res.zip

/Users/diyuanwang/Library/Android/sdk/build-tools/28.0.3/aapt2 link --proto-format -o tmp.apk -I /Users/diyuanwang/Library/Android/sdk/platforms/android-28/android.jar res.zip --manifest AndroidManifest.xml --auto-add-overlay --java gen

unzip tmp.apk -d staging

mkdir -p staging/{manifest,dex} && mv staging/AndroidManifest.xml staging/manifest

javac -source 1.8 -target 1.8 -bootclasspath $JAVA_HOME/jre/lib/rt.jar -classpath /Users/diyuanwang/Library/Android/sdk/platforms/android-28/android.jar -d classes gen/com/andforce/buildapkwithcommandline/*.java java/com/andforce/buildapkwithcommandline/*.java

/Users/diyuanwang/Library/Android/sdk/build-tools/28.0.3/dx --dex --output=staging/dex/classes.dex classes/

cd staging && zip -r ../base.zip * && cd -

java -jar bundletool-all-0.10.2.jar build-apks --bundle=bundle.aab --output=out.apks --mode=universal
```
