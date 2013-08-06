@echo OFF
title Coding Initialiser
pushd "%~dp0"

REM Time (seconds) to wait for RoboCopy.
set /a X=70

:Start
REM Check if Notepad++ is already running.
WMIC PROCESS get Caption > "%TEMP%\procz_alive.tmp"
find /i "notepad++.exe" "%TEMP%\procz_alive.tmp" >nul
if ERRORLEVEL 1 (goto :Initialise)
if ERRORLEVEL 0 (goto :NP_Running) else (exit /b 1)

:Initialise
REM Mount the BigCache (TrueCrypt file-hosted volume) if it's not already mounted.
if not exist "T:\" (schtasks /run /tn "Personal\VD\Mount BigCache")

REM Watch out for the BigCache coming online, and end if it doesn't.
set /a LOOKS=0
:Look_Again
if %LOOKS%==250 (set /a WAITED=0) && (goto :Wait_Longer)
if not exist "T:\" (
	set /a LOOKS=LOOKS+1
	echo Looking again . . .
	goto :Look_Again
)

:Wait_Longer
if WAITED==3 (goto :End)
if not exist "T:\" (
	echo Waiting longer . . .
	timeout /t 5 /nobreak
	set /a WAITED=WAITED+1
	goto :Wait_Longer
)

set LOOKS=
set WAITED=

REM Wait for user to finish coding.
echo.
echo Do not close this window. It will automatically close itself %X% seconds after
echo you have closed Notepad++, giving RoboCopy a minimum of 10 seconds to back up
echo anything you may have saved upon exit.
echo.

REM Launch RoboCopy if it's not already running.
find /i "robocopy.exe" "%TEMP%\procz_alive.tmp" >nul
if ERRORLEVEL 1 (schtasks /run /tn "Personal\RoboCopy\Code to BC")
if exist "%TEMP%\procz_alive.tmp" (del "%TEMP%\procz_alive.tmp")

REM Launch Notepad++.
call "%CD%\CMDs\Notepad++.cmd"

REM Kill RoboCopy after %X% seconds.
timeout /t %X% /nobreak
schtasks /run /tn "Personal\RoboCopy\Kill RoboCopy"
set X=

REM Dismount the BigCache if it's mounted.
if exist "T:\" (schtasks /run /tn "Personal\VD\Dismount BigCache")

:End
popd
exit /b 0

:NP_Running
echo Notepad++ is already running. Please close Notepad++ so that it can be
echo launched in the new environment.
echo.
pause
cls
goto :Start
