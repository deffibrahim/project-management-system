@echo off
setlocal EnableExtensions
title PMS - Stop

rem ---------- SETTINGS (same as start-pms.bat) ----------
set "TOMCAT_DIR=%USERPROFILE%\tomcat10\apache-tomcat-10.1.59\apache-tomcat-10.1.59"
set "XAMPP_DIR=C:\xampp"
rem ------------------------------------------------------

if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" goto java_ok
set "JAVA_HOME="
for /d %%D in ("%USERPROFILE%\.jdks\*17*") do set "JAVA_HOME=%%D"
if not defined JAVA_HOME for /d %%D in ("%USERPROFILE%\.jdks\*") do set "JAVA_HOME=%%D"
if not defined JAVA_HOME for /d %%D in ("C:\Program Files\Java\jdk*") do set "JAVA_HOME=%%D"
if not defined JAVA_HOME for /d %%D in ("C:\Program Files\BellSoft\*") do set "JAVA_HOME=%%D"
if not defined JAVA_HOME for /d %%D in ("C:\Program Files\Eclipse Adoptium\jdk*") do set "JAVA_HOME=%%D"
:java_ok

echo Stopping Tomcat...
set "CATALINA_HOME=%TOMCAT_DIR%"
set "CATALINA_BASE=%TOMCAT_DIR%"
if exist "%TOMCAT_DIR%\bin\catalina.bat" (
    pushd "%TOMCAT_DIR%\bin"
    call catalina.bat stop >nul 2>&1
    popd
    echo Tomcat stopped.
) else (
    echo Tomcat not found at %TOMCAT_DIR%
)

echo.
choice /c YN /m "Also stop MySQL"
if errorlevel 2 goto done
if exist "%XAMPP_DIR%\mysql\bin\mysqladmin.exe" (
    "%XAMPP_DIR%\mysql\bin\mysqladmin.exe" -u root shutdown
    echo MySQL stopped.
) else (
    echo mysqladmin.exe not found in %XAMPP_DIR%
)

:done
echo.
timeout /t 3 >nul
