@echo off
set PVM_DIR=%LOCALAPPDATA%\pvm
echo Installing PVM to %PVM_DIR%...

mkdir "%PVM_DIR%\versions" 2>nul
mkdir "%PVM_DIR%\cache" 2>nul
mkdir "%PVM_DIR%\alias" 2>nul

copy pvm.exe "%PVM_DIR%\"
copy pvm.cmd "%PVM_DIR%\"
copy settings.txt "%PVM_DIR%\"

echo Adding PVM to PATH...
setx PATH "%PATH%;%PVM_DIR%;%PVM_DIR%\current"

echo PVM installed successfully!
echo Restart your terminal and type 'pvm' to get started.
pause
