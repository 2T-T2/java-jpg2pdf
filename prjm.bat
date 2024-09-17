setlocal enabledelayedexpansion

@echo off

rem ソースファイルのエンコーディング
set src_enc=utf8
rem classファイル出力フォルダ
set out_dir=.\out\
rem jarファイル出力フォルダ
set dst_dir=.\dst\
rem javadoc出力フォルダ
set doc_dir=.\docs\
rem ソースファイルの格納フォルダ
set src_dir=.\src\
rem 依存jar格納フォルダ
set lib_dir=.\lib\
rem リソース（jarに含める）ファイルの格納フォルダ
set res_dir=.\res\
rem mavenリポジトリ作成フォルダ
set rep_dir=.\rep\
set rep_dir_uri=file:///%CD:\=/%%rep_dir:\=/%
rem 出力jarファイル名
set jar_name=t_panda.jpg2pdf.jar
rem コンパイル、アーカイブ化、ドキュメント生成の対象モジュール名
set mdl_name=t_panda.jpg2pdf
rem mavenリポジトリ作成時に使用するPOMファイル
set pom_name=pom.xml

rem エラーメッセージ
set error_msg=0

REM フォルダ作成
If not exist %out_dir% mkdir %out_dir%
If not exist %dst_dir% mkdir %dst_dir%
If not exist %doc_dir% mkdir %doc_dir%
If not exist %src_dir% mkdir %src_dir%
If not exist %lib_dir% mkdir %lib_dir%
If not exist %res_dir% mkdir %res_dir%
If not exist %rep_dir% mkdir %rep_dir%
If not exist %src_dir%t_panda.jpg2pdf mkdir %src_dir%t_panda.jpg2pdf

REM module-info.java 作成
REM echo %src_dir%t_panda.jpg2pdf\module-info.java
REM echo module t_panda.jpg2pdf { > %src_dir%t_panda.jpg2pdf\module-info.java
REM echo     // requires /* transitive */ 依存する外部モジュール; >> %src_dir%t_panda.jpg2pdf\module-info.java
REM echo     // opens 外部モジュールからリフレクションでアクセスを許可するパッケージ; >> %src_dir%t_panda.jpg2pdf\module-info.java
REM echo     // exports 外部モジュールからアクセスを許可するパッケージ; >> %src_dir%t_panda.jpg2pdf\module-info.java
REM echo } >> %src_dir%t_panda.jpg2pdf\module-info.java

if "%~1"=="all" (
echo.
    call :clean
echo.
    call :dl-depend
echo.
    call :compile
echo.
    call :archive
echo.
    call :mvnrep
echo.
    call :javadoc
echo.
    goto :end
echo.
)

set help_disp_flg=false
if "%1"=="help"  set help_disp_flg=true
if "%1"=="/help" set help_disp_flg=true
if "%1"=="-help" set help_disp_flg=true
if "%1"=="-h"    set help_disp_flg=true
if "%1"==""      set help_disp_flg=true

if "%help_disp_flg%"=="true" (
    echo.

    echo %~nx0 clean
    echo     %lib_dir%, %out_dir%, %dst_dir%, %doc_dir% をクリーンします
    echo.
    echo %~nx0 dl-depend
    echo     %lib_dir% に %pom_name% で指定された依存ファイルをダウンロードします
    echo.
    echo %~nx0 compile
    echo     %src_dir% の内容をコンパイルします
    echo     出力先フォルダ %out_dir%
    echo.
    echo %~nx0 archive
    echo     %out_dir%, %src_dir%, %res_dir% をアーカイブ化してjarを作成します
    echo     出力先ファイル名 %dst_dir%%jar_name%
    echo.
    echo %~nx0 mvnrep
    echo     %dst_dir%%jar_name%, %pom_name% からmavenリポジトリの作成を行います
    echo     出力先ファイル名 %dst_dir%%jar_name%
    echo.
    echo %~nx0 javadoc
    echo     ドキュメントを生成します
    echo     出力先フォルダ %doc_dir%
    echo.
    echo %~nx0 all
    echo     clean -^> dl-depend -^> compile
    echo     -^> archive -^> mvnrep -^> javadoc の順で実行します
    echo.

    goto :end
    echo.
)

call :%1
goto :end

:clean
    echo =============== クリーン開始 ===============
    del /s /q %out_dir%
    del /s /q %dst_dir%
    del /s /q %doc_dir%
    del /s /q %lib_dir%
    del /s /q %rep_dir%
    rmdir /s /q %out_dir%
    rmdir /s /q %dst_dir%
    rmdir /s /q %doc_dir%
    rmdir /s /q %lib_dir%
    rmdir /s /q %rep_dir%
    mkdir %out_dir%
    mkdir %dst_dir%
    mkdir %doc_dir%
    mkdir %lib_dir%
    mkdir %rep_dir%
    echo =============== クリーン終了 ===============
exit /b

:dl-depend
    echo =============== 依存ファイルダウンロード開始 ===============
    REM 依存ファイルをディレクトリを指定してダウンロード
    set mvnDlDependCmd=call mvn dependency:copy-dependencies -f %pom_name% -DoutputDirectory=%lib_dir%
    echo %mvnDlDependCmd%
    %mvnDlDependCmd%
    if %errorlevel% neq 0 (
        set error_msg=依存ファイルダウンロードエラー
        goto :echo_error
    )
    echo =============== 依存ファイルダウンロード終了 ===============
exit /b

:compile
    echo =============== コンパイル開始 ===============
    set javacCmd=javac^
        -d %out_dir%^
        -encoding %src_enc%^
        -parameters^
        --module-source-path %src_dir%^
        --module %mdl_name%^
        --module-path %lib_dir%
    echo %javacCmd%
    %javacCmd%
    if %errorlevel% neq 0 (
        set error_msg=コンパイルエラー
        goto :echo_error
    )
    echo =============== コンパイル終了 ===============
exit /b

:archive
    echo =============== アーカイブ化開始 ===============
    set jarCmd=jar^
        -cf %dst_dir%%jar_name%^
        -C %out_dir%%mdl_name% .^
        -C %src_dir%%mdl_name% .^
        %res_dir%
    echo %jarCmd%
    %jarCmd%
    if %errorlevel% neq 0 (
        set error_msg=アーカイブ化エラー
        goto :echo_error
    )
    echo =============== アーカイブ化終了 ===============
exit /b

:mvnrep
    echo =============== リポジトリ作成開始 ===============
　　　　REM 指定ファイル(jarとpom)を指定ディレクトリにデプロイ
　　　　set mvnDeployCmd=call mvn deploy:deploy-file -Dfile=%dst_dir%%jar_name% -Durl=%rep_dir_uri% -DpomFile=%pom_name% -Dpackaging=jar
    echo %mvnDeployCmd%
    %mvnDeployCmd%
    if %errorlevel% neq 0 (
        set error_msg=リポジトリ作成エラー
        goto :echo_error
    )
    echo =============== リポジトリ作成終了 ===============
exit /b

:javadoc
    echo =============== ドキュメント生成開始 ===============
    set javadocCmd=javadoc ^
        --allow-script-in-comments ^
        -d %doc_dir% ^
        -encoding utf8^
        --module-source-path %src_dir%^
        --module %mdl_name%^
        --module-path %lib_dir%^
        -header "<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.10/styles/vs.min.css'><script src='https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.10/highlight.min.js'></script><script>hljs.initHighlightingOnLoad();</script>"
    echo %javadocCmd%
    %javadocCmd%
    if %errorlevel% neq 0 (
        set error_msg=ドキュメント生成エラー
        goto :echo_error
    )
    echo =============== ドキュメント生成終了 ===============
exit /b

:echo_error
    echo %error_msg%
goto :end

:end
    ENDLOCAL
