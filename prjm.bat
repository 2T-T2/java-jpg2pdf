setlocal enabledelayedexpansion

@echo off

rem �\�[�X�t�@�C���̃G���R�[�f�B���O
set src_enc=utf8
rem class�t�@�C���o�̓t�H���_
set out_dir=.\out\
rem jar�t�@�C���o�̓t�H���_
set dst_dir=.\dst\
rem javadoc�o�̓t�H���_
set doc_dir=.\docs\
rem �\�[�X�t�@�C���̊i�[�t�H���_
set src_dir=.\src\
rem �ˑ�jar�i�[�t�H���_
set lib_dir=.\lib\
rem ���\�[�X�ijar�Ɋ܂߂�j�t�@�C���̊i�[�t�H���_
set res_dir=.\res\
rem maven���|�W�g���쐬�t�H���_
set rep_dir=.\rep\
set rep_dir_uri=file:///%CD:\=/%%rep_dir:\=/%
rem �o��jar�t�@�C����
set jar_name=t_panda.jpg2pdf.jar
rem �R���p�C���A�A�[�J�C�u���A�h�L�������g�����̑Ώۃ��W���[����
set mdl_name=t_panda.jpg2pdf
rem maven���|�W�g���쐬���Ɏg�p����POM�t�@�C��
set pom_name=pom.xml

rem �G���[���b�Z�[�W
set error_msg=0

REM �t�H���_�쐬
If not exist %out_dir% mkdir %out_dir%
If not exist %dst_dir% mkdir %dst_dir%
If not exist %doc_dir% mkdir %doc_dir%
If not exist %src_dir% mkdir %src_dir%
If not exist %lib_dir% mkdir %lib_dir%
If not exist %res_dir% mkdir %res_dir%
If not exist %rep_dir% mkdir %rep_dir%
If not exist %src_dir%t_panda.jpg2pdf mkdir %src_dir%t_panda.jpg2pdf

REM module-info.java �쐬
REM echo %src_dir%t_panda.jpg2pdf\module-info.java
REM echo module t_panda.jpg2pdf { > %src_dir%t_panda.jpg2pdf\module-info.java
REM echo     // requires /* transitive */ �ˑ�����O�����W���[��; >> %src_dir%t_panda.jpg2pdf\module-info.java
REM echo     // opens �O�����W���[�����烊�t���N�V�����ŃA�N�Z�X��������p�b�P�[�W; >> %src_dir%t_panda.jpg2pdf\module-info.java
REM echo     // exports �O�����W���[������A�N�Z�X��������p�b�P�[�W; >> %src_dir%t_panda.jpg2pdf\module-info.java
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
    echo     %lib_dir%, %out_dir%, %dst_dir%, %doc_dir% ���N���[�����܂�
    echo.
    echo %~nx0 dl-depend
    echo     %lib_dir% �� %pom_name% �Ŏw�肳�ꂽ�ˑ��t�@�C�����_�E�����[�h���܂�
    echo.
    echo %~nx0 compile
    echo     %src_dir% �̓��e���R���p�C�����܂�
    echo     �o�͐�t�H���_ %out_dir%
    echo.
    echo %~nx0 archive
    echo     %out_dir%, %src_dir%, %res_dir% ���A�[�J�C�u������jar���쐬���܂�
    echo     �o�͐�t�@�C���� %dst_dir%%jar_name%
    echo.
    echo %~nx0 mvnrep
    echo     %dst_dir%%jar_name%, %pom_name% ����maven���|�W�g���̍쐬���s���܂�
    echo     �o�͐�t�@�C���� %dst_dir%%jar_name%
    echo.
    echo %~nx0 javadoc
    echo     �h�L�������g�𐶐����܂�
    echo     �o�͐�t�H���_ %doc_dir%
    echo.
    echo %~nx0 all
    echo     clean -^> dl-depend -^> compile
    echo     -^> archive -^> mvnrep -^> javadoc �̏��Ŏ��s���܂�
    echo.

    goto :end
    echo.
)

call :%1
goto :end

:clean
    echo =============== �N���[���J�n ===============
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
    echo =============== �N���[���I�� ===============
exit /b

:dl-depend
    echo =============== �ˑ��t�@�C���_�E�����[�h�J�n ===============
    REM �ˑ��t�@�C�����f�B���N�g�����w�肵�ă_�E�����[�h
    set mvnDlDependCmd=call mvn dependency:copy-dependencies -f %pom_name% -DoutputDirectory=%lib_dir%
    echo %mvnDlDependCmd%
    %mvnDlDependCmd%
    if %errorlevel% neq 0 (
        set error_msg=�ˑ��t�@�C���_�E�����[�h�G���[
        goto :echo_error
    )
    echo =============== �ˑ��t�@�C���_�E�����[�h�I�� ===============
exit /b

:compile
    echo =============== �R���p�C���J�n ===============
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
        set error_msg=�R���p�C���G���[
        goto :echo_error
    )
    echo =============== �R���p�C���I�� ===============
exit /b

:archive
    echo =============== �A�[�J�C�u���J�n ===============
    set jarCmd=jar^
        -cf %dst_dir%%jar_name%^
        -C %out_dir%%mdl_name% .^
        -C %src_dir%%mdl_name% .^
        %res_dir%
    echo %jarCmd%
    %jarCmd%
    if %errorlevel% neq 0 (
        set error_msg=�A�[�J�C�u���G���[
        goto :echo_error
    )
    echo =============== �A�[�J�C�u���I�� ===============
exit /b

:mvnrep
    echo =============== ���|�W�g���쐬�J�n ===============
�@�@�@�@REM �w��t�@�C��(jar��pom)���w��f�B���N�g���Ƀf�v���C
�@�@�@�@set mvnDeployCmd=call mvn deploy:deploy-file -Dfile=%dst_dir%%jar_name% -Durl=%rep_dir_uri% -DpomFile=%pom_name% -Dpackaging=jar
    echo %mvnDeployCmd%
    %mvnDeployCmd%
    if %errorlevel% neq 0 (
        set error_msg=���|�W�g���쐬�G���[
        goto :echo_error
    )
    echo =============== ���|�W�g���쐬�I�� ===============
exit /b

:javadoc
    echo =============== �h�L�������g�����J�n ===============
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
        set error_msg=�h�L�������g�����G���[
        goto :echo_error
    )
    echo =============== �h�L�������g�����I�� ===============
exit /b

:echo_error
    echo %error_msg%
goto :end

:end
    ENDLOCAL
