# java-jpg2pdf
jpg画像をpdfに変換するライブラリ

## セットアップ方法
### mavenプロジェクトに追加する方法
pom.xmlに下記を記載
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

  <repositories>
    <repository>
      <id>nakigao_rep</id>
      <url>https://raw.githubusercontent.com/2T-T2/nakigao-maven-repository/main/</url>
    </repository>
  </repositories>

  <dependencies>
    <dependency>
      <groupId>t_panda.jpg2pdf</groupId>
      <artifactId>t_panda.jpg2pdf.jar</artifactId>
      <version>0.0.0.0</version>
    </dependency>
  </dependencies>
</project>
```
### ソースからJarを生成する方法
#### 前提条件
- 環境変数 PATH に JDKのbinフォルダを設定してあること
- 環境変数 PATH に Mavenのbinフォルダを設定してあること

ソースダウンロードする
```bat
curl -L -O "https://github.com/2T-T2/java-jpg2pdf/archive/refs/heads/main.zip"
```
ダウンロードしたzip解凍後にprmj.batのあるフォルダに移動し下記実行
```bat
prjm.bat all
```
上記実行後に、同フォルダに <b>rep\t_panda\compiler\t_panda.compiler.jar\0.0.0.0\t_panda.compiler.jar-0.0.0.0.jar</b> が生成される。<br>
<div><b><i>※pom.xml が存在しますが、mavenでのビルドは出来ません。。。</i></b></div>
生成された jar はモジュールパスに追加して使用してください。

### 使用例
```java
 import t_panda.jpg2pdf.Jpg2Pdf;

 import java.io.IOException;
 import java.nio.file.Files;
 import java.nio.file.Paths;

 public class Application {
     public static void main(String[] args) throws IOException {
         // コマンドライン引数で入出力ファイルを指定するサンプル
         if(args.length < 2) {
             System.err.println("引数が足りません");
             System.err.println("　　　引数1: 出力PDF名");
             System.err.println("　引数2以降: 入力JPG名");
         }

         try (Jpg2Pdf jpg2Pdf = new Jpg2Pdf(Files.newOutputStream(Paths.get(args[0])))) {
             for (int i = 1; i < args.length; i++) {
                 jpg2Pdf.addJpg(Paths.get(args[i]));
             }
         }

     }
 }
 ```

### ドキュメント
[https://2t-t2.github.io/java-jpg2pdf/](https://2t-t2.github.io/java-jpg2pdf/)

### 補足
<div><b><i>※pom.xml が存在しますが、mavenでのビルドは出来ません。。。</i></b></div>
ビルドはprjm.batを使用して行ってください。

```bat
prjm.bat help

prjm.bat clean
    .\lib\, .\out\, .\dst\, .\javadoc\ をクリーンします

prjm.bat dl-depend
    .\lib\ に pom.xml で指定された依存ファイルをダウンロードします

prjm.bat compile
    .\src\ の内容をコンパイルします
    出力先フォルダ .\out\

prjm.bat archive
    .\out\, .\src\, .\res\ をアーカイブ化してjarを作成します
    出力先ファイル名 .\dst\my.test.jar

prjm.bat mvnrep
    .\dst\my.test.jar, pom.xml からmavenリポジトリの作成を行います
    出力先ファイル名 .\dst\my.test.jar

prjm.bat javadoc
    ドキュメントを生成します
    出力先フォルダ .\javadoc\

prjm.bat all
    clean -> dl-depend -> compile
    -> archive -> mvnrep -> javadoc の順で実行します
```
