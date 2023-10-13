@echo off

:Set parameters
@REM change the ProjectVersion
@REM so that it reads ProjectVersion= YY.MM.DD.0 use ONLY numbers
@REM seperated with periods in the form YY.MM.DD.0
@REM use the date of compilatation YY.MM.DD.Incremental number usually 0
@REM where YY is the two digit year, MM the digit month, DD two digit day
@REM eg set ProjectVersion=23.07.23.0
set ProjectVersion=23.10.08.0
@REM ProjectDate=YYYY-MM-DD use ONLY numbers
@REM use the date of compilatation in the format YYYY-MM-DD
@REM where YYYY is the four digit year, MM the two digit month, DD two digit day
@REM use the date of compilatation YYYY-MM-DD seperated by a '-'
@REM eg set ProjectDate=2023-07-23
set ProjectDate=2023-10-08
@REM Upload=yes will also generate SetupS-files.htm file ready for upload
set Upload=Yes

:Begin
@REM call !DistrPack.Project.cmd %ProjectVersion% %ProjectDate% %Upload%

@REM #######################################################
@REM ### Create files
@REM #######################################################

:MainMenu
set errorlevel = 0
set selectall=

cls
echo.===============================================================================
echo.                           Dev Pack Tools  - Main Menu
echo.                          Project version  v%ProjectVersion%
echo.                          Select file to compile or all
echo.===============================================================================
echo.
echo.                             [A]   About
echo.
echo.                             [1]   Development Tools
echo.
echo.                             [2]   ssXFormer
echo.
echo.                             [3]   ssCleaner
echo.
echo.                             [4]   ssFATSorter
echo.
echo.                             [5]   ssGooey
echo.
echo.                             [6]   Select all files
echo.
echo.                             [7]   Cleanup
echo.
echo.                             [H]   Help
echo.
echo.
echo.                             [X]   Quit
echo.
echo.===============================================================================
echo.
choice /C:A1234567HX /N /M "Enter Your Choice: "
if errorlevel 10 goto :Quit
if errorlevel 9 goto :mainHelp
if errorlevel 8 goto :Movefiles
if errorlevel 7 set "selectall=AllFiles"  goto :checkfile
if errorlevel 6  set "ssGooey=y" goto :checkfile
if errorlevel 5 set "ssFATSorter=y" goto :checkfile
if errorlevel 4 set "ssCleaner=y" goto :checkfile
if errorlevel 3 set "ssXFormer=y" goto :checkfile
if errorlevel 2 set "devtools=y" goto :checkfile
if errorlevel 1 goto :about
::-------------------------------------------------------------------------------------------

:about
cls
echo. ############################################################
echo.
echo These are the additional tools used in SetupS suite.
echo.
pause
goto MainMenu

:mainHelp
cls
echo. ##############################################################
echo.
echo Select file to compile or all
echo after completion it will copy compiked files to files directory ready for upload
echo then clean up
echo   [1]   Development Tools
echo these are the files needed to create SetupS Suite
echo.
pause
goto MainMenu

@REM checks flag
:checkfile
@REM if allfiles then goto setupallfiles else compile selected file
if "%selectall%" equ "AllFiles" (goto setupallfiles) else (goto :compilefiles)
@REM if "%selectall%" equ "AllFiles" (set "devtools=y" set "ssXFormer=y") else (goto :compilefiles)

@REM set flags for compiling
:setupallfiles
set "devtools=y"
set "ssXFormer=y"
set "ssCleaner=y"
set "ssFATSorter=y"
set "ssGooey=y"

echo. ####Compiling All Files########################################################
goto :compilefiles


:compilefiles

if "%devtools%" equ "y" goto :devtools
if "%ssXFormer%" equ "y" goto :ssXFormer
if "%ssCleaner%" equ "y" goto :ssCleaner
if "%ssFATSorter%" equ "y" goto :ssFATSorter
if "%ssGooey%" equ "y" goto :ssGooey

@REM if files are compiled then cleanup

goto Movefiles

 :devtools
@REM pause
call !DistrPack.Development.Tools.cmd %ProjectVersion% %ProjectDate% %Upload% Development.Tools
set "devtools="
goto compilefiles

:ssXFormer
call !DistrPack.ExtraApp.cmd %ProjectVersion% %ProjectDate% %Upload% ssXFormer
set "ssXFormer="
goto compilefiles

:ssCleaner
call !DistrPack.ExtraApp.cmd %ProjectVersion% %ProjectDate% %Upload% ssCleaner
set "ssCleaner="
goto compilefiles

:ssFATSorter
call !DistrPack.ExtraApp.cmd %ProjectVersion% %ProjectDate% %Upload% ssFATSorter
set "ssFATSorter="
goto compilefiles


:ssGooey
call !DistrPack.ExtraApp.cmd %ProjectVersion% %ProjectDate% %Upload% ssGooey
set "ssGooey="
goto compilefiles



@REM pause
@REM #######################################################
@REM ### Movefiles
@REM #######################################################
:Movefiles
echo Moving files to files directory ...
set completedfiles=files
set sc=Source.Code

:move files to files directory
@REM echo moving files to files directory..
if exist "%completedfiles%" rd /s /q "%completedfiles%" >nul:
md "%completedfiles%"
echo copying files to %completedfiles% directory..
@REM set Upload=Yes
@REM if NOT exist "SetupS-*.htm" echo File not found Change in Make.SetupS-Project.cmd to 'set Upload=Yes'&pause&goto Cleaning
echo copying htm files to files directory..
@REM copy "SetupS-*.htm" "%completedfiles%\" /y >nul:
copy "*.htm" "%completedfiles%\" /y >nul:
@REM echo copying SetupS-*.png files to files directory..
copy "%~dp0%sc%\SetupS-*.png" "%~dp0\%completedfiles%" /y >nul
@REM copy "%~dp0SetupS-*.png" "%~dp0\%completedfiles%" /y >nul
echo copying .7z files to files directory..
@REM
copy "*.7z" "%completedfiles%\" /y >nul:
echo copying apz files to files directory..
@REM SetupS.SendTo.Suite_v23.07.18.1_ssApp.apz
copy "*.apz" "%completedfiles%\" /y >nul:
echo copying exe files to files directory..
@REM Development.Tools_v2023-10-08.exe
copy "*.exe" "%completedfiles%\" /y >nul:
echo copying UploadMe.cmd files to files directory..
@REM UploadMe.cmd
copy "UploadMe.cmd" "%completedfiles%\" /y >nul:
@REM update.ini
copy "update.ini" "%completedfiles%\" /y >nul:
echo copying Checksums files to files directory..
@REM Development.Tools_v2023-10-08.exe.md5
copy "*.md5" "%completedfiles%\" /y >nul:
@REM ChangeLog.txt
copy "ChangeLog.txt" "%completedfiles%\" /y >nul:
@REM pause


@REM #######################################################
@REM ### Cleaning
@REM #######################################################
:Cleaning
echo #######################################################
echo Cleaning up...
echo.
echo  Deleting compilied files
echo #######################################################
cd "%~dp0"
:Deleting files
@REM echo deleting SetupS-*.htm
if exist "*.htm" del /F /Q "*.htm" >nul:
@REM echo deleting SetupS-*.png
@REM if exist "SetupS-*.png" del /F /Q "SetupS-*.png" >nul:
@REM echo deleting 7z
if exist "*.7z" del /F /Q "*.7z" >nul:
@REM echo deleting apz
if exist "*.apz" del /F /Q "*.apz" >nul:
@REM echo deleting exe
if exist "*.exe" del /F /Q "*.exe" >nul:
@REM echo deleting UploadMe.cmd
if exist "UploadMe.cmd" del /F /Q "UploadMe.cmd" >nul:
@REM echo deleting update.ini
if exist "update.ini" del /F /Q "update.ini" >nul:
@REM echo deleting checksums
if exist "*.md5" del /F /Q "*.md5" >nul:
@REM SetupS-title.png

@REM echo  #######################################################
@REM echo   ### Final cleanup
@REM echo #######################################################
@REM %AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "Kill"
@REM if exist "%ssApp%" rd /s /q "%ssApp%" >nul:
@REM if exist "%ppApp%" rd /s /q "%ppApp%" >nul:
@REM if exist "%scp%" rd /s /q "%scp%" >nul:
@REM if exist "%devpack%" rd /s /q "%devpack%" >nul:
@REM if exist "%ssUI%" rd /s /q "%ssUI%" >nul:
@REM rem if exist "%ssII%.exe" del /F /Q "%ssII%.exe" >nul:
@REM if exist "%~dp0%sc%\ssTek.chm" del /F /Q "%~dp0%sc%\ssTek.chm" >nul:
@REM if exist "%~dp0%sc%\ssTek.html" del /F /Q "%~dp0%sc%\ssTek.html" >nul:
@REM if exist "%~dp0%sc%\files" rd /s /q "%~dp0%sc%\files" >nul:
@REM if exist "%~dp0%sc%\%EditorPath%\ssEditor.html" del /F /Q "%~dp0%sc%\%EditorPath%\ssEditor.html" >nul:
@REM if exist "%~dp0%sc%\%EditorPath%\files" rd /s /q "%~dp0%sc%\%EditorPath%\files" >nul:
@REM if exist "%sc%\originals" echo Originals already exists!

@REM @REM Echo %_fRed%%_bBlack% error
@REM @REM Echo %_RESET%
@REM @REM Echo %_fBGreen%%_bBlack%
@REM @REM echo working
@REM @REM Echo %_fYellow%%_bBlue%
@REM @REM echo finished
@REM @REM @REM Echo %_RESET%
@REM Echo %_fBGreen%%_bBlack%
Echo %_bBWhite%%_bBlue% ####################################################### %_fBGreen%%_bBlack%
echo.

 :Quit
:Exit