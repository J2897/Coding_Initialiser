@echo OFF
set NPL=Notepad++ Launcher
title %NPL%

start "%NPL%" /d "%USERPROFILE%\Code" /i /w /max "C:\Program Files\Notepad++\notepad++.exe"
