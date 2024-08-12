chcp 65001

@echo off 
set path="C:\Users\user\folder1\some other folder"

REM make sure that path includes putty installation
taskkill /F /IM putty.exe

REM wait 1 second
ping -n 1 -w 1000 127.0.0.1 > nul

REM Delete Files Older Than 1 Days 
ForFiles /p %path% /s /d -1 /c "cmd /c del /q @file"

REM start putty again
start putty.exe -load "EXACT NAME OF THE SAVED SESSION"
