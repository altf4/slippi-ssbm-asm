@echo off
echo Building tas.json...
gecko build -c tas.json -defsym "STG_EXIIndex=1"
echo.

pause
