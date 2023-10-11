:This script creates dual architecture (x86|x64) distribution packages. Does NOT require an x64-machine to run.
:Assumes the following are installed: AutoIt3 (plus SciTE) and Inno Setup.
:The following folders also need to be present: bin, sfx, and curl.
:7zip.exe will be required but is already included in the Tools folder.
@echo off

@REM ref https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/color
@REM black / green color 02
@REM color 02
@REM blue / white color 17
@REM color 17
  @REM black / Light Green color 0A
color 0A
@REM cls
call !RestoreOriginals.cmd

:getExtraApp
if [%4]==[] goto setExtraApp
set ExtraApp=%4
goto getDoUploads

:setExtraApp
set ExtraApp=ssGooey
goto getDoUploads

:getDoUploads
if [%3]==[] goto setDoUploads
set DoUploads=%3
goto getDate

:setDoUploads
set DoUploads=No
goto getDate

:getDate
if [%2]==[] goto setDate
set ProjectDate=%2
goto getVer

:setDate
set ProjectDate=2013-11-23
goto getVer

:getVer
if [%1]==[] goto setVer
set ProjectVersion=%1
goto setText

:setVer
set ProjectVersion=13.7.15.0
goto setText

:setText
set cYear=2023
set cHolder=Vergitek Solutions
set WebSite1=ssTek Forum
set WebLink1=sstek.vergitek.com
set WebSite2=LastOS Team
set WebLink2=www.lastos.org
set WebSite3=ssTek Distribution
set WebLink3=dl.bintray.com/sstek
set WebSite4=ssTek Development
set WebLink4=sstek.googlecode.com
set CoreVersion=%ProjectVersion%
set sc=Source.Code
set SFXMaker=ssXFormer

:Begin
echo Begin ... %ExtraApp% v%ProjectDate%
set path=%path%;%~dp0bin;%~dp0%sc%\Tools;%~dp0%sc%\Tools\_x86
cd "%~dp0"

:SetAutoIt3 working variable
set AutoIt3="%ProgramFiles%\AutoIt3\AutoIt3.exe"
if exist "%ProgramFiles(x86)%\AutoIt3\AutoIt3.exe" set AutoIt3="%ProgramFiles(x86)%\AutoIt3\AutoIt3.exe"
FOR %%i IN (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST "%%i:\ppApps\AutoIt3\AutoIt3.exe" (SET AutoIt3="%%i:\ppApps\AutoIt3\AutoIt3.exe"& goto MakeBackups)

:MakeBackups of originals
cd "%~dp0"
if exist "%sc%\originals" goto exit
md "%sc%\originals\%ExtraApp%"
copy "%sc%\%ExtraApp%\%ExtraApp%.htm" "%sc%\originals\%ExtraApp%" /y >nul:

:Find And Replace Text for the following (requires: bin\fart.exe)
echo Updating Text ...
cd "%~dp0"
fart -q -i "%sc%\%ExtraApp%\%ExtraApp%.htm" "#ExtraApp#" "%ExtraApp%" >nul:
fart -q -i "%sc%\%ExtraApp%\%ExtraApp%.htm" "#ProjectVersion#" "%ProjectVersion%" >nul:
fart -q -i "%sc%\%ExtraApp%\%ExtraApp%.htm" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\%ExtraApp%\%ExtraApp%.htm" "#CoreVersion#" "%CoreVersion%" >nul:
fart -q -i "%sc%\%ExtraApp%\%ExtraApp%.htm" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\%ExtraApp%\%ExtraApp%.htm" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\%ExtraApp%\%ExtraApp%.htm" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\%ExtraApp%\%ExtraApp%.htm" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\%ExtraApp%\%ExtraApp%.htm" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\%ExtraApp%\%ExtraApp%.htm" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\%ExtraApp%\%ExtraApp%.htm" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\%ExtraApp%\%ExtraApp%.htm" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\%ExtraApp%\%ExtraApp%.htm" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\%ExtraApp%\%ExtraApp%.htm" "#WebLink3#" "%WebLink3%" >nul:

:Create Development Tools APZ (requires: 7zip)
echo Constructing the Development Tools package (as APZ)...
cd "%~dp0"
if exist %ExtraApp%_v%ProjectDate% rd /s /q %ExtraApp%_v%ProjectDate% >nul:
md %ExtraApp%_v%ProjectDate% >nul:
cd %ExtraApp%_v%ProjectDate% >nul:
xcopy "%~dp0%sc%\%ExtraApp%\*.*" /s/e/y >nul:
7z a "%ExtraApp%_v%ProjectDate%.apz" -ms=on -mx=9 -m0=lzma2 >nul:
copy "%ExtraApp%_v%ProjectDate%.apz" "..\%ExtraApp%_v%ProjectDate%.apz" /y >nul:
del /F /Q "%ExtraApp%_v%ProjectDate%.apz" >nul:

:MakeSFX
cd "%~dp0%sc%\%SFXMaker%\"
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "%SFXMaker%.au3" -autobuild "%~dp0%ExtraApp%_v%ProjectDate%.apz"

:RestoreOriginals
echo Restoring originals...
cd "%~dp0"
call !RestoreOriginals.cmd

:Create Checksums (requires: md5sum.exe)
echo Calculating md5 checksums...
cd "%~dp0"
md5sum %ExtraApp%_v%ProjectDate%.exe >%ExtraApp%_v%ProjectDate%.exe.md5
if exist %ExtraApp%_v%ProjectDate%.7z del /F /Q %ExtraApp%_v%ProjectDate%.7z >nul:
if exist %ExtraApp%_v%ProjectDate%.apz rename %ExtraApp%_v%ProjectDate%.apz %ExtraApp%_v%ProjectDate%.7z
md5sum %ExtraApp%_v%ProjectDate%.7z >%ExtraApp%_v%ProjectDate%.7z.md5

:Upload .apz
echo Upload? %DoUploads%
echo.
if [%DoUploads%]==[No] goto Exit
cd "%~dp0"
copy %ExtraApp%_v%ProjectDate%\%ExtraApp%.htm /y >nul:

:Bintray (requires cURL)
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink3%"
call UploadMe.cmd %ExtraApp%_v%ProjectDate%.exe files %ExtraApp% %ProjectDate%
call UploadMe.cmd %ExtraApp%_v%ProjectDate%.exe.md5 files %ExtraApp% %ProjectDate%

:GoogleCode (requires python)
rem %AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink4%"
rem call UploadMe.cmd %ExtraApp%_v%ProjectDate%.exe "Everything needed to work with the Full Developers Package." Type-Executable,Type-Archive,OpSys-Windows
rem call UploadMe.cmd %ExtraApp%_v%ProjectDate%.exe.md5 "MD5 Checksums"

:ssTekForum (requires cURL)
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink1%"
call UploadMe.cmd %ExtraApp%_v%ProjectDate%.exe sstek/files/ .\ ssTek
call UploadMe.cmd %ExtraApp%_v%ProjectDate%.exe.md5 sstek/files/ .\ ssTek
call UploadMe.cmd %ExtraApp%.htm sstek/files/ .\ ssTek

:LastOS (requires cURL)
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink2%"
rem call UploadMe.cmd %ExtraApp%_v%ProjectDate%.exe files/ .\ LastOS
call UploadMe.cmd %ExtraApp%_v%ProjectDate%.exe.md5 files/ .\ LastOS
call UploadMe.cmd %ExtraApp%.htm files/ .\ LastOS

Goto Exit

:Exit
echo Cleaning up...
cd "%~dp0"
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "Kill"
if exist "%ExtraApp%_v%ProjectDate%" rd /s /q "%ExtraApp%_v%ProjectDate%" >nul:
if exist %ExtraApp%_v%ProjectDate%.apz del /F /Q %ExtraApp%_v%ProjectDate%.apz
if exist %ExtraApp%_v%ProjectDate%.7z del /F /Q %ExtraApp%_v%ProjectDate%.7z
if exist %ExtraApp%_v%ProjectDate%.7z.md5 del /F /Q %ExtraApp%_v%ProjectDate%.7z.md5
if exist "%sc%\originals" echo Originals already exists!


@REM @REM #######################################################
@REM @REM ### Movefiles
@REM @REM #######################################################
@REM :Movefiles
@REM echo Moving files to files directory ...
@REM set completedfiles=files

@REM :move files to files directory
@REM @REM echo moving files to files directory..
@REM if exist "%completedfiles%" rd /s /q "%completedfiles%" >nul:
@REM md "%completedfiles%"
@REM echo copying setups files to files directory..
@REM @REM set Upload=Yes
@REM @REM if NOT exist "SetupS-*.htm" echo File not found Change in Make.SetupS-Project.cmd to 'set Upload=Yes'&pause&goto Cleaning
@REM echo copying htm files to files directory..
@REM @REM copy "SetupS-*.htm" "%completedfiles%\" /y >nul:
@REM copy "*.htm" "%completedfiles%\" /y >nul:
@REM echo copying SetupS-*.png files to files directory..
@REM @REM copy "%~dp0SetupS-*.png" "%~dp0\%completedfiles%" /y >nul
@REM echo copying .7z files to files directory..
@REM @REM SetupS.Project_v23.07.18.1_DevelopersPack.7z
@REM copy "*.7z" "%completedfiles%\" /y >nul:
@REM echo copying apz files to files directory..
@REM @REM SetupS.SendTo.Suite_v23.07.18.1_ssApp.apz
@REM copy "*.apz" "%completedfiles%\" /y >nul:
@REM echo copying exe files to files directory..
@REM @REM SetupS.SendTo.Suite_v23.07.18.1_ssApp.exe
@REM copy "*.exe" "%completedfiles%\" /y >nul:
@REM echo copying UploadMe.cmd files to files directory..
@REM @REM UploadMe.cmd
@REM copy "UploadMe.cmd" "%completedfiles%\" /y >nul:
@REM @REM update.ini
@REM copy "update.ini" "%completedfiles%\" /y >nul:
@REM echo copying Uchecksums files to files directory..
@REM @REM checksums_v23.07.18.1.md5
@REM copy "*.md5" "%completedfiles%\" /y >nul:
@REM @REM ChangeLog.txt
@REM copy "ChangeLog.txt" "%completedfiles%\" /y >nul:
@REM @REM pause

@REM @REM #######################################################
@REM @REM ### Cleaning
@REM @REM #######################################################
@REM :Cleaning
@REM echo #######################################################
@REM echo Cleaning up...
@REM echo.
@REM echo  Deleting compilied files after upload
@REM echo #######################################################
@REM cd "%~dp0"
@REM :Deleting files

@REM if exist "*.htm" del /F /Q "*.htm" >nul:
@REM @REM echo deleting SetupS-*.png
@REM @REM if exist "SetupS-*.png" del /F /Q "SetupS-*.png" >nul:
@REM @REM echo deleting 7z
@REM if exist "*.7z" del /F /Q "*.7z" >nul:
@REM @REM echo deleting apz
@REM if exist "*.apz" del /F /Q "*.apz" >nul:
@REM @REM echo deleting exe
@REM if exist "*.exe" del /F /Q "*.exe" >nul:
@REM @REM echo deleting UploadMe.cmd
@REM if exist "UploadMe.cmd" del /F /Q "UploadMe.cmd" >nul:
@REM @REM echo deleting update.ini
@REM if exist "update.ini" del /F /Q "update.ini" >nul:
@REM @REM echo deleting checksums
@REM if exist "*.md5" del /F /Q "*.md5" >nul:

@REM echo  #######################################################
@REM echo   ### Final cleanup
@REM echo #######################################################
@REM %AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "Kill"
@REM @REM if exist "%ssApp%" rd /s /q "%ssApp%" >nul:
@REM @REM if exist "%ppApp%" rd /s /q "%ppApp%" >nul:
@REM @REM if exist "%scp%" rd /s /q "%scp%" >nul:
@REM @REM if exist "%devpack%" rd /s /q "%devpack%" >nul:
@REM @REM if exist "%ssUI%" rd /s /q "%ssUI%" >nul:
@REM rem if exist "%*%.exe" del /F /Q "%*%.exe" >nul:
@REM rem if exist "%*%.md5" del /F /Q "%*%.exe" >nul:
@REM if exist "%~dp0%sc%\ssTek.chm" del /F /Q "%~dp0%sc%\ssTek.chm" >nul:
@REM if exist "%~dp0%sc%\ssTek.html" del /F /Q "%~dp0%sc%\ssTek.html" >nul:
@REM if exist "%~dp0%sc%\files" rd /s /q "%~dp0%sc%\files" >nul:
@REM if exist "%~dp0%sc%\%EditorPath%\ssEditor.html" del /F /Q "%~dp0%sc%\%EditorPath%\ssEditor.html" >nul:
@REM if exist "%~dp0%sc%\%EditorPath%\files" rd /s /q "%~dp0%sc%\%EditorPath%\files" >nul:
@REM if exist "%sc%\originals" echo Originals already exists!

echo.
echo %ExtraApp% v%ProjectDate% ... Done!
echo.
