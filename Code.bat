@echo OFF
title Coding Initialiser
pushd "%~dp0"

REM Time (seconds) to wait for RoboCopy to finish after closing Notepad++.
set /a X=70

REM Time (seconds) to wait for drive to wake up if it's sleeping.
set /a Y=5

REM The TrueCrypt drive to look for after mounting.
set DRIVE_LETTER=T:\

:Start
REM Check if Notepad++ is already running.
WMIC PROCESS get Caption > "%TEMP%\procz_alive.tmp"
find /i "notepad++.exe" "%TEMP%\procz_alive.tmp" >nul
if ERRORLEVEL 1 (goto :Initialise)
if ERRORLEVEL 0 (goto :NP_Running) else (exit /b 1)

:Initialise
REM Open the Coding foler.
"%WINDIR%\explorer.exe" "%USERPROFILE%\Code"

REM Scheduled task's names.
set MBC=Personal\VD\Mount BigCache
set CBC=Personal\RoboCopy\Code to BC
set KRC=Personal\RoboCopy\Kill RoboCopy
set DBC=Personal\VD\Dismount BigCache

REM Mount the BigCache (TrueCrypt file-hosted volume) if it's not already mounted.
if not exist "%DRIVE_LETTER%" (schtasks /run /tn "%MBC%")

REM Watch out for the BigCache coming online, and end if it doesn't.
set /a LOOKS=1
:Look_Again
if %LOOKS%==250 (set /a WAITED=0) && (goto :Wait_Longer)
if not exist "%DRIVE_LETTER%" (
	set /a LOOKS=LOOKS+1
	goto :Look_Again
) else (echo.) && (echo Found drive %DRIVE_LETTER% after looking %LOOKS% times.)

:Waited
set LOOKS=
set WAITED=

REM Wait for user to finish coding.
echo.
echo Do not close this window. It will automatically close itself %X% seconds after
echo you have closed Notepad++, giving RoboCopy a minimum of 10 seconds to back up
echo anything that you may have saved upon exit.
echo.

REM Launch RoboCopy if it's not already running.
find /i "robocopy.exe" "%TEMP%\procz_alive.tmp" >nul
if ERRORLEVEL 1 (schtasks /run /tn "%CBC%")
if exist "%TEMP%\procz_alive.tmp" (del "%TEMP%\procz_alive.tmp")

REM Launch Notepad++.
call "%CD%\CMDs\Notepad++.cmd"

REM Kill RoboCopy after %X% seconds.
timeout /t %X% /nobreak
schtasks /run /tn "%KRC%"
set X=

REM Dismount the BigCache if it's mounted.
if exist "%DRIVE_LETTER%" (schtasks /run /tn "%DBC%")

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

:Wait_Longer
if WAITED==3 (goto :Mount_Failure)
if not exist "%DRIVE_LETTER%" (
	timeout /t %Y% /nobreak
	set /a WAITED=WAITED+1
	goto :Wait_Longer
) else (echo.) && (echo Found drive %DRIVE_LETTER% after waiting %Y% seconds %WAITED% times.)
goto :Waited

:Mount_Failure
echo Failed to mount the BigCache.
echo.
echo pause
popd
exit /b 1
