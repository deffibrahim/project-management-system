@echo off
setlocal EnableExtensions
title PMS - One Click Launcher
cd /d "%~dp0"

rem ============================================================
rem  PMS ONE-CLICK LAUNCHER
rem  Put this file in the project root (next to pom.xml) and
rem  double-click it. It will:
rem    1. start MySQL (XAMPP) if it is not running
rem    2. create the pms_db database + demo data if missing
rem    3. build the WAR with Maven
rem    4. deploy it to Tomcat and start Tomcat
rem    5. open the app in your browser
rem ============================================================

rem ---------- SETTINGS (edit only if your paths differ) ----------
set "APP=projectmanagementtool"
set "TOMCAT_DIR=%USERPROFILE%\tomcat10\apache-tomcat-10.1.59\apache-tomcat-10.1.59"
set "XAMPP_DIR=C:\xampp"
set "WAR_BUILT=%~dp0target\%APP%-1.0-SNAPSHOT.war"
rem ---------------------------------------------------------------

echo =========================================================
echo   PROJECT MANAGEMENT SYSTEM - STARTING...
echo =========================================================
echo.

rem ---------- Find Java ----------
if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" goto java_ok
set "JAVA_HOME="
for /d %%D in ("%USERPROFILE%\.jdks\*17*") do set "JAVA_HOME=%%D"
if not defined JAVA_HOME for /d %%D in ("%USERPROFILE%\.jdks\*") do set "JAVA_HOME=%%D"
if not defined JAVA_HOME for /d %%D in ("C:\Program Files\Java\jdk*") do set "JAVA_HOME=%%D"
if not defined JAVA_HOME for /d %%D in ("C:\Program Files\BellSoft\*") do set "JAVA_HOME=%%D"
if not defined JAVA_HOME for /d %%D in ("C:\Program Files\Eclipse Adoptium\jdk*") do set "JAVA_HOME=%%D"
if not defined JAVA_HOME goto java_missing
:java_ok
if "%JAVA_HOME:~-1%"=="\" set "JAVA_HOME=%JAVA_HOME:~0,-1%"
for %%S in ("%JAVA_HOME%") do set "JAVA_HOME=%%~sS"
echo [OK] Java: %JAVA_HOME%

rem ---------- Check Tomcat ----------
if not exist "%TOMCAT_DIR%\bin\catalina.bat" goto tomcat_missing
echo [OK] Tomcat: %TOMCAT_DIR%

rem ---------- 1. MySQL ----------
echo.
echo [1/5] MySQL...
call :port_open 3306
if not errorlevel 1 goto mysql_ready
if not exist "%XAMPP_DIR%\mysql\bin\mysqld.exe" goto mysql_missing
echo       Starting MySQL...
start "PMS-MySQL" /min "%XAMPP_DIR%\mysql\bin\mysqld.exe" --defaults-file="%XAMPP_DIR%\mysql\bin\my.ini" --standalone
call :wait_port 3306 40
if errorlevel 1 goto mysql_fail
:mysql_ready
echo       MySQL is running on port 3306.

rem ---------- 2. Database ----------
echo.
echo [2/5] Database...
if not exist "%XAMPP_DIR%\mysql\bin\mysql.exe" goto db_skip
pushd "%XAMPP_DIR%\mysql\bin"
set "HAS_TABLE="
for /f "usebackq" %%C in (`mysql.exe -u root --batch --skip-column-names -e "SHOW TABLES FROM pms_db LIKE 'users'" 2^>nul`) do set "HAS_TABLE=1"
if not defined HAS_TABLE goto db_schema
set "HAS_ROWS="
for /f "usebackq" %%C in (`mysql.exe -u root --batch --skip-column-names -e "SELECT user_id FROM pms_db.users LIMIT 1" 2^>nul`) do set "HAS_ROWS=1"
if not defined HAS_ROWS goto db_seed
popd
echo       pms_db already set up.
goto build

:db_schema
echo       Creating pms_db tables...
mysql.exe -u root < "%~dp0database\schema.sql"
if errorlevel 1 goto db_fail
:db_seed
echo       Loading demo data...
mysql.exe -u root < "%~dp0database\sample_data.sql"
if errorlevel 1 goto db_fail
popd
echo       Database ready.
goto build

:db_skip
echo       mysql.exe not found in XAMPP - skipping database check.
goto build

rem ---------- 3. Build ----------
:build
echo.
echo [3/5] Building project...
set "MVN="
set "TOOLS=%USERPROFILE%\.pms-tools"
set "MAVEN_LOCAL=%TOOLS%\apache-maven-3.9.9"
for /f "delims=" %%M in ('where mvn.cmd 2^>nul') do set "MVN=%%M"
if not defined MVN call :find_idea_maven
if not defined MVN if exist "%MAVEN_LOCAL%\bin\mvn.cmd" set "MVN=%MAVEN_LOCAL%\bin\mvn.cmd"
if not defined MVN goto get_maven
:run_maven
echo       Using Maven: %MVN%
call "%MVN%" -q -DskipTests clean package
if errorlevel 1 goto build_failed
echo       Build successful.
goto deploy

:get_maven
echo       Maven not found. Downloading a portable copy once - about 9 MB...
if not exist "%TOOLS%" mkdir "%TOOLS%"
powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; try { Invoke-WebRequest -UseBasicParsing -Uri 'https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.9/apache-maven-3.9.9-bin.zip' -OutFile '%TOOLS%\maven.zip'; Expand-Archive -Force '%TOOLS%\maven.zip' '%TOOLS%'; exit 0 } catch { exit 1 }"
if exist "%MAVEN_LOCAL%\bin\mvn.cmd" set "MVN=%MAVEN_LOCAL%\bin\mvn.cmd"
if defined MVN goto run_maven
echo       Could not download Maven - check your internet connection.

:build_nomaven
echo       Maven not found - using the existing WAR if there is one.
goto deploy

:build_failed
echo [WARNING] Maven build failed - see the messages above.
goto deploy

rem ---------- 4. Deploy + Tomcat ----------
:deploy
if not exist "%WAR_BUILT%" goto war_missing
echo.
echo [4/5] Deploying to Tomcat...
call :port_open 8080
set "TOMCAT_UP=0"
if not errorlevel 1 set "TOMCAT_UP=1"
if "%TOMCAT_UP%"=="0" if exist "%TOMCAT_DIR%\webapps\%APP%" rmdir /s /q "%TOMCAT_DIR%\webapps\%APP%"
copy /y "%WAR_BUILT%" "%TOMCAT_DIR%\webapps\%APP%.war" >nul
if errorlevel 1 goto deploy_fail
echo       WAR deployed.

echo.
echo [5/5] Tomcat...
if "%TOMCAT_UP%"=="1" goto tomcat_running
set "CATALINA_HOME=%TOMCAT_DIR%"
set "CATALINA_BASE=%TOMCAT_DIR%"
pushd "%TOMCAT_DIR%\bin"
start "PMS-Tomcat" /min cmd /c catalina.bat run
popd
call :wait_port 8080 60
if errorlevel 1 goto tomcat_fail
goto wait_app
:tomcat_running
echo       Tomcat already running - app is reloading with the new build.

:wait_app
echo       Waiting for the app to come up...
powershell -NoProfile -Command "for($i=0;$i -lt 60;$i++){ try{ $r=Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:8080/%APP%/' -TimeoutSec 2; if($r.StatusCode -lt 500){exit 0} }catch{ if($_.Exception.Response){exit 0} }; Start-Sleep 1 }; exit 1"
if errorlevel 1 echo [WARNING] App did not answer yet - opening the browser anyway.
start "" "http://localhost:8080/%APP%/"

echo.
echo =========================================================
echo   READY  -  http://localhost:8080/%APP%/
echo =========================================================
echo   Admin:           admin@pms.com   /  admin123
echo   Project Manager: manager@pms.com /  manager123
echo   Team Member:     john@pms.com    /  member123
echo =========================================================
echo   To shut everything down, run stop-pms.bat
echo.
timeout /t 8 >nul
exit /b 0

rem ---------- Error exits ----------
:java_missing
echo [ERROR] Java 17 not found. Install JDK 17 or set JAVA_HOME.
goto fail
:tomcat_missing
echo [ERROR] Tomcat not found at: %TOMCAT_DIR%
echo         Edit TOMCAT_DIR at the top of start-pms.bat.
goto fail
:mysql_missing
echo [ERROR] MySQL is not running and XAMPP was not found at: %XAMPP_DIR%
echo         Start MySQL yourself, or edit XAMPP_DIR at the top of start-pms.bat.
goto fail
:mysql_fail
echo [ERROR] MySQL did not start within 40 seconds.
goto fail
:db_fail
popd
echo [ERROR] Could not import the database scripts.
goto fail
:war_missing
echo [ERROR] No WAR file at: %WAR_BUILT%
echo         Maven build failed or Maven was not found. Build once from IntelliJ (Maven - package).
goto fail
:deploy_fail
echo [ERROR] Could not copy the WAR into Tomcat webapps.
goto fail
:tomcat_fail
echo [ERROR] Tomcat did not start on port 8080. Check the "PMS-Tomcat" window.
goto fail

:fail
echo.
pause
exit /b 1

rem ---------- Helpers ----------
:port_open
netstat -ano | findstr /R /C:":%~1 .*LISTENING" >nul
exit /b

:wait_port
set /a "_t=0"
:wait_port_loop
call :port_open %~1
if not errorlevel 1 exit /b 0
set /a "_t+=1"
if %_t% geq %~2 exit /b 1
timeout /t 1 /nobreak >nul
goto wait_port_loop

:find_idea_maven
for /d %%R in ("%ProgramFiles%\JetBrains\*" "%ProgramW6432%\JetBrains\*" "C:\Program Files\JetBrains\*" "C:\Program Files (Arm)\JetBrains\*" "C:\Program Files (x86)\JetBrains\*" "%LOCALAPPDATA%\Programs\*") do if exist "%%R\plugins\maven\lib\maven3\bin\mvn.cmd" set "MVN=%%R\plugins\maven\lib\maven3\bin\mvn.cmd"
exit /b
