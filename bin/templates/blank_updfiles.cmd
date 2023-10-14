@echo off
color 02
set filesini1=filesvergitek.ini
@REM updfiles.cmd
@REM this file has been added to .gitignore to prevent upload to github
@REM of sensitive data
@REM this script changes the password in fileslastos.ini to the correct one
@REM change mypass to correct password
@REM set pw for  filesini2


@REM compare the var filesini1 with the incoming filename
@REM if matches then goto nextfile else continue

if %filesini1%==%1 goto nextfile

@REM IF [NOT] EXIST filename command

@REM if then else

@REM  example of using if exist else
@REM IF EXIST filename.txt (
@REM     Echo deleting filename.txt
@REM     Del filename.txt
@REM  ) ELSE (
@REM     Echo The file was not found.
@REM  )

@REM first file to update pw
@REM if file does not exist goto exit
if NOT EXIST  %1 (
    echo file not found %1
    timeout /t 5
    goto exit
) ELSE (
   pw=mypass1
@REM this will replace the txt label of #password# to pw
    echo.
    echo updating %1
    echo.
   fart -q -i -r ".\%1" "#password#" "%pw%" >nul:
    echo.
    goto exit
)

@REM check if file exist
:nextfile
@REM  if the valus is the content of %filesini1%
@REM second file to update pw

@REM IF [NOT] EXIST filename command
@REM if file does not exist goto exit
if NOT EXIST  %1 (
    echo file not found %1
    timeout /t 5
    goto exit
) ELSE (
set pw=mypass2
@REM this will replace the txt label of #password# to pw
    echo.
    echo updating %1
    echo.
   fart -q -i -r ".\%1" "#password#" "%pw%" >nul:
    echo.
    goto exit
)

:exit
echo finish