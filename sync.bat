@echo off

set VERSION=8.3.12.1412
set PLATFORM=c:\Program Files\1cv8\%VERSION%\bin\1cv8.exe
set EDT_PROJECT_VERSION=8.3.12

set DB_TRUNK=c:\1C\Dev\DevDB
set DB_USER=
set DB_PASS=
set REPO_ADDRESS=tcp://server:1542/Path_to_repo
set REPO_USER_NAME=UserName
set REPO_PASS=

set WORKSPACE=c:\1C\DT\1.8\YourConfig_import
set DUMP_FOLDER=c:\1C\DT\1.8\YourConfig_dump
set GIT_REPO=c:\1C\DT\1.8\git\YourConfig_dt
set PROJECT_PATH=%GIT_REPO%\YourConfig
set LOGFILE=c:\1C\DT\1.8\YourConfig\log.txt

:: Default author name - leave "anonymous"
set GIT_AUTHOR_NAME="Anonymous"
set GIT_COMMITTER_NAME="Anonymous"
set GIT_AUTHOR_EMAIL="<anonymous@1c.ru>"
set GIT_COMMITTER_EMAIL="<anonymous@1c.ru>"

set START_TIME=%date% - %time%

ECHO Start %date% - %time% >> %LOGFILE%
"%PLATFORM%" DESIGNER /F "%DB_TRUNK%" /N "%DB_USER%" /P "%DB_PASS%" /WA- /DisableStartupDialogs /ConfigurationRepositoryF "%REPO_ADDRESS%" /ConfigurationRepositoryN "%REPO_USER_NAME%" /ConfigurationRepositoryP "%REPO_PASS%" /ConfigurationRepositoryUpdateCfg -force /Out "%LOGFILE%" -NoTruncate

cd "%GIT_REPO%" >> %LOGFILE%
git pull >> %LOGFILE% 2>&1

rd /S /Q "%WORKSPACE%"
md  "%WORKSPACE%"
rd /S /Q "%DUMP_FOLDER%"
rd /S /Q "%PROJECT_PATH%"
md  "%DUMP_FOLDER%"

ECHO Dump config files %date% - %time% >> %LOGFILE%
"%PLATFORM%" DESIGNER /F "%DB_TRUNK%" /N "%DB_USER%" /P "%DB_PASS%" /WA- /DisableStartupDialogs /DumpConfigToFiles "%DUMP_FOLDER%" -force /Out "%LOGFILE%" -NoTruncate

ECHO Convert config files to EDT %date% - %time% >> %LOGFILE%
call ring edt workspace import --workspace-location %WORKSPACE% --configuration-files %DUMP_FOLDER% --project %PROJECT_PATH% --version %EDT_PROJECT_VERSION% >> %LOGFILE% 2>&1
ECHO Finished convert config files to EDT %date% - %time% >> %LOGFILE%
ECHO Error level: %ERRORLEVEL% >> %LOGFILE%

if %ERRORLEVEL% NEQ 0 echo Unsuccessful >> %LOGFILE%
if %ERRORLEVEL% NEQ 0 exit %ERRORLEVEL% >> %LOGFILE%

cd "%GIT_REPO%" >> %LOGFILE%

ECHO Start commit to Git %date% - %time% >> %LOGFILE%

git add ./ --all >> %LOGFILE% 2>&1
git commit -m "Sync from main 1C Storage @ %START_TIME%" >> %LOGFILE% 2>&1
git push -u origin master >> %LOGFILE% 2>&1

ECHO Finished %date% - %time% >> %LOGFILE%