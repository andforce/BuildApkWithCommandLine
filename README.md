# BuildApkWithCommandLine

### 设置环境变量
假如我们要使用`build-tools-29.0.2`编译：
```bash
export PATH=$PATH:~/android-sdk/build-tools/29.0.2/
```
执行
```shell
aapt2 version
```
>Android Asset Packaging Tool (aapt) 2.19-SOONG BUILD NUMBER PLACEHOLDER

看到以上信息就表示设置成功了

当然还要设置JDK环境变量，这个比较常规，就不说了

### 使用AAPT2编译

1. 创建`build`目录
```shell
mkdir build
```

2. 编译打包资源文件
```bash
aapt2 compile --dir app/src/main/res/ -o build/res.zip
```

3. 连接资源文件ID,生成R.java
```bash
aapt2 link --proto-format -o build/link_res_id_res.zip -I ~/android-sdk/platforms/android-28/android.jar build/res.zip --manifest app/src/main/AndroidManifest.xml --auto-add-overlay --java build/gen/R
```
4. 拆分资源包
```bash
unzip build/link_res_id_res.zip -d build/staging/
# 创建拆分目录
mkdir -p build/staging/{manifest,dex}
# 移动资源文件
mv build/staging/AndroidManifest.xml build/staging/manifest/
```
5. 编译java文件,生成class,放入build/classes/
```shell
javac -source 1.8 -target 1.8 -bootclasspath $JAVA_HOME/jre/lib/rt.jar -classpath ~/android-sdk/platforms/android-28/android.jar -d build/classes/ build/gen/R/com/andforce/buildapkwithcommandline/*.java app/src/main/java/com/andforce/buildapkwithcommandline/*.java
```
6. 将class进行dex化
```shell
dx --dex --output=build/staging/dex/classes.dex build/classes/
```

7. 打包

```shell
cd build/staging/ && zip -r ../base.zip ./* && cd -
```

8. 打包abb
下载最新的`bundletool`jar， https://github.com/google/bundletool/releases/latest
用`bundletool-all-0.10.2.jar`为举例：
```shell
java -jar bundletool-all-0.10.2.jar build-bundle --modules=build/base.zip --output=build/bundle.aab
```

9. 编译apks
```shell
java -jar bundletool-all-0.10.2.jar build-apks --bundle=build/bundle.aab --output=build/out.apks --mode=universal
```
10. 解压out.apks得到单个apk
```shell
unzip -o build/out.apks -d build/
```

### 使用AAPT编译

1. 创建编译目录

```
mkdir -p build/gen/R/
```
2. 编译资源文件，生成R.java
```shell
aapt package -v -f -m -S app/src/main/res -J build/gen/R/ -M app/src/main/AndroidManifest.xml -I ~/android-sdk/platforms/android-28/android.jar -I /home/dy/Desktop/aapt/smartisanos.jar
```
3. 
```shell

javac -verbose -d ./obj -classpath /home/dy/android-sdk/platforms/android-28/android.jar -sourcepath app/src/main/java/ app/src/main/java/com/andforce/buildapkwithcommandline/*.java


~/android-sdk/build-tools/28.0.3/dx --dex --output=./bin/classes.dex ./obj


aapt package -v -f -M app/src/main/AndroidManifest.xml -S app/src/main/res -I /home/dy/android-sdk/platforms/android-28/android.jar -I /home/dy/Desktop/aapt/smartisanos.jar -F ./bin/unsigned.apk ./bin



jarsigner -verbose -keystore ~/.android/debug.keystore -storepass android -keypass android bin/unsigned.apk androiddebugkey

adb install -r -d bin/unsigned.apk
```