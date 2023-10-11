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
set ProjectVersion=13.11.23.0
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
set EditorPath=ssEditor

:Begin
echo Begin ... %ExtraApp% v%ProjectVersion%
set path=%path%;%~dp0bin;%~dp0%sc%\Tools;%~dp0%sc%\Tools\_x86
cd "%~dp0"
if exist "%sc%\%ExtraApp%\default.ini" xcopy "%sc%\%ExtraApp%\default.ini\*.*" "%sc%\%ExtraApp%\*.*" /y/e/s >nul:

:SetAutoIt3 working variable
set AutoIt3="%ProgramFiles%\AutoIt3\AutoIt3.exe"
if exist "%ProgramFiles(x86)%\AutoIt3\AutoIt3.exe" set AutoIt3="%ProgramFiles(x86)%\AutoIt3\AutoIt3.exe"
FOR %%i IN (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST "%%i:\ppApps\AutoIt3\AutoIt3.exe" (SET AutoIt3="%%i:\ppApps\AutoIt3\AutoIt3.exe"& goto MakeBackups)

:MakeBackups of originals
echo Backing up originals...
cd "%~dp0"
if exist "%sc%\originals" goto exit
md "%sc%\originals\%ExtraApp%"
copy "%sc%\%ExtraApp%\*.au3" "%sc%\originals\%ExtraApp%" /y >nul:
copy "%sc%\%ExtraApp%\*.app" "%sc%\originals\%ExtraApp%" /y >nul:
copy "%sc%\%ExtraApp%\%ExtraApp%.htm" "%sc%\originals\%ExtraApp%" /y >nul:
if exist "%sc%\%ExtraApp%\*.hlp" copy "%sc%\%ExtraApp%\*.hlp" "%sc%\originals\%ExtraApp%" /y >nul:
copy "%sc%\SetupS.Core.au3" "%sc%\originals" /y >nul:

:Find And Replace Text for the following (requires: bin\fart.exe)
echo Updating file resources ...
cd "%~dp0"

::Naming
fart -q -i "%sc%\%ExtraApp%\*.au3" "#ExtraApp#" "%ExtraApp%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.app" "#ExtraApp#" "%ExtraApp%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.hlp" "#ExtraApp#" "%ExtraApp%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.htm" "#ExtraApp#" "%ExtraApp%" >nul:

::Versioning
fart -q -i "%sc%\%ExtraApp%\*.au3" "#ProjectVersion#" "%ProjectVersion%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.app" "#ProjectVersion#" "%ProjectVersion%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.hlp" "#ProjectVersion#" "%ProjectVersion%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.htm" "#ProjectVersion#" "%ProjectVersion%" >nul:
fart -q -i "%sc%\SetupS.Core.au3" "#ProjectVersion#" "%ProjectVersion%" >nul:

fart -q -i "%sc%\%ExtraApp%\*.au3" "#CoreVersion#" "%CoreVersion%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.app" "#CoreVersion#" "%CoreVersion%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.hlp" "#CoreVersion#" "%CoreVersion%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.htm" "#CoreVersion#" "%CoreVersion%" >nul:
fart -q -i "%sc%\SetupS.Core.au3" "#CoreVersion#" "%CoreVersion%" >nul:

::ProjectDate
fart -q -i "%sc%\%ExtraApp%\*.au3" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.app" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.hlp" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.htm" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\SetupS.Core.au3" "#ProjectDate#" "%ProjectDate%" >nul:

::cYear
fart -q -i "%sc%\%ExtraApp%\*.au3" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.app" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.hlp" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.htm" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\SetupS.Core.au3" "#cYear#" "%cYear%" >nul:

::cHolder
fart -q -i "%sc%\%ExtraApp%\*.au3" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.app" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.hlp" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.htm" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\SetupS.Core.au3" "#cHolder#" "%cHolder%" >nul:

::WebSite1
fart -q -i "%sc%\%ExtraApp%\*.au3" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.app" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.hlp" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.htm" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\SetupS.Core.au3" "#WebSite1#" "%WebSite1%" >nul:

::WebLink1
fart -q -i "%sc%\%ExtraApp%\*.au3" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.app" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.hlp" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.htm" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\SetupS.Core.au3" "#WebLink1#" "%WebLink1%" >nul:

::WebSite2
fart -q -i "%sc%\%ExtraApp%\*.au3" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.app" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.hlp" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.htm" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\SetupS.Core.au3" "#WebSite2#" "%WebSite2%" >nul:

::WebLink2
fart -q -i "%sc%\%ExtraApp%\*.au3" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.app" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.hlp" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.htm" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\SetupS.Core.au3" "#WebLink2#" "%WebLink2%" >nul:

::WebSite3
fart -q -i "%sc%\%ExtraApp%\*.au3" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.app" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.hlp" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.htm" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\SetupS.Core.au3" "#WebSite3#" "%WebSite3%" >nul:

::WebLink3
fart -q -i "%sc%\%ExtraApp%\*.au3" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.app" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.hlp" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.htm" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\SetupS.Core.au3" "#WebLink3#" "%WebLink3%" >nul:

::WebSite4
fart -q -i "%sc%\%ExtraApp%\*.au3" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.app" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.hlp" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.htm" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\SetupS.Core.au3" "#WebSite4#" "%WebSite4%" >nul:

::WebLink4
fart -q -i "%sc%\%ExtraApp%\*.au3" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.app" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.hlp" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\%ExtraApp%\*.htm" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\SetupS.Core.au3" "#WebLink4#" "%WebLink4%" >nul:

:Compile EXE's (requires: AutoIt3 plus SciTE)
cd "%~dp0%sc%"
cd "%ExtraApp%"
call Compile.AutoIt.Script.cmd %ExtraApp%
cd ".."

:Create ppApp package
echo Creating the ppApp package...
cd "%~dp0%sc%\%ExtraApp%"
call "Create.ppApp.package.cmd" %ExtraApp%

:Create .apz
cd "%~dp0%sc%\%EditorPath%\"
rem %EditorPath%.exe -autobuild -ExpressInstaller=yes "%~dp0%sc%\%ExtraApp%\%ExtraApp%_ppApp"
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "%EditorPath%.au3" -autobuild -ExpressInstaller=yes "%~dp0%sc%\%ExtraApp%\%ExtraApp%_ppApp"
copy "%~dp0%sc%\%ExtraApp%\*.apz" "%~dp0" /y >nul:
del /F /Q "%~dp0%sc%\%ExtraApp%\*.apz" >nul:

:UpdateINI
if [%DoUploads%]==[No] goto RestoreOriginals
echo Refresh the "Update.ini" file...
cd "%~dp0%bin"
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "UpdateINI.au3" "%~dp0%sc%\%ExtraApp%" "apz" "%WebLink1%/files"
copy "%~dp0%sc%\%ExtraApp%\%ExtraApp%.htm" "%~dp0" /y >nul:

:RestoreOriginals
echo Restoring originals...
cd "%~dp0"
call !RestoreOriginals.cmd

:Create Checksums (requires: md5sum.exe)
echo Calculating md5 checksums...
cd "%~dp0"
md5sum %ExtraApp%_v%ProjectVersion%_ppApp.apz >%ExtraApp%_v%ProjectVersion%_ppApp.apz.md5

:Upload .apz
echo Upload? %DoUploads%
echo.
if [%DoUploads%]==[No] goto Exit
cd "%~dp0"

:Bintray (requires cURL)
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink3%"
call UploadMe.cmd %ExtraApp%_v%ProjectVersion%_ppApp.apz files %ExtraApp% %ProjectVersion%
call UploadMe.cmd %ExtraApp%_v%ProjectVersion%_ppApp.apz.md5 files %ExtraApp% %ProjectVersion%

:GoogleCode (requires python)
rem %AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink4%"
rem call UploadMe.cmd %ExtraApp%_v%ProjectVersion%_ppApp.apz "%ExtraApp% (ppApp package)" Type-Package
rem call UploadMe.cmd %ExtraApp%_v%ProjectVersion%_ppApp.apz.md5 "MD5 checksum"

:ssTekForum (requires cURL)
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink1%"
call UploadMe.cmd %ExtraApp%.htm sstek/files/ .\ ssTek
call UploadMe.cmd %ExtraApp%_v%ProjectVersion%_ppApp.apz sstek/files/ .\ ssTek
call UploadMe.cmd %ExtraApp%_v%ProjectVersion%_ppApp.apz.md5 sstek/files/ .\ ssTek
call UploadMe.cmd update.ini sstek/files/ .\ ssTek

:LastOS (requires cURL)
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink2%"
call UploadMe.cmd %ExtraApp%.htm files/ .\ LastOS
rem call UploadMe.cmd %ExtraApp%_v%ProjectVersion%_ppApp.apz files/ .\ LastOS
call UploadMe.cmd %ExtraApp%_v%ProjectVersion%_ppApp.apz.md5 files/ .\ LastOS
call UploadMe.cmd update.ini files/ .\ LastOS

:Exit
cd "%~dp0"
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "Kill"
if exist "%sc%\originals" echo Originals already exists!
echo %ExtraApp% v%ProjectVersion% ... Done!
echo.