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

`注意⚠️：android.jar 的版本要跟运行到手机系统匹配，比如手机系统是android 6.0, 那么你需要使用 $androidsdk/platforms/android-23/android.jar`

### 使用AAPT编译

编译完成后，build目录结构

```bash
build
├── generated
│   └── source
│       └── com
│           └── andforce
│               └── build
│                   └── R.java
├── intermediates
│   ├── classes
│   │   └── com
│   │       └── andforce
│   │           └── build
│   │               ├── MainActivity.class
│   │               ├── R$attr.class
│   │               ├── R.class
│   │               ├── R$color.class
│   │               ├── R$drawable.class
│   │               ├── R$layout.class
│   │               └── R$string.class
│   └── dex
│       └── classes.dex
└── outputs
    └── apk
        └── unsigned.apk
```



1. 创建编译目录

```
mkdir -p build/{outputs/apk,intermediates/{classes,dex},generated/source}
```
2. 编译资源文件，生成R.java
```shell
aapt package -v -f -m -S app/src/main/res -J build/generated/source/ -M app/src/main/AndroidManifest.xml -I ~/android-sdk/platforms/android-28/android.jar
```
3. 编译java文件
```shell
javac -verbose -d build/intermediates/classes/ -classpath ~/android-sdk/platforms/android-28/android.jar -sourcepath build/generated/source/ app/src/main/java/com/andforce/build/*.java
```
4. 将class进行dex化
```shell
dx --dex --output=build/intermediates/dex/classes.dex build/intermediates/classes/
```
5. 打包未签名apk
```shell
aapt package -v -f -M app/src/main/AndroidManifest.xml --min-sdk-version 21 --target-sdk-version 29 -S app/src/main/res -I ~/android-sdk/platforms/android-28/android.jar -F build/outputs/apk/unsigned.apk build/intermediates/dex/
```
6. 签名apk
```shell
jarsigner -verbose -keystore ~/.android/debug.keystore -storepass android -keypass android build/outputs/apk/unsigned.apk androiddebugkey
# rename
mv build/outputs/apk/unsigned.apk build/outputs/apk/signed.apk
# 安装
adb install -r -d build/outputs/apk/signed.apk
```

### 使用AAPT2编译

编译完成后，build目录结构

```bash
build
├── generated
│   └── source
│       └── com
│           └── andforce
│               └── build
│                   └── R.java
├── intermediates
│   ├── classes
│   │   └── com
│   │       └── andforce
│   │           └── build
│   │               ├── MainActivity.class
│   │               ├── R.class
│   │               ├── R$color.class
│   │               ├── R$drawable.class
│   │               ├── R$layout.class
│   │               └── R$string.class
│   ├── res
│   │   ├── link_res_id_res.zip
│   │   └── res.zip
│   └── staging
│       ├── dex
│       │   └── classes.dex
│       ├── manifest
│       │   └── AndroidManifest.xml
│       ├── res
│       │   ├── drawable
│       │   │   └── ic_launcher.png
│       │   └── layout
│       │       └── activity_main.xml
│       └── resources.pb
└── outputs
    ├── aab
    │   └── bundle.aab
    ├── apk
    │   ├── toc.pb
    │   └── universal.apk
    ├── base.zip
    └── out.apks
```



1. 创建`build`目录
```shell
mkdir -p build/{outputs/{apk,aab},intermediates/{res,classes,staging/{manifest,dex}},generated/source}
```

2. 编译打包资源文件
```bash
aapt2 compile --dir app/src/main/res/ -o build/intermediates/res/res.zip
```

3. 连接资源文件ID,生成R.java
```bash
aapt2 link --proto-format -o build/intermediates/res/link_res_id_res.zip -I ~/android-sdk/platforms/android-28/android.jar build/intermediates/res/res.zip --manifest app/src/main/AndroidManifest.xml --min-sdk-version 21 --target-sdk-version 29 --auto-add-overlay --java build/generated/source
```
4. 拆分资源包
```bash
unzip build/intermediates/res/link_res_id_res.zip -d build/intermediates/staging/
# 移动资源文件
mv build/intermediates/staging/AndroidManifest.xml build/intermediates/staging/manifest/
```
5. 编译java文件,生成class
```shell
javac -source 1.8 -target 1.8 -bootclasspath $JAVA_HOME/jre/lib/rt.jar -classpath ~/android-sdk/platforms/android-28/android.jar -d build/intermediates/classes/ build/generated/source/com/andforce/build/*.java app/src/main/java/com/andforce/build/*.java
```
6. 将class进行dex化
```shell
dx --dex --output=build/intermediates/staging/dex/classes.dex build/intermediates/classes/
```

7. 打包

```shell
cd build/intermediates/staging/ && zip -r ../../outputs/base.zip ./* && cd -
```

8. 打包aab

下载最新的`bundletool`jar， https://github.com/google/bundletool/releases/latest
用`bundletool-all-0.10.2.jar`为举例：
```shell
java -jar bundletool-all-0.10.2.jar build-bundle --modules=build/outputs/base.zip --output=build/outputs/aab/bundle.aab
```

9. 编译apks
```shell
java -jar bundletool-all-0.10.2.jar build-apks --bundle=build/outputs/aab/bundle.aab --output=build/outputs/out.apks --mode=universal
```
10. 解压out.apks得到单个apk
```shell
unzip -o build/outputs/out.apks -d build/outputs/apk/
# 安装
adb install -r -d build/outputs/apk/
```
