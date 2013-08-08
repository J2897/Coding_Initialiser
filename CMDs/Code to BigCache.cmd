@echo OFF
set TITLE=Code to BigCache
title %TITLE%
set LOG=%USERPROFILE%\Documents\RoboCopy Logs\%TITLE%.log

REM This needs Administrator privileges for the /SL switch to work. If you're not going to run it with Administrator privileges, remove the /SL switch!!!
start "%TITLE%" /d "%USERPROFILE%\Code" /i /b robocopy.exe "%USERPROFILE%\Code" "T:\Users\J2897\Code" *.* /TEE /MIR /NP /MON:1 /MOT:1 /R:100 /W:30 /SL /LOG:"%LOG%" /XF "desktop.ini" /XD ".git"
