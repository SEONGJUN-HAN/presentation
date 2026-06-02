@echo off
chcp 65001 > nul
echo.
echo ========================================
echo  발표자료 단일 파일 빌드 스크립트
echo  실행하면 dist/output.html 이 생성됩니다
echo ========================================
echo.

:: Node.js 설치 여부 확인
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [오류] Node.js가 설치되지 않았습니다.
    echo       https://nodejs.org 에서 설치 후 다시 실행하세요.
    pause
    exit /b
)

:: 빌드 스크립트 실행
node build.js

if %errorlevel% equ 0 (
    echo.
    echo [완료] dist/output.html 생성 성공!
    echo        이 파일 하나만 복사하면 어디서든 실행됩니다.
) else (
    echo.
    echo [실패] 오류가 발생했습니다. 위 메시지를 확인하세요.
)

echo.
pause